whenever sqlerror exit failure rollback;
whenever oserror exit failure rollback;

@@type_specs/ct_error_codes.tps
@@type_specs/ct_error_contexts.tps
@@type_specs/ot_error.tps
@@type_specs/ct_errors.tps
@@type_specs/ot_error_detection_strategy.tps
@@type_specs/ot_bulk_error_detection_strategy.tps
@@type_specs/ot_bulk_errors_detection_strategy.tps
@@type_specs/ot_dml_error_log_detection_strategy.tps
@@type_specs/ot_error_collector.tps

@@type_bodies/ot_error.tpb
@@type_bodies/ot_error_detection_strategy.tpb
@@type_bodies/ot_bulk_error_detection_strategy.tpb
@@type_bodies/ot_bulk_errors_detection_strategy.tpb
@@type_bodies/ot_dml_error_log_detection_strategy.tpb
@@type_bodies/ot_error_collector.tpb

@@package_specs/elox_types.pks
@@package_specs/elox_exceptions.pks
@@package_specs/elox.pks
@@package_specs/elox_apex.pks
@@package_specs/ut_error_collector.pks

@@package_bodies/elox.pkb
@@package_bodies/elox_apex.pkb
@@package_bodies/ut_error_collector.pkb

@@views/elox_apex_collections.sql

--todo: check if user wants to grant to publci
@@grants/execute_on_elox_exceptions_to_public.sql
@@grants/execute_on_elox_to_public.sql
@@grants/execute_on_elox_types_to_public.sql

