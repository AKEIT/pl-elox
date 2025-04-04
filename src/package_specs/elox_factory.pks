create or replace package elox_factory authid current_user as 

   function create_error_collector return elox_types.error_collector;

end elox_factory;
/