create or replace type body ot_bulk_errors_detection_strategy as 
    constructor function ot_bulk_errors_detection_strategy(context in varchar2 default null) return self as result
    as  
    begin 
        self.errors := ct_errors();

        for idx in 1..SQL%BULK_EXCEPTIONS.count loop
            if SQL%BULK_EXCEPTIONS(idx).ERROR_CODE > 0 then 
                self.errors.extend();
                self.errors(self.errors.count) := ot_error( code          => -SQL%BULK_EXCEPTIONS(idx).ERROR_CODE,
                                                            message       => SQLERRM(-SQL%BULK_EXCEPTIONS(idx).ERROR_CODE),
                                                            error_stack   => DBMS_UTILITY.FORMAT_ERROR_BACKTRACE , -- todo: add error stack detection
                                                            call_stack    => DBMS_UTILITY.FORMAT_CALL_STACK, -- todo: add call stack detection
                                                            context       => context,
                                                            reference_id  => SQL%BULK_EXCEPTIONS(idx).error_index,
                                                            time_stamp    => systimestamp());
            end if;
        end loop;
        return;
    end ot_bulk_errors_detection_strategy;

end ot_bulk_errors_detection_strategy;
/