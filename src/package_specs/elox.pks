create or replace package elox authid current_user as
   subtype delimiter_type is varchar2(5 char);
   co_default_value_delimiter constant delimiter_type := ':';
   co_default_attribute_delimiter constant delimiter_type := ',';
   function new_collector return elox_types.error_collector;

   function is_userdefined_exception (
      in_sqlcode in pls_integer default sqlcode
   ) return boolean;

   function is_system_exception (
      in_sqlcode in pls_integer default sqlcode
   ) return boolean;

   function is_constraint_exception (
      in_sqlcode in pls_integer default sqlcode
   ) return boolean;

   function is_generic_error_message (
      in_sqlcode in pls_integer default sqlcode,
      in_sqlerrm in varchar2 default sqlerrm
   ) return boolean;

   --todo: hier weitere Exceptions machen um zu prüfen ob ein konkreter Constraint verletzt wurde

   function join_string (
      in_errors              in ct_errors,
      in_error_delimiter     in delimiter_type default co_default_value_delimiter,
      in_attribute_delimiter in delimiter_type default co_default_attribute_delimiter,
      in_show_context        in boolean default false,
      in_show_reference_id   in boolean default false,
      in_show_code           in boolean default false,
      in_show_message        in boolean default true
   ) return clob;
   
   function join_string (
      in_collector           in ot_error_collector,
      in_error_delimiter     in delimiter_type default co_default_value_delimiter,
      in_attribute_delimiter in delimiter_type default co_default_attribute_delimiter,
      in_show_context        in boolean default false,
      in_show_reference_id   in boolean default false,
      in_show_code           in boolean default false,
      in_show_message        in boolean default true
   ) return clob;

   function join_string (
      in_error_codes in ct_error_codes,
      in_delimiter   in delimiter_type default co_default_value_delimiter
   ) return clob;

   function join_string (
      in_error_contexts in ct_error_contexts,
      in_delimiter      in delimiter_type default co_default_value_delimiter
   ) return clob;

   function detect_bulk_error (
      in_exception_index in pls_integer,
      in_context         in varchar2 default null,
      in_reference_id    in varchar2 default null,
      in_custom_message  in varchar2 default null
   ) return ot_error_detection_strategy;

   function detect_bulk_errors (
      in_context in varchar2 default null
   ) return ot_error_detection_strategy;

   function detect_dml_errrors (
      in_log_table_name      in varchar2,
      in_error_tag           in varchar2,
      in_reference_id_column in varchar2,
      in_context             in varchar2 default null,
      in_log_table_owner     in varchar2 default null
   ) return ot_error_detection_strategy;

   function bulk_error_code_at(in_index in pls_integer) return pls_integer;
   function bulk_error_index_at(in_index in pls_integer) return pls_integer;

end elox;
/