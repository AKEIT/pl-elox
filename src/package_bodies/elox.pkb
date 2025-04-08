create or replace package body elox as

   function is_userdefined_exception (
      in_sqlcode in pls_integer default sqlcode
   ) return boolean is
   begin
      return in_sqlcode between - 20999 and - 20000;
   end is_userdefined_exception;

   function is_system_exception (
      in_sqlcode in pls_integer default sqlcode
   ) return boolean is
   begin
      return not is_userdefined_exception(in_sqlcode => in_sqlcode);
   end is_system_exception;

   function is_constraint_exception (
      in_sqlcode in pls_integer default sqlcode
   ) return boolean is
   begin
      return in_sqlcode in ( elox_exceptions.sqlcode_unique_constraint,
                             elox_exceptions.sqlcode_not_null_violation,
                             elox_exceptions.sqlcode_check_constraint,
                             elox_exceptions.sqlcode_fk_violation_parent,
                             elox_exceptions.sqlcode_fk_violation_child );
   end is_constraint_exception;

   function is_generic_error_message(
        in_sqlcode in pls_integer default sqlcode,
        in_sqlerrm in varchar2    default sqlerrm
   ) return boolean as
   begin 
      return in_sqlerrm = sqlerrm(in_sqlcode);
   end is_generic_error_message;

   function detect_bulk_error(in_exception_index   in pls_integer,
                              in_context           in varchar2 default null,
                              in_reference_id      in varchar2 default null,
                              in_custom_message    in varchar2 default null) return ot_error_detection_strategy 
   is 
   begin
      return new ot_bulk_error_detection_strategy(exception_index   => in_exception_index,
                                                  context           => in_context, 
                                                  reference_id      => in_reference_id,
                                                  custom_message    => in_custom_message);
   end detect_bulk_error;

   function detect_bulk_errors(in_context in varchar2 default null) return ot_error_detection_strategy 
   is 
   begin
      return new ot_bulk_errors_detection_strategy(context => in_context);
   end detect_bulk_errors;
   
   function detect_dml_errrors(in_log_table_name      in varchar2,
                               in_error_tag           in varchar2,
                               in_reference_id_column in varchar2,
                               in_context             in varchar2 default null,
                               in_log_table_owner     in varchar2 default null) return ot_error_detection_strategy
   is 
   begin
      return ot_dml_error_log_detection_strategy(log_table_name      => in_log_table_name,
                                                 error_tag           => in_error_tag,
                                                 reference_id_column => in_reference_id_column,
                                                 context             => in_context,
                                                 log_table_owner     => in_log_table_owner);
   end detect_dml_errrors;
   
end elox;
/