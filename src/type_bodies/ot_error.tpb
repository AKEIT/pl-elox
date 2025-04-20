create or replace type body ot_error as 

    member function to_json return json_object_t
    as  l_result         json_object_t;
    begin
        l_result        := json_object_t();
        
        l_result.put('code',            self.code);
        l_result.put('message',         self.message);
        l_result.put('context',         self.context);
        l_result.put('reference_id',    self.reference_id);
        l_result.put('error_stack',     self.error_stack);
        l_result.put('call_stack',      self.call_stack);
        l_result.put('time_stamp',      self.time_stamp);

        return l_result;
    end to_json;

    member function to_string return clob 
    as 
    begin 
        return self.to_json().to_clob();
    end to_string;

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