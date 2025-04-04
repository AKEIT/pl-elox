create or replace package elox_exceptions authid current_user as

-- ORA-00001: Unique constraint violated
   sqlcode_unique_constraint constant pls_integer := -1;
   unique_constraint exception;
   pragma exception_init ( unique_constraint,
   sqlcode_unique_constraint );

-- ORA-01400: cannot insert NULL into (...)
   sqlcode_not_null_violation constant pls_integer := -1400;
   not_null_violation exception;
   pragma exception_init ( not_null_violation,
   sqlcode_not_null_violation );

-- ORA-02291: integrity constraint violated - parent key not found
   sqlcode_fk_violation_parent constant pls_integer := -2291;
   fk_violation_parent exception;
   pragma exception_init ( fk_violation_parent,
   sqlcode_fk_violation_parent );

-- ORA-02292: integrity constraint violated - child record found
   sqlcode_fk_violation_child constant pls_integer := -2292;
   fk_violation_child exception;
   pragma exception_init ( fk_violation_child,
   sqlcode_fk_violation_child );

-- ORA-00942: table or view does not exist
   sqlcode_table_or_view_missing constant pls_integer := -942;
   table_or_view_missing exception;
   pragma exception_init ( table_or_view_missing,
   sqlcode_table_or_view_missing );

-- ORA-00054: resource busy and acquire with NOWAIT specified or timeout expired
   sqlcode_resource_busy constant pls_integer := -54;
   resource_busy exception;
   pragma exception_init ( resource_busy,
   sqlcode_resource_busy );

-- ORA-00060: deadlock detected while waiting for resource
   sqlcode_deadlock_detected constant pls_integer := -60;
   deadlock_detected exception;
   pragma exception_init ( deadlock_detected,
   sqlcode_deadlock_detected );

-- ORA-02290: check constraint violated
   sqlcode_check_constraint constant pls_integer := -2290;
   check_constraint exception;
   pragma exception_init ( check_constraint,
   sqlcode_check_constraint );

-- ORA-01438: value larger than specified precision allowed for this column
   sqlcode_value_too_large constant pls_integer := -1438;
   value_too_large exception;
   pragma exception_init ( value_too_large,
   sqlcode_value_too_large );

-- ORA-01476: divisor is equal to zero
   sqlcode_divide_by_zero constant pls_integer := -1476;
   divide_by_zero exception;
   pragma exception_init ( divide_by_zero,
   sqlcode_divide_by_zero );

-- ORA-06502: PL/SQL: numeric or value error
   sqlcode_numeric_or_value_error constant pls_integer := -6502;
   numeric_or_value_error exception;
   pragma exception_init ( numeric_or_value_error,
   sqlcode_numeric_or_value_error );

-- ORA-06512: at line... (backtrace only)
   sqlcode_plsql_stack_marker constant pls_integer := -6512;
   plsql_stack_marker exception;
   pragma exception_init ( plsql_stack_marker,
   sqlcode_plsql_stack_marker );

-- ORA-04091: table is mutating, trigger/function may not see it
   sqlcode_table_mutating constant pls_integer := -4091;
   table_mutating exception;
   pragma exception_init ( table_mutating,
   sqlcode_table_mutating );

-- ORA-04092: mutating table error during constraint check
   sqlcode_table_mutating_constraint constant pls_integer := -4092;
   table_mutating_constraint exception;
   pragma exception_init ( table_mutating_constraint,
   sqlcode_table_mutating_constraint );

-- ORA-00904: invalid identifier
   sqlcode_invalid_identifier constant pls_integer := -904;
   invalid_identifier exception;
   pragma exception_init ( invalid_identifier,
   sqlcode_invalid_identifier );

-- ORA-00936: missing expression
   sqlcode_missing_expression constant pls_integer := -936;
   missing_expression exception;
   pragma exception_init ( missing_expression,
   sqlcode_missing_expression );

-- ORA-00933: SQL command not properly ended
   sqlcode_sql_command_not_ended constant pls_integer := -933;
   sql_command_not_ended exception;
   pragma exception_init ( sql_command_not_ended,
   sqlcode_sql_command_not_ended );

-- ORA-01031: insufficient privileges
   sqlcode_insufficient_privileges constant pls_integer := -1031;
   insufficient_privileges exception;
   pragma exception_init ( insufficient_privileges,
   sqlcode_insufficient_privileges );

-- ORA-01017: invalid username/password; logon denied
   sqlcode_invalid_logon constant pls_integer := -1017;
   invalid_logon exception;
   pragma exception_init ( invalid_logon,
   sqlcode_invalid_logon );


-- ORA-24381: error(s) in array DML
   sqlcode_array_dml_error constant pls_integer := -24381;
   array_dml_error exception;
   pragma exception_init ( array_dml_error,
   sqlcode_array_dml_error );
end elox_exceptions;
/