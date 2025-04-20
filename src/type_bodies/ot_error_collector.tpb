create or replace type body ot_error_collector as

    member procedure capture_exception(context        in varchar2 default null,
                                       reference_id   in varchar2 default null)
    is  
    begin
        self.capture_errors_by(strategy =>  ot_error_detection_strategy(context => context,
                                                                        reference_id => reference_id));
    end capture_exception;

    member procedure capture_errors_by(strategy in ot_error_detection_strategy) 
    is  
    begin
        self.add_errors(errors => strategy.get_detected_errors());
    end capture_errors_by;

    member procedure add_error(error in ot_error) is
    begin
        self.errors.extend;
        self.errors(self.errors.count) := error;
    end add_error;

    member procedure add_errors(errors in ct_errors) is
    begin
        <<iterate_errors>>
        for idx in 1 .. errors.count loop
            self.add_error(error => errors(idx));
        end loop iterate_errors;
    end add_errors;

    member procedure add_errors(collector in ot_error_collector) is
    begin
        self.add_errors(errors => collector.get_errors());
    end add_errors;

    member procedure add_error( code          in number,
                                message       in varchar2,
                                error_stack   in varchar2 default null,
                                call_stack    in varchar2 default null,
                                context       in varchar2 default null,
                                reference_id  in varchar2 default null) 
    as
    begin 
        self.add_error(error => ot_error(code            => code,
                                         message         => message,
                                         error_stack     => error_stack,
                                         call_stack      => call_stack,
                                         context         => context,
                                         reference_id    => reference_id));
    end add_error;

    member function get_size return number is
    begin
        return self.errors.count;
    end get_size;

    member function has_errors return boolean is
    begin
        return self.errors.count > 0;
    end has_errors;

    member function contains(code in number) return boolean 
    is  l_entry_found boolean;
    begin
        l_entry_found := false;
        <<iterate_errors>>
        for idx in 1 .. self.errors.count loop
            if self.errors(idx).code = code then
                l_entry_found := true;
                exit iterate_errors when l_entry_found;
            end if;
        end loop iterate_errors;
        return l_entry_found;
    end contains;

    member function contains(context in varchar2) return boolean 
    is  l_entry_found boolean;
    begin
        l_entry_found := false;
        <<iterate_errors>>
        for idx in 1 .. self.errors.count loop
            if self.errors(idx).context = context then
                l_entry_found := true;
                exit iterate_errors when l_entry_found;
            end if;
        end loop iterate_errors;
        return l_entry_found;
    end contains;

    member function contains(reference_id in varchar2) return boolean 
    is  l_entry_found boolean;
    begin
        l_entry_found := false;
        <<iterate_errors>>
        for idx in 1 .. self.errors.count loop
            if self.errors(idx).reference_id = reference_id then
                l_entry_found := true;
                exit iterate_errors when l_entry_found;
            end if;
        end loop iterate_errors;
        return l_entry_found;
    end contains;

    member function contains(context in varchar2, code in number) return boolean 
    is  l_entry_found boolean;
    begin
        l_entry_found := false;
        <<iterate_errors>>
        for idx in 1 .. self.errors.count loop
            if  self.errors(idx).code    = code 
            and self.errors(idx).context = context 
            then
                l_entry_found := true;
                exit iterate_errors when l_entry_found;
            end if;
        end loop iterate_errors;
        return l_entry_found;
    end contains;

    member function contains(context in varchar2, reference_id in varchar2) return boolean 
    is  l_entry_found boolean;
    begin
        l_entry_found := false;
        <<iterate_errors>>
        for idx in 1 .. self.errors.count loop
            if  self.errors(idx).reference_id   = reference_id 
            and self.errors(idx).context        = context 
            then
                l_entry_found := true;
                exit iterate_errors when l_entry_found;
            end if;
        end loop iterate_errors;
        return l_entry_found;
    end contains;

    member function contains(reference_id in varchar2, code in number) return boolean 
    is  l_entry_found boolean;
    begin 
        l_entry_found := false;
        <<iterate_errors>>
        for idx in 1 .. self.errors.count loop
            if  self.errors(idx).reference_id = reference_id
            and self.errors(idx).code         = code
            then
                l_entry_found := true;
                exit iterate_errors when l_entry_found;
            end if;
        end loop iterate_errors;
        return l_entry_found;
    end contains;

    member function contains(context in varchar2, reference_id in varchar2, code in number) return boolean 
    is  l_entry_found boolean;
    begin 
        l_entry_found := false;
        <<iterate_errors>>
        for idx in 1 .. self.errors.count loop
            if  self.errors(idx).context      = context
            and self.errors(idx).reference_id = reference_id
            and self.errors(idx).code         = code
            then
                l_entry_found := true;
                exit iterate_errors when l_entry_found;
            end if;
        end loop iterate_errors;
        return l_entry_found;
    end contains;

    member function get_error_codes return ct_error_codes is
        l_error_codes ct_error_codes := ct_error_codes();
    begin
        <<iterate_errors>>
        for idx in 1 .. self.errors.count loop
            l_error_codes.extend;
            l_error_codes(l_error_codes.count) := self.errors(idx).code;
        end loop iterate_errors;
        return l_error_codes;
    end get_error_codes;

    member function get_error_codes_for(context in varchar2) return ct_error_codes is
    begin
       return self.filter(context => context).get_error_codes();
    end get_error_codes_for;

    member function get_error_codes_for(context in varchar2, reference_id in varchar2) return ct_error_codes is
    begin
       return self.filter(context => context,reference_id => reference_id).get_error_codes();
    end get_error_codes_for;

    member function filter(code         in number)                                          return ot_error_collector is
        error_collector ot_error_collector;
    begin
        error_collector := ot_error_collector();
        <<iterate_errors>>
        for idx in 1 .. self.errors.count loop
            if self.errors(idx).code = code then
                error_collector.add_error(error => self.errors(idx));
            end if;
        end loop iterate_errors;
        return error_collector;
    end filter;

    member function filter(context      in varchar2)                                        return ot_error_collector is
        error_collector ot_error_collector;
    begin
        error_collector := ot_error_collector();
        <<iterate_errors>>
        for idx in 1 .. self.errors.count loop
            if self.errors(idx).context = context then
                error_collector.add_error(error => self.errors(idx));
            end if;
        end loop iterate_errors;
        return error_collector;
    end filter;

    member function filter(reference_id in varchar2)                                        return ot_error_collector  is
        error_collector ot_error_collector;
    begin
        error_collector := ot_error_collector();
        <<iterate_errors>>
        for idx in 1 .. self.errors.count loop
            if self.errors(idx).reference_id = reference_id then
                error_collector.add_error(error => self.errors(idx));
            end if;
        end loop iterate_errors;
        return error_collector;
    end filter;
    
    member function filter(context in varchar2, code            in number)                  return ot_error_collector is
        error_collector ot_error_collector;
    begin
        error_collector := ot_error_collector();
        <<iterate_errors>>
        for idx in 1 .. self.errors.count loop
            if self.errors(idx).context = context
            and self.errors(idx).code = code
            then
                error_collector.add_error(error => self.errors(idx));
            end if;
        end loop iterate_errors;
        return error_collector;
    end filter;

    member function filter(context in varchar2, reference_id    in varchar2)                return ot_error_collector is
        error_collector ot_error_collector;
    begin
        error_collector := ot_error_collector();
        <<iterate_errors>>
        for idx in 1 .. self.errors.count loop
            if self.errors(idx).context = context
            and self.errors(idx).reference_id = reference_id
            then
                error_collector.add_error(error => self.errors(idx));
            end if;
        end loop iterate_errors;
        return error_collector;
    end filter;

    member function filter(reference_id in varchar2, code in varchar2)                      return ot_error_collector is
        error_collector ot_error_collector;
    begin
        error_collector := ot_error_collector();
        <<iterate_errors>>
        for idx in 1 .. self.errors.count loop
            if self.errors(idx).reference_id = reference_id
            and self.errors(idx).code = code
            then
                error_collector.add_error(error => self.errors(idx));
            end if;
        end loop iterate_errors;
        return error_collector;
    end filter;

    member function filter(context in varchar2, reference_id in varchar2, code in number)   return ot_error_collector is
        error_collector ot_error_collector;
    begin
        error_collector := ot_error_collector();
        <<iterate_errors>>
        for idx in 1 .. self.errors.count loop
            if  self.errors(idx).context        = context
            and self.errors(idx).reference_id   = reference_id
            and self.errors(idx).code           = code
            then
                error_collector.add_error(error => self.errors(idx));
            end if;
        end loop iterate_errors;
        return error_collector;
    end filter;

    member function get_error(position in pls_integer) return ot_error is
    begin 
        return self.errors(position);
    end get_error;

    member function get_errors return ct_errors is
    begin
        return self.errors;
    end get_errors;

    member function get_errors_for(code in number) return ct_errors is
    begin
        return self.filter(code => code).get_errors();
    end get_errors_for;

    member function get_errors_for(context in varchar2) return ct_errors is
    begin
        return self.filter(context => context).get_errors();
    end get_errors_for;

    member function get_errors_for(reference_id in varchar2) return ct_errors is
    begin
        return self.filter(reference_id => reference_id).get_errors();
    end get_errors_for;

    member function get_errors_for(context in varchar2, code in number) return ct_errors is
    begin
        return self.filter(context => context, code => code).get_errors();
    end get_errors_for;

    member function get_errors_for(context in varchar2, reference_id in varchar2) return ct_errors is
    begin
        return self.filter(context => context, reference_id => reference_id).get_errors();
    end get_errors_for;

    member function get_errors_for(reference_id in varchar2, code in varchar2) return ct_errors is
    begin
        return self.filter(reference_id => reference_id, code => code).get_errors();
    end get_errors_for;
    
    member function get_errors_for(context in varchar2, reference_id in varchar2, code in number)   return ct_errors  is
    begin
        return self.filter(context => context, reference_id => reference_id, code => code).get_errors();
    end get_errors_for;

    member function get_contexts                                                                    return ct_error_contexts 
    is  t_contexts ct_error_contexts;
    begin 
        t_contexts := ct_error_contexts();
        <<extract_contexts_of_errors>>
        for idx in 1..self.errors.count loop
            t_contexts.extend();
            t_contexts(t_contexts.count) := self.errors(idx).context;
        end loop extract_contexts_of_errors;
        return set(t_contexts);
    end get_contexts;

    member procedure clear is
    begin
        self.errors.delete;
    end clear;

    member function to_json return json_array_t as 
        t_json_array json_array_t;
    begin
        t_json_array := json_array_t();
        <<iterate_errors>>
        for idx in 1 .. self.errors.count loop
            t_json_array.append(self.errors(idx).to_json());
        end loop iterate_errors;
        return t_json_array;
    end to_json;

    member function to_string return clob as
    begin 
        return self.to_json().to_clob();
    end to_string;
    
    constructor function ot_error_collector return self as result is
    begin
        self.errors := ct_errors();
        return;
    end ot_error_collector;

end ot_error_collector;
/