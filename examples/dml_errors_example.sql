DECLARE
    ----------------------------------------------------------------------------
    -- Example Use Case: Capturing DML Errors using ELOX and LOG ERRORS
    ----------------------------------------------------------------------------
    -- This example demonstrates how to capture and collect runtime errors from
    -- a BULK INSERT using Oracle's LOG ERRORS mechanism and the ELOX framework.
    --
    -- Scenario:
    --   - Attempt to insert duplicate or null primary keys into a target table
    --   - Use DBMS_ERRLOG to capture the errors in a dedicated error log table
    --   - Use ELOX to fetch, collect and format these errors into a centralized collector
    --
    -- Real-world usage:
    --   - Data warehouse loading
    --   - Post-import sanity checks
    --   - Deferred error handling in large DML jobs
    ----------------------------------------------------------------------------

    -- Dependencies for this demo:
    --   create table target_table (id integer primary key , value_1 integer, value_2 integer);
    --   exec dbms_errlog.create_error_log('target_table');

    ----------------------------------------------------------------------------
    -- SECTION: Constants & Error Collector
    ----------------------------------------------------------------------------
    error_collector elox_types.error_collector;

    co_log_table_name     constant user_tables.table_name%type := 'ERR$_TARGET_TABLE';
    co_context_dml_demo   constant varchar2(100) := 'TARGET_INSERT';
    co_log_tag            constant varchar2(2000) := to_char(systimestamp, 'yyyy-mm-dd hh24:mi:ssxff') || ' - INSERT';
    co_log_owner          constant varchar2(30) := user;

    ----------------------------------------------------------------------------
    -- Utility: Convert BOOLEAN to string (true/false)
    ----------------------------------------------------------------------------
    function to_string(in_boolean in boolean) return varchar2 is
    begin
        return case when in_boolean then 'true' else 'false' end;
    end to_string;

BEGIN
    ----------------------------------------------------------------------------
    -- STEP 1: Initialize error collector
    ----------------------------------------------------------------------------
    error_collector := elox.new_collector;

    ----------------------------------------------------------------------------
    -- STEP 2: Perform DML with LOG ERRORS
    ----------------------------------------------------------------------------
    insert into target_table(id, value_1, value_2)
    select 1,    1, 2 from dual union all     -- ✅ valid row
    select 1,    1, 2 from dual union all     -- ❌ duplicate PK
    select null, 1, 2 from dual               -- ❌ null PK
    log errors into ERR$_TARGET_TABLE (co_log_tag)
    reject limit unlimited;

    ----------------------------------------------------------------------------
    -- STEP 3: Transfer DML errors into ELOX error_collector
    ----------------------------------------------------------------------------
    error_collector.capture_errors_by(
        strategy => elox.detect_dml_errrors(
            in_log_table_name      => co_log_table_name,
            in_error_tag           => co_log_tag,
            in_reference_id_column => 'id' -- used to associate error with a unique row identifier
        )
    );

    ----------------------------------------------------------------------------
    -- STEP 4: Output error details
    ----------------------------------------------------------------------------
    dbms_output.put_line('=== DML Error Collection Report ===');
    dbms_output.put_line(' - Context Tag(s): ' || elox.join_string(in_error_contexts => error_collector.get_contexts));
    dbms_output.put_line(' - Total Errors:   ' || error_collector.get_size);
    dbms_output.put_line(' - Errors Present: ' || to_string(error_collector.has_errors));

    dbms_output.new_line;
    dbms_output.put_line('Error Codes:');
    dbms_output.put_line(' - ' || elox.join_string(error_collector.get_error_codes));

    dbms_output.new_line;
    dbms_output.put_line('Detailed Messages:');
    for i in 1 .. error_collector.get_size loop
        dbms_output.put_line(' - #' || i || ': ' ||
            error_collector.get_error(i).code || ' - ' ||
            error_collector.get_error(i).message);
    end loop;

    dbms_output.new_line;
    dbms_output.put_line('JSON Representation:');
    dbms_output.put_line(error_collector.to_string);

    ----------------------------------------------------------------------------
    -- STEP 5: Cleanup test data (rollback simulation)
    ----------------------------------------------------------------------------
    rollback;

END;
