create or replace type body ot_error as 
    constructor function ot_error(code          number,
                                  message       varchar2,
                                  context       varchar2  default null,
                                  reference_id  varchar2  default null,
                                  error_stack   varchar2  default null,
                                  call_stack    varchar2  default null,
                                  time_stamp    timestamp default systimestamp()) return self as result
    as
    begin 
        self.code           := code;
        self.message        := message;
        self.context        := context;
        self.reference_id   := reference_id;
        self.error_stack    := error_stack;
        self.call_stack     := call_stack;
        self.time_stamp     := time_stamp;
        return;
    end ot_error;

end ot_error;
/