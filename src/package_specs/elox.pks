create or replace package elox authid current_user as 

   

   function is_userdefined_exception (
      in_sqlcode in pls_integer default sqlcode
   ) return boolean;

   function is_system_exception(
    in_sqlcode in pls_integer default sqlcode
   ) return boolean;

   function is_constraint_exception(
        in_sqlcode in pls_integer default sqlcode
   ) return boolean;

   function is_generic_error_message(
        in_sqlcode in pls_integer default sqlcode,
        in_sqlerrm in varchar2    default sqlerrm
   ) return boolean;

   --todo: hier weitere Exceptions machen um zu prüfen ob ein konkreter Constraint verletzt wurde

   function detect_bulk_error(in_exception_index in pls_integer,
                              in_context         in varchar2 default null,
                              in_reference_id    in varchar2 default null,
                              in_custom_message  in varchar2 default null) return ot_error_detection_strategy;

   function detect_bulk_errors(in_context        in varchar2 default null) return ot_error_detection_strategy;

   function detect_dml_errrors(in_log_table_name      in varchar2,
                               in_error_tag           in varchar2,
                               in_reference_id_column in varchar2,
                               in_context             in varchar2 default null,
                               in_log_table_owner     in varchar2 default null) return ot_error_detection_strategy;

end elox;
/