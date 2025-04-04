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

end elox;
/