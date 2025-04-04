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
   
end elox;
/