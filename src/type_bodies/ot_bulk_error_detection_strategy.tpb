create or replace type body ot_bulk_error_detection_strategy as 
    constructor function ot_bulk_error_detection_strategy(exception_index   in pls_integer,
                                                          context           in varchar2 default null,
                                                          reference_id      in varchar2 default null,
                                                          custom_message    in varchar2 default null) return self as result
    as  
    begin 
        if SQL%BULK_EXCEPTIONS(exception_index).ERROR_CODE >= 0 
        or SQL%BULK_EXCEPTIONS(exception_index).ERROR_CODE is null 
        then 
            self.errors := ct_errors();
        end if;

        self.errors := ct_errors(ot_error(  code          => -SQL%BULK_EXCEPTIONS(exception_index).ERROR_CODE,
                                            message       => coalesce(custom_message, SQLERRM(-SQL%BULK_EXCEPTIONS(exception_index).ERROR_CODE)),
                                            error_stack   => DBMS_UTILITY.FORMAT_ERROR_BACKTRACE , -- todo: add error stack detection
                                            call_stack    => DBMS_UTILITY.FORMAT_CALL_STACK, -- todo: add call stack detection
                                            context       => context,
                                            reference_id  => reference_id,
                                            time_stamp    => systimestamp()));

        return;
    end ot_bulk_error_detection_strategy;

end ot_bulk_error_detection_strategy;
/