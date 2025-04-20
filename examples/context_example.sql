DECLARE

    ----------------------------------------------------------------------------
    -- Example Use Case: Vehicle Validation with Error Collection using ELOX
    ----------------------------------------------------------------------------
    -- This PL/SQL script demonstrates how to validate structured data 
    -- (in this case: a car object) using the ELOX framework for error collection.
    --
    -- Each car consists of:
    --   - a VIN (vehicle ID)
    --   - one engine (mandatory, must be of an allowed type)
    --   - one steering wheel (mandatory, must be valid)
    --   - four tires (must match specific positions exactly once)
    --
    -- Instead of aborting on the first error, the script collects all validation 
    -- issues into a centralized error collector (`elox_types.error_collector`).
    --
    -- This is especially useful in database applications such as:
    --   - complex data migrations or ETL jobs
    --   - post-import validations
    --   - UI form validations with deferred feedback
    --   - auditing scenarios where complete issue tracking is required
    ----------------------------------------------------------------------------

    ----------------------------------------------------------------------------
    -- SECTION: CONSTANTS
    ----------------------------------------------------------------------------

    -- Valid engine types
    co_engine_petrol     constant varchar2(10) := 'PETROL';
    co_engine_diesel     constant varchar2(10) := 'DIESEL';
    co_engine_invalid    constant varchar2(10) := 'ATOMIC';

    -- Valid steering types
    co_steering_comfort  constant varchar2(10) := 'Comfort';
    co_steering_racing   constant varchar2(10) := 'Racing';
    co_steering_sport    constant varchar2(10) := 'Sport';
    co_steering_invalid  constant varchar2(10) := 'Joystick';

    -- Tire positions
    co_tire_front_left constant varchar2(2) := 'FL';
    co_tire_front_right constant varchar2(2) := 'FR';
    co_tire_rear_left constant varchar2(2) := 'RL';
    co_tire_rear_right constant varchar2(2) := 'RR';

    -- Contexts
    co_context_engine    constant varchar2(20) := 'ENGINE';
    co_context_steering  constant varchar2(20) := 'STEERING';
    co_context_tires     constant varchar2(20) := 'TIRES';

    -- Error codes
    co_sqlcode_invalid_engine         constant pls_integer := -20001;
    co_sqlcode_missing_engine         constant pls_integer := -20003;
    co_sqlcode_invalid_steering       constant pls_integer := -20010;
    co_sqlcode_missing_steering       constant pls_integer := -20012;
    co_sqlcode_duplicate_tire_position constant pls_integer := -20021;
    co_sqlcode_missing_tire_position   constant pls_integer := -20022;

    -- Exception mapping
    e_missing_engine exception;
    e_invalid_engine exception;
    pragma exception_init(e_missing_engine, co_sqlcode_missing_engine);
    pragma exception_init(e_invalid_engine, co_sqlcode_invalid_engine);

    ----------------------------------------------------------------------------
    -- SECTION: TYPES
    ----------------------------------------------------------------------------

    type r_tire_type is record (position varchar2(2));
    type t_tires_type is table of r_tire_type;
    type r_car_type is record (
        vin      varchar2(17 char), -- 17-character vehicle identification number
        engine   varchar2(10),
        steering varchar2(10),
        tires    t_tires_type
    );

    ----------------------------------------------------------------------------
    -- SECTION: VARIABLES
    ----------------------------------------------------------------------------

    r_car r_car_type;

    ----------------------------------------------------------------------------
    -- SECTION: UTILITY FUNCTIONS
    ----------------------------------------------------------------------------

    -- Utility function: convert BOOLEAN to VARCHAR2 for readable output
    function to_string(in_boolean in boolean) return varchar2 is
    begin
        return case when in_boolean then 'true' else 'false' end;
    end to_string;

    ----------------------------------------------------------------------------
    -- Helper: Adds a specific error to the collector based on an element count.
    --
    -- This procedure is used internally by the validation logic to check whether 
    -- a given position or identifier is:
    --   - missing (count = 0),
    --   - correctly assigned (count = 1),
    --   - or duplicated (count > 1).
    --
    -- It appends the corresponding error entry to the error collector, using 
    -- context = 'TIRES' and reference_id = <position>. 
    -- (In other validation contexts, similar logic can be reused.)
    --
    -- Possible real-world causes for such count-based errors:
    --   - Data imports or synchronization processes introducing incomplete datasets
    --   - Incorrect merging or deduplication of records
    --   - Faulty input validation in frontend or backend systems
    --   - Logical errors during transformation or mapping of entity structures
    ----------------------------------------------------------------------------
    procedure detect_tire_error_by(
        io_collector in out nocopy ot_error_collector,
        in_position  in varchar2,
        in_counter   in pls_integer
    ) is
    begin 
        case in_counter
            when 1 then null;
            when 0 then io_collector.add_error(
                context      => co_context_tires,
                reference_id => in_position,
                code         => co_sqlcode_missing_tire_position,
                message      => 'Missing tire on position ' || in_position);
            else io_collector.add_error(
                context      => co_context_tires,
                reference_id => in_position,
                code         => co_sqlcode_duplicate_tire_position,
                message      => 'Duplicate tire on position ' || in_position);
        end case;
    end detect_tire_error_by;

 ----------------------------------------------------------------------------
    -- SECTION: VALIDATIONS
    ----------------------------------------------------------------------------
    -- The following procedures demonstrate three different ways of 
    -- interacting with the error collector:
    --
    -- 1. Tires: Errors are added directly using `add_error`, based on count logic and by userdefined sqlcode and error message.
    -- 2. Engine: Errors are raised as exceptions and captured using `capture_exception`.
    -- 3. Steering: Errors are added via `add_error`, distinguishing missing vs. invalid values.
    ----------------------------------------------------------------------------

    ----------------------------------------------------------------------------
    -- Validation: Ensures all required tire positions are correctly assigned.
    --
    -- This procedure checks if all expected tire positions (FL, FR, RL, RR)
    -- are present exactly once. For each position, a simple counter is used
    -- to detect missing or duplicate assignments.
    --
    -- Errors are added directly using `add_error`, with:
    --   - context = 'TIRES'
    --   - reference_id = the position (e.g. 'FL')
    --
    -- This is a classic pattern in database development where:
    --   - data imports introduce duplicates or incomplete records
    --   - missing foreign key references or invalid mappings occur
    --   - unique constraints are not enforced at DB level and must be handled in logic
    --
    -- This style of validation is ideal for structural checks where no
    -- exceptions are raised, and issues can be aggregated for reporting.
    ----------------------------------------------------------------------------
    procedure validate_that_car_has_fitting_tires(
        in_car       in r_car_type,
        io_collector in out nocopy ot_error_collector
    ) is
        l_fl pls_integer := 0;
        l_fr pls_integer := 0;
        l_rl pls_integer := 0;
        l_rr pls_integer := 0;
    begin
        for i in 1..in_car.tires.count loop
            case in_car.tires(i).position
                when co_tire_front_left then l_fl := l_fl + 1;
                when co_tire_front_right then l_fr := l_fr + 1;
                when co_tire_rear_left then l_rl := l_rl + 1;
                when co_tire_rear_right then l_rr := l_rr + 1;
            end case;
        end loop;

        detect_tire_error_by(io_collector, co_tire_front_left, l_fl);
        detect_tire_error_by(io_collector, co_tire_front_right, l_fr);
        detect_tire_error_by(io_collector, co_tire_rear_left, l_rl);
        detect_tire_error_by(io_collector, co_tire_rear_right, l_rr);
    end validate_that_car_has_fitting_tires;

    ----------------------------------------------------------------------------
    -- Validation: Ensures the engine is present and valid.
    --
    -- This procedure validates that an engine is assigned and that its type 
    -- matches one of the allowed values. If the engine is missing or not valid, 
    -- a user-defined exception is raised using `raise_application_error`. 
    --
    -- The exception is caught and collected via `capture_exception`, which 
    -- extracts relevant information (SQLCODE, message, error stack) and adds 
    -- it to the collector with:
    --   - context = 'ENGINE'
    --   - reference_id = the invalid engine type (if present)
    --
    -- This type of validation also provides a pattern for collecting 
    -- Oracle-defined exceptions, such as:
    --   - `NO_DATA_FOUND` (e.g. required lookup missing)
    --   - `TOO_MANY_ROWS` (e.g. ambiguous foreign key)
    --   - Constraint violations (e.g. FK/PK/Unique), wrapped via exception handlers
    --
    -- Real-world applications in database development:
    --   - Enforcing mandatory relationships and business rules
    --   - Detecting inconsistencies during migration or ETL
    --   - Centralized error handling in complex PL/SQL processing chains
    --
    -- This approach ensures that exceptions raised at any layer can be 
    -- captured structurally and passed along for auditing, logging, or user feedback.
    ----------------------------------------------------------------------------
    procedure validate_that_car_has_fitting_engine(
        in_car       in r_car_type,
        io_collector in out nocopy ot_error_collector
    ) is
    begin
        if in_car.engine is null then
            raise_application_error(co_sqlcode_missing_engine, 'No engine installed');
        elsif in_car.engine not in (co_engine_petrol, co_engine_diesel) then
            raise_application_error(co_sqlcode_invalid_engine, 'Invalid engine part number');
        end if;
    exception
        when e_missing_engine or e_invalid_engine then
            io_collector.capture_exception(
                context      => co_context_engine,
                reference_id => in_car.engine);
    end validate_that_car_has_fitting_engine;

    ----------------------------------------------------------------------------
    -- Validation: Ensures the steering wheel is present and valid.
    --
    -- This procedure verifies that a steering value exists and matches one
    -- of the allowed types. If the steering is missing or invalid, the error 
    -- is directly added to the collector using `add_error`.
    --
    -- The added error includes:
    --   - context = 'STEERING'
    --   - reference_id = the provided (invalid) steering value
    --
    -- Real-world examples in database systems:
    --   - soft validation of optional attributes (e.g. optional settings or preferences)
    --   - validation of configuration inputs in data import pipelines
    --   - warnings for deprecated or non-standard input values
    --
    -- This style fits well when errors are not critical but should still be 
    -- reported and reviewed collectively after processing.
    ----------------------------------------------------------------------------
    procedure validate_that_car_has_fitting_steering(
        in_car       in r_car_type,
        io_collector in out nocopy ot_error_collector
    ) is
    begin
        if in_car.steering is null then
            io_collector.add_error(
                code    => co_sqlcode_missing_steering,
                message => 'No steering wheel installed',
                context => co_context_steering);
        elsif in_car.steering not in (co_steering_comfort, co_steering_racing, co_steering_sport) then
            io_collector.add_error(
                code         => co_sqlcode_invalid_steering,
                message      => 'Invalid steering type',
                context      => co_context_steering,
                reference_id => in_car.steering);
        end if;
    end validate_that_car_has_fitting_steering;

    ----------------------------------------------------------------------------
    -- SECTION: OUTPUT / ERROR SUMMARY
    ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------
    -- Reporting: Outputs a structured validation report for a given car object.
    --
    -- This procedure demonstrates how to evaluate and report collected errors 
    -- from multiple contexts (ENGINE, TIRES, STEERING) using the ELOX framework.
    --
    -- Purpose:
    --   - Show that validation does not stop at the first error
    --   - Collect and analyze all issues across different domains (contexts)
    --   - React specifically based on which contexts are affected
    --
    -- The report includes:
    --   - An overall processing status (e.g. READY_FOR_SALE, QUARANTINE)
    --   - A component-level quality gate result (Engine, Tires, Steering)
    --   - A recommended action based on error context and type
    --   - A detailed per-component breakdown with error messages and references
    --
    -- This illustrates the key ELOX design goal: defer and structure error
    -- handling instead of stopping at the first failure (fail-safe aggregation).
    --
    -- Real-world applications in database development include:
    --   - Post-import validation of external data feeds (e.g. partner systems)
    --   - Batch processing with rule violations across multiple tables/entities
    --   - Business rule enforcement with full transparency for downstream teams
    --   - Quality assurance for form-based or transactional input (e.g. order systems)
    --
    -- This approach allows you to clearly separate validation, collection, 
    -- decision logic and reporting — a pattern widely applicable in complex 
    -- data processing, integration, and ETL projects.
    ----------------------------------------------------------------------------
    procedure print_report(in_car       in r_car_type,
                           in_collector in elox_types.error_collector) as 
    begin 

        dbms_output.put_line('############ Start report for car with vin <'||in_car.vin||'>');
        dbms_output.put_line('Overall Status: '||case 
                                                    when not in_collector.has_errors 
                                                    then 'READY_FOR_SALE'
                                                    when in_collector.contains(context => co_context_engine) 
                                                    then 'REQUIRES_REASSEMBLY'
                                                    when in_collector.contains(context => co_context_steering)
                                                      or in_collector.contains(context => co_context_tires, code => co_sqlcode_missing_tire_position)
                                                    then 'QUARANTINE'
                                                    else 'AWAITING_REWORK'
                                                end);

        dbms_output.put_line('Quality-Gates:');
        dbms_output.put_line(rpad('  - Engine: '    ,15, ' ')||case when in_collector.contains(context => co_context_engine) then '❌' else '✅' end);
        dbms_output.put_line(rpad('  - Tires: '     ,15, ' ')||case when in_collector.contains(context => co_context_tires)  then '❌' else '✅' end);
        dbms_output.put_line(rpad('  - Steering: '  ,15, ' ')||case when in_collector.contains(context => co_context_steering, code => co_sqlcode_missing_steering) 
                                                                        then '❌' 
                                                                        when in_collector.contains(context => co_context_steering) 
                                                                        then '⚠️'
                                                                        else '✅' 
                                                                end);
        dbms_output.put_line('Action to take: ');
        dbms_output.put_line('    '||case 
                                        when not in_collector.has_errors 
                                        then 'The vehicle is ready for delivery. Move it to the sales preparation area for final inspection and documentation.'
                                        when in_collector.contains(context => co_context_engine) 
                                        then 'The vehicle must be disassembled and returned to the assembly line for a full rebuild of the power unit section.'
                                        when in_collector.contains(context => co_context_steering)
                                            or in_collector.contains(context => co_context_tires, code => co_sqlcode_missing_tire_position)
                                        then 'The vehicle cannot be moved on its own. Use a crane to transport it to a designated exception handling area for further correction.'
                                        else 'Move the vehicle to the rework zone where the steering wheel can be replaced or reassessed for special customer configurations.'
                                    end);

        if not in_collector.has_errors() then 
            return;
        end if;

        dbms_output.new_line();
        dbms_output.put_line('Detailed Report:');
        dbms_output.put(' - ');
        if in_collector.contains(context => co_context_engine) then 
            dbms_output.put_line('Engine assembly failed: '||elox.join_string(in_collector.filter(context => co_context_engine)));
        else
            dbms_output.put_line('Engine assembly completed successfully by fitting <'||in_car.engine||'> engine');
        end if;

        dbms_output.put(' - ');
        if in_collector.contains(context => co_context_steering, code => co_sqlcode_missing_steering) then 
            dbms_output.put_line('Steering assembly failed: '||elox.join_string(in_collector.filter(context => co_context_steering, code => co_sqlcode_missing_steering)));
        elsif in_collector.contains(context => co_context_steering) then 
            dbms_output.put_line('Steering assembly incomplete: '||elox.join_string(in_collector            => in_collector.filter(context => co_context_steering),
                                                                                    in_show_reference_id    => true,
                                                                                    in_attribute_delimiter  => ' is '));
        else
            dbms_output.put_line('Steering assembly completed successfully by fitting <'||in_car.steering||'> steering wheel');
        end if;

        dbms_output.put(' - ');
        if in_collector.contains(context => co_context_tires) then 
            dbms_output.put_line('Tire assembly failed: ');
            dbms_output.put_line('   - Front Left: '    ||nvl(elox.join_string(in_collector.filter(context => co_context_tires, reference_id => co_tire_front_left)),    'Fitted'));
            dbms_output.put_line('   - Front Right: '   ||nvl(elox.join_string(in_collector.filter(context => co_context_tires, reference_id => co_tire_front_right)),   'Fitted'));
            dbms_output.put_line('   - Rear Left: '     ||nvl(elox.join_string(in_collector.filter(context => co_context_tires, reference_id => co_tire_rear_left)),     'Fitted'));
            dbms_output.put_line('   - Rear Right: '    ||nvl(elox.join_string(in_collector.filter(context => co_context_tires, reference_id => co_tire_rear_right)),    'Fitted'));
        else
            dbms_output.put_line('Tire assembly completed successfully by fitting <'||in_car.tires.count||'> tires');
        end if;

        dbms_output.new_line();
    end print_report;

    function validate_car_setup(in_car       in r_car_type)
    return elox_types.error_collector
    as  error_collector elox_types.error_collector;
    begin 

        error_collector := elox.new_collector();
        validate_that_car_has_fitting_tires(in_car => in_car, io_collector => error_collector);
        validate_that_car_has_fitting_engine(in_car => in_car, io_collector => error_collector);
        validate_that_car_has_fitting_steering(in_car => in_car, io_collector => error_collector);

        return error_collector;
    end validate_car_setup;

BEGIN
    ----------------------------------------------------------------------------
    -- SECTION: INPUT + VALIDATION
    ----------------------------------------------------------------------------
    -- Below are four sample cars (r_car), each representing a different type 
    -- of validation scenario:
    --   - ELOX_1: Duplicate tire position + invalid engine
    --   - ELOX_2: Invalid steering wheel type
    --   - ELOX_3: Missing engine, missing tires, invalid steering
    --   - ELOX_4: Passed every test
    --
    -- Each car is passed to the validation logic and the resulting 
    -- error collector is used to generate a detailed processing report.
    --
    -- You may easily expand this by adding further scenarios to test
    -- additional combinations or simulate integration with real data pipelines.
    ----------------------------------------------------------------------------
    r_car := r_car_type(vin      => 'ELOX_1',
                        engine   => co_engine_invalid, -- <-- invalid: Engine has to be petrol or diesel
                        steering => co_steering_comfort,
                        tires    => t_tires_type(
                                        r_tire_type(co_tire_front_left),
                                        r_tire_type(co_tire_front_right),
                                        r_tire_type(co_tire_rear_left),
                                        r_tire_type(co_tire_rear_left))); -- <-- invalid: Duplicate rear left, and missing rear right
    print_report(in_car       => r_car, 
                 in_collector => validate_car_setup(in_car => r_car));

    r_car := r_car_type(vin      => 'ELOX_2',
                        engine   => co_engine_petrol,
                        steering => co_steering_invalid, -- <-- invalid: Steering has to be comfort, sport or racing
                        tires    => t_tires_type(
                                        r_tire_type(co_tire_front_left),
                                        r_tire_type(co_tire_front_right),
                                        r_tire_type(co_tire_rear_left),
                                        r_tire_type(co_tire_rear_right)));

    print_report(in_car       => r_car, 
                 in_collector => validate_car_setup(in_car => r_car));

    r_car := r_car_type(vin      => 'ELOX_3',
                        engine   => null,
                        steering => co_steering_invalid, -- <-- invalid: Steering has to be comfort, sport or racing
                        tires    => t_tires_type());     -- <-- invalid: missing tire on each position

    print_report(in_car       => r_car, 
                 in_collector => validate_car_setup(in_car => r_car));

    r_car := r_car_type(vin      => 'ELOX_4',
                        engine   => co_engine_petrol,
                        steering => co_steering_racing,
                        tires    => t_tires_type(r_tire_type(co_tire_front_left),
                                                 r_tire_type(co_tire_front_right),
                                                 r_tire_type(co_tire_rear_left),
                                                 r_tire_type(co_tire_rear_right)));

    print_report(in_car       => r_car, 
                 in_collector => validate_car_setup(in_car => r_car));

    ----------------------------------------------------------------------------
    -- You could now imagine this logic being wrapped in a loop over a dataset
    -- or fed by an import process. This allows:
    --   - full issue tracing without premature aborts
    --   - conditional routing of objects based on quality status
    --   - simplified integration testing for structural and business validations
    ----------------------------------------------------------------------------
END;