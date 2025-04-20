create or replace package body elox as

   function new_collector return elox_types.error_collector as
   begin
      return ot_error_collector();
   end new_collector;

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

   function is_generic_error_message (
      in_sqlcode in pls_integer default sqlcode,
      in_sqlerrm in varchar2 default sqlerrm
   ) return boolean as
   begin
      return in_sqlerrm = sqlerrm(in_sqlcode);
   end is_generic_error_message;

   function join_string (
      in_errors              in ct_errors,
      in_error_delimiter     in delimiter_type default co_default_value_delimiter,
      in_attribute_delimiter in delimiter_type default co_default_attribute_delimiter,
      in_show_context        in boolean default false,
      in_show_reference_id   in boolean default false,
      in_show_code           in boolean default false,
      in_show_message        in boolean default true
   ) return clob is
      l_errors clob;
   begin
      << iterate_errors >> for i in 1..in_errors.count loop
         if l_errors is not null then
            l_errors := l_errors || in_error_delimiter;
         end if;
         if in_show_context then
            l_errors := l_errors
                        || in_errors(i).context
                        || in_attribute_delimiter;
         end if;

         if in_show_reference_id then
            l_errors := l_errors
                        || in_errors(i).reference_id
                        || in_attribute_delimiter;
         end if;

         if in_show_code then
            l_errors := l_errors
                        || in_errors(i).code
                        || in_attribute_delimiter;
         end if;

         if in_show_message then
            l_errors := l_errors || in_errors(i).message;
         end if;

      end loop iterate_errors;
      return l_errors;
   end join_string;
   
   function join_string (
      in_collector           in ot_error_collector,
      in_error_delimiter     in delimiter_type default co_default_value_delimiter,
      in_attribute_delimiter in delimiter_type default co_default_attribute_delimiter,
      in_show_context        in boolean default false,
      in_show_reference_id   in boolean default false,
      in_show_code           in boolean default false,
      in_show_message        in boolean default true
   ) return clob as 
   begin 
      return join_string (in_errors              => in_collector.get_errors,
                          in_error_delimiter     => in_error_delimiter,
                          in_attribute_delimiter => in_attribute_delimiter,
                          in_show_context        => in_show_context,
                          in_show_reference_id   => in_show_reference_id,
                          in_show_code           => in_show_code,
                          in_show_message        => in_show_message);
   end join_string;

   function join_string (
      in_error_codes in ct_error_codes,
      in_delimiter   in delimiter_type default co_default_value_delimiter
   ) return clob is
      l_codes clob;
      t_codes ct_error_codes;
   begin
      t_codes := set(in_error_codes);
      << iterate_codes >> for i in 1..t_codes.count loop
         if t_codes(i) is null then
            continue iterate_codes;
         end if;
         if l_codes is not null then
            l_codes := l_codes || in_delimiter;
         end if;
         l_codes := l_codes || t_codes(i);
      end loop iterate_codes;
      return l_codes;
   end join_string;

   function join_string (
      in_error_contexts in ct_error_contexts,
      in_delimiter      in delimiter_type default co_default_value_delimiter
   ) return clob is
      l_contexts clob;
   begin
      << iterate_contexts >> 
      for idx in 1..in_error_contexts.count loop
         if l_contexts is not null then
            l_contexts := l_contexts || in_delimiter;
         end if;
         l_contexts := l_contexts || in_error_contexts(idx);
      end loop iterate_contexts;
      return l_contexts;
   end join_string;

   function detect_bulk_error (
      in_exception_index in pls_integer,
      in_context         in varchar2 default null,
      in_reference_id    in varchar2 default null,
      in_custom_message  in varchar2 default null
   ) return ot_error_detection_strategy is
   begin
      return new ot_bulk_error_detection_strategy(
         exception_index => in_exception_index,
         context         => in_context,
         reference_id    => in_reference_id,
         custom_message  => in_custom_message
      );
   end detect_bulk_error;

   function detect_bulk_errors (
      in_context in varchar2 default null
   ) return ot_error_detection_strategy is
   begin
      return new ot_bulk_errors_detection_strategy(context => in_context);
   end detect_bulk_errors;

   function detect_dml_errrors (
      in_log_table_name      in varchar2,
      in_error_tag           in varchar2,
      in_reference_id_column in varchar2,
      in_context             in varchar2 default null,
      in_log_table_owner     in varchar2 default null
   ) return ot_error_detection_strategy is
   begin
      return ot_dml_error_log_detection_strategy(
         log_table_name      => in_log_table_name,
         error_tag           => in_error_tag,
         reference_id_column => in_reference_id_column,
         context             => in_context,
         log_table_owner     => in_log_table_owner
      );
   end detect_dml_errrors;

   function bulk_error_code_at(in_index in pls_integer) return pls_integer as 
   begin 
      return -SQL%BULK_EXCEPTIONS(in_index).ERROR_CODE;
   end bulk_error_code_at;

   function bulk_error_index_at(in_index in pls_integer) return pls_integer as 
   begin 
      return SQL%BULK_EXCEPTIONS(in_index).ERROR_INDEX;
   end bulk_error_index_at;

end elox;
/