DECLARE
    ----------------------------------------------------------------------------
    -- Example Use Case: Capturing Bulk DML Errors using ELOX
    ----------------------------------------------------------------------------
    -- This example shows how ELOX can be used in combination with FORALL DML
    -- and SQL%BULK_EXCEPTIONS to capture errors that occur at individual
    -- array indexes during bulk processing.
    --
    -- Strategy used: ot_bulk_error_detection_strategy
    --
    -- Required setup before execution:
    --   CREATE TABLE target_table (
    --       id       INTEGER PRIMARY KEY,
    --       value_1  INTEGER,
    --       value_2  INTEGER
    --   );
    --
    -- Real-world relevance:
    --   - ETL transformations where data must be loaded in chunks
    --   - Use cases where partial success is acceptable
    --   - Enhanced diagnostics for failed rows during large updates/inserts
    ----------------------------------------------------------------------------

    -- Error Collector
    error_collector elox_types.error_collector;

    -- Sample input data
    type t_ids_type is table of target_table.id%type;
    type t_values_type is table of target_table.value_1%type;

    t_ids     t_ids_type    := t_ids_type(1, null, 2, 1); -- duplicate ID and null ID
    t_values  t_values_type := t_values_type(10, 20, 30, 40);

    -- Constants
    co_context_bulk_insert constant varchar2(100) := 'EXAMPLE_CONTEXT';

    ----------------------------------------------------------------------------
    -- Helper: Convert boolean to string
    ----------------------------------------------------------------------------
    function to_string(in_boolean in boolean) return varchar2 is
    begin
        return case when in_boolean then 'true' else 'false' end;
    end to_string;

BEGIN
    ----------------------------------------------------------------------------
    -- STEP 1: Init collector
    ----------------------------------------------------------------------------
    error_collector := elox.new_collector;

    ----------------------------------------------------------------------------
    -- STEP 2: Perform bulk DML with exception tracking
    ----------------------------------------------------------------------------
    begin
        forall idx in 1 .. t_ids.count save exceptions
            insert into target_table(id, value_1, value_2)
            values (t_ids(idx), t_values(idx), t_values(idx) + 100);
    exception
        when elox_exceptions.array_dml_error then
            for idx in 1 .. SQL%BULK_EXCEPTIONS.count loop
                error_collector.capture_errors_by(
                    strategy => ot_bulk_error_detection_strategy(
                        exception_index => idx,
                        context         => co_context_bulk_insert,
                        reference_id    => t_ids(elox.bulk_error_index_at(idx)), -- Allows linking to a unique identifier
                        custom_message  => case elox.bulk_error_code_at(idx)  -- custom_message overrides SQLERRM with a user-defined text; if NULL, the default error message is used.
                                            when -1400 then 'Bulk insert failed because primary column was null'
                                            else NULL
                                           end
                    )
                );
            end loop;
    end;

    ----------------------------------------------------------------------------
    -- STEP 3: Output collected error report
    ----------------------------------------------------------------------------
    dbms_output.put_line('=== Bulk Error Collection Report ===');
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
            error_collector.get_error(i).message || ' (ref=' || error_collector.get_error(i).reference_id || ')');
    end loop;

    dbms_output.new_line;
    dbms_output.put_line('JSON Output:');
    dbms_output.put_line(error_collector.to_string);

    rollback;
END;