DECLARE
    ----------------------------------------------------------------------------
    -- Basic Error Collection Demo using ELOX
    --
    -- Demonstrates how to:
    --   - collect exceptions and manual errors during PL/SQL execution
    --   - combine multiple error sources
    --   - evaluate which specific errors occurred (or didn't)
    --   - format and interpret results
    ----------------------------------------------------------------------------

    error_collector elox_types.error_collector;

    ----------------------------------------------------------------------------
    -- Simulated error codes and exceptions
    ----------------------------------------------------------------------------
    co_sqlcode_foobar constant pls_integer := -20000;
    co_sqlcode_foo    constant pls_integer := -20001;
    co_sqlcode_bar    constant pls_integer := -20002;
    co_sqlcode_dummy  constant pls_integer := -20999;  -- Not triggered

    e_foobar exception;
    e_foo exception;
    e_bar exception;
    e_dummy exception;

    pragma exception_init(e_foobar, co_sqlcode_foobar);
    pragma exception_init(e_foo, co_sqlcode_foo);
    pragma exception_init(e_bar, co_sqlcode_bar);
    pragma exception_init(e_dummy, co_sqlcode_dummy);

    ----------------------------------------------------------------------------
    -- Utility function for printing booleans
    ----------------------------------------------------------------------------
    function to_string(in_boolean in boolean) return varchar2 is
    begin
        return case when in_boolean then 'true' else 'false' end;
    end to_string;

    ----------------------------------------------------------------------------
    -- Always raises and captures FOO error
    ----------------------------------------------------------------------------
    procedure foo(io_collector in out nocopy elox_types.error_collector) is
    begin
        raise_application_error(co_sqlcode_foo, 'Simulated error in FOO');
    exception
        when e_foo then
            io_collector.capture_exception;
    end foo;

    ----------------------------------------------------------------------------
    -- Conditionally raises and captures BAR error
    ----------------------------------------------------------------------------
    procedure bar(in_val in number, io_collector in out nocopy elox_types.error_collector) is
    begin
        if in_val = 2 then
            raise_application_error(co_sqlcode_bar, 'BAR failed on input value 2');
        end if;
    exception
        when e_bar then
            io_collector.capture_exception;
    end bar;

    ----------------------------------------------------------------------------
    -- Returns independent error collector (e.g. from utility task)
    ----------------------------------------------------------------------------
    function simulate_independent_check return elox_types.error_collector is
        l_collector elox_types.error_collector;
    begin
        l_collector := elox.new_collector;
        l_collector.add_error(
            code    => co_sqlcode_foobar,
            message => 'Unexpected FOOBAR error occurred during isolated check');
        return l_collector;
    end simulate_independent_check;

BEGIN
    ----------------------------------------------------------------------------
    -- STEP 1: Init collector
    ----------------------------------------------------------------------------
    error_collector := elox.new_collector;

    ----------------------------------------------------------------------------
    -- STEP 2: Trigger and collect various errors
    ----------------------------------------------------------------------------
    foo(io_collector => error_collector);

    for i in 1 .. 3 loop
        bar(in_val => i, io_collector => error_collector);
    end loop;

    error_collector.add_errors(collector => simulate_independent_check());

    ----------------------------------------------------------------------------
    -- STEP 3: Output summary and contents
    ----------------------------------------------------------------------------
    dbms_output.put_line('Error Collection Summary:');
    dbms_output.put_line(' - Total errors:   ' || error_collector.get_size());
    dbms_output.put_line(' - Any errors?     ' || to_string(error_collector.has_errors));
    dbms_output.put_line(' - Contains FOO?   ' || to_string(error_collector.contains(code => co_sqlcode_foo)));
    dbms_output.put_line(' - Contains BAR?   ' || to_string(error_collector.contains(code => co_sqlcode_bar)));
    dbms_output.put_line(' - Contains FOOBAR?' || to_string(error_collector.contains(code => co_sqlcode_foobar)));
    dbms_output.put_line(' - Contains DUMMY? ' || to_string(error_collector.contains(code => co_sqlcode_dummy)));

    dbms_output.new_line;
    dbms_output.put_line('Error Codes:');
    dbms_output.put_line(' - ' || elox.join_string(error_collector.get_error_codes()));

    dbms_output.new_line;
    dbms_output.put_line('Detailed Error Messages:');
    for i in 1 .. error_collector.get_size loop
        dbms_output.put_line(' - #' || i || ': ' ||
            error_collector.get_error(i).code || ' - ' ||
            error_collector.get_error(i).message);
    end loop;

    dbms_output.new_line;
    dbms_output.put_line('Error Collector as JSON:');
    dbms_output.put_line(error_collector.to_string);

    ----------------------------------------------------------------------------
    -- STEP 4: Interpret and react
    ----------------------------------------------------------------------------
    dbms_output.new_line;
    if not error_collector.has_errors then
        dbms_output.put_line('→ ✅ No issues detected. Proceed normally.');
    elsif error_collector.contains(code => co_sqlcode_foo) then
        dbms_output.put_line('→ ⚠️  Detected FOO issue. Retry or alert operator.');
    elsif error_collector.contains(code => co_sqlcode_bar) then
        dbms_output.put_line('→ ⚠️  Detected BAR failure. Input rejected.');
    else
        dbms_output.put_line('→ ⚠️  Unexpected errors occurred. Manual review advised.');
    end if;

END;
