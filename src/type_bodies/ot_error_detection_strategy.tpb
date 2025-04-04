create or replace type body ot_error_detection_strategy as 
    constructor function ot_error_detection_strategy(reference_id in varchar2 default null) return self as result 
    is 
    begin
        self.errors := ct_errors();
        if UTL_CALL_STACK.ERROR_DEPTH > 0 then 
            self.errors.extend();
            self.errors(1) := ot_error(code          => -1 * sys.utl_call_stack.error_number(error_depth => 1),
                                       message       => sys.utl_call_stack.error_msg(error_depth => 1),
                                       error_stack   => DBMS_UTILITY.FORMAT_ERROR_BACKTRACE , -- todo: add error stack detection
                                       call_stack    => DBMS_UTILITY.FORMAT_CALL_STACK, -- todo: add call stack detection
                                       reference_id  => reference_id);
        end if;
        return;
    end ot_error_detection_strategy;

    member function get_detected_errors return ct_errors is
    begin
        return self.errors;
    end get_detected_errors;
end ot_error_detection_strategy;
/