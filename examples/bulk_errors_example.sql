DECLARE
    ----------------------------------------------------------------------------
    -- Example Use Case: Capturing Bulk DML Errors with Index Reference
    ----------------------------------------------------------------------------
    -- This script demonstrates how to use the ELOX strategy 
    -- `ot_bulk_errors_detection_strategy` to collect errors that occur during
    -- bulk DML operations (e.g., FORALL).
    --
    -- Key characteristics of this strategy:
    --   - No access to specific column values from the input data
    --   - The reference_id refers to the error index in the input array
    --     (i.e., the value of SQL%BULK_EXCEPTIONS(idx).error_index)
    --
    -- This is particularly helpful when column-level values are not needed,
    -- or when only the positional context is relevant.
    --
    -- Prerequisites:
    --   CREATE TABLE target_table (
    --     id       INTEGER PRIMARY KEY,
    --     value_1  INTEGER,
    --     value_2  INTEGER
    --   );
    ----------------------------------------------------------------------------

    -- Error Collector
    error_collector elox_types.error_collector;

    -- Sample Input
    type t_ids_type is table of target_table.id%type;
    type t_vals_type is table of target_table.value_1%type;

    t_ids   t_ids_type  := t_ids_type(1, null, 1, 2); -- Null + duplicate key errors
    t_vals  t_vals_type := t_vals_type(10, 20, 30, 40);

    -- Constants
    co_context_bulk_index constant varchar2(100) := 'BULK_BY_INDEX';

    -- Utility
    function to_string(in_bool boolean) return varchar2 is
    begin
        return case when in_bool then 'true' else 'false' end;
    end to_string;

BEGIN
    ----------------------------------------------------------------------------
    -- STEP 1: Init collector
    ----------------------------------------------------------------------------
    error_collector := elox.new_collector;

    ----------------------------------------------------------------------------
    -- STEP 2: Perform bulk insert with SAVE EXCEPTIONS
    ----------------------------------------------------------------------------
    BEGIN
        forall idx in 1 .. t_ids.count save exceptions
            insert into target_table(id, value_1, value_2)
            values (t_ids(idx), t_vals(idx), t_vals(idx) + 100);
    EXCEPTION
        WHEN elox_exceptions.array_dml_error THEN
            error_collector.capture_errors_by(
                strategy => ot_bulk_errors_detection_strategy(
                    context => co_context_bulk_index)
            );
    END;

    ----------------------------------------------------------------------------
    -- STEP 3: Output collected result
    ----------------------------------------------------------------------------
    dbms_output.put_line('=== Bulk Error Index-Based Collection ===');
    dbms_output.put_line(' - Errors Present: ' || to_string(error_collector.has_errors));
    dbms_output.put_line(' - Total Errors:   ' || error_collector.get_size);

    dbms_output.new_line;
    dbms_output.put_line('Collected Error Entries:');
    for i in 1 .. error_collector.get_size loop
        dbms_output.put_line(' - Error #' || i || ': Code=' ||
            error_collector.get_error(i).code || 
            ', RefIndex=' || error_collector.get_error(i).reference_id || 
            ', Msg="' || error_collector.get_error(i).message || '"');
    end loop;

    dbms_output.new_line;
    dbms_output.put_line('Collector as JSON:');
    dbms_output.put_line(error_collector.to_string);

    ROLLBACK;
END;
