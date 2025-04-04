create or replace type body ot_error_collector as

    member procedure capture_exception
    is  
    begin
        self.capture_errors_by(strategy =>  ot_error_detection_strategy());
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

    member procedure add_bulk_error(exception_index in pls_integer,
                                    context         in varchar2 default null,
                                    reference_id    in varchar2 default null,
                                    custom_message  in varchar2 default null) 
    as
    begin 
        self.capture_errors_by(strategy =>  ot_bulk_error_detection_strategy(exception_index   => exception_index,
                                                                             context           => context, 
                                                                             reference_id      => reference_id,
                                                                             custom_message    => custom_message));
    end add_bulk_error;

    member procedure add_bulk_errors(context         in varchar2 default null) 
    as
    begin 
        self.capture_errors_by(strategy =>  ot_bulk_errors_detection_strategy(context           => context));
    end add_bulk_errors;

    member procedure add_dml_error_logs(log_table_name      in varchar2,
                                        error_tag           in varchar2,
                                        reference_id_column in varchar2,
                                        context             in varchar2 default null,
                                        log_table_owner     in varchar2 default null)
    as  
    begin 
        self.capture_errors_by(strategy =>  ot_dml_error_log_detection_strategy(log_table_name      => log_table_name,
                                                                                error_tag           => error_tag,
                                                                                reference_id_column => reference_id_column,
                                                                                context             => context,
                                                                                log_table_owner     => log_table_owner));
    end add_dml_error_logs;

    member procedure add_errors(errors in ct_errors) is
    begin
        <<iterate_errors>>
        for idx in 1 .. errors.count loop
            self.add_error(errors(idx));
        end loop iterate_errors;
    end add_errors;

    member function get_errors return ct_errors is
    begin
        return self.errors;
    end get_errors;

    member function get_error(position in pls_integer) return ot_error is
    begin 
        return self.errors(position);
    end get_error;

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

    member function get_error_codes return sys.odcivarchar2list is
        l_error_codes sys.odcivarchar2list := sys.odcivarchar2list();
    begin
        <<iterate_errors>>
        for idx in 1 .. self.errors.count loop
            l_error_codes.extend;
            l_error_codes(l_error_codes.count) := self.errors(idx).code;
        end loop iterate_errors;
        return l_error_codes;
    end get_error_codes;

    member function get_error_codes_for(context in varchar2) return sys.odcivarchar2list is
        l_error_codes sys.odcivarchar2list := sys.odcivarchar2list();
    begin
        <<iterate_errors>>
        for idx in 1 .. self.errors.count loop
            if self.errors(idx).context = context then
                l_error_codes.extend;
                l_error_codes(l_error_codes.count) := self.errors(idx).code;
            end if;
        end loop iterate_errors;
        return l_error_codes;
    end get_error_codes_for;

    member function get_error_codes_for(context in varchar2, reference_id in varchar2) return sys.odcivarchar2list is
        l_error_codes sys.odcivarchar2list := sys.odcivarchar2list();
    begin
        <<iterate_errors>>
        for idx in 1 .. self.errors.count loop
            if  self.errors(idx).context        = context 
            and self.errors(idx).reference_id   = reference_id
            then
                l_error_codes.extend;
                l_error_codes(l_error_codes.count) := self.errors(idx).code;
            end if;
        end loop iterate_errors;
        return l_error_codes;
    end get_error_codes_for;

    member function get_errors_for(code in number) return ct_errors is
        l_filtered_errors ct_errors := ct_errors();
    begin
        <<iterate_errors>>
        for idx in 1 .. self.errors.count loop
            if self.errors(idx).code = code then
                l_filtered_errors.extend;
                l_filtered_errors(l_filtered_errors.count) := self.errors(idx);
            end if;
        end loop iterate_errors;
        return l_filtered_errors;
    end get_errors_for;

    member function get_errors_for(context in varchar2, code in number) return ct_errors is
        l_filtered_errors ct_errors := ct_errors();
    begin
        <<iterate_errors>>
        for idx in 1 .. self.errors.count loop
            if  self.errors(idx).context = context
            and self.errors(idx).code    = code 
            then
                l_filtered_errors.extend;
                l_filtered_errors(l_filtered_errors.count) := self.errors(idx);
            end if;
        end loop iterate_errors;
        return l_filtered_errors;
    end get_errors_for;

    member function get_errors_for(reference_id in varchar2) return ct_errors is
        l_filtered_errors ct_errors := ct_errors();
    begin
        <<iterate_errors>>
        for idx in 1 .. self.errors.count loop
            if self.errors(idx).reference_id = reference_id then
                l_filtered_errors.extend;
                l_filtered_errors(l_filtered_errors.count) := self.errors(idx);
            end if;
        end loop iterate_errors;
        return l_filtered_errors;
    end get_errors_for;

    member function get_errors_for(context in varchar2, reference_id in varchar2) return ct_errors is
        l_filtered_errors ct_errors := ct_errors();
    begin
        <<iterate_errors>>
        for idx in 1 .. self.errors.count loop
            if  self.errors(idx).context        = context
            and self.errors(idx).reference_id   = reference_id 
            then
                l_filtered_errors.extend;
                l_filtered_errors(l_filtered_errors.count) := self.errors(idx);
            end if;
        end loop iterate_errors;
        return l_filtered_errors;
    end get_errors_for;

    member procedure clear is
    begin
        self.errors.delete;
    end clear;

    member function to_string return clob as
    begin 
        return json_serialize(json(self.errors)); --todo: abwärtskompatibel machen
    end to_string;
    
    constructor function ot_error_collector return self as result is
    begin
        self.errors := ct_errors();
        return;
    end ot_error_collector;

end ot_error_collector;
/