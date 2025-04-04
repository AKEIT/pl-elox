create or replace package body elox_factory as 

    function create_error_collector return elox_types.error_collector as
    begin 
        return ot_error_collector();
    end create_error_collector;

end elox_factory;
/