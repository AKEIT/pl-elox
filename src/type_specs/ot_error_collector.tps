create or replace type ot_error_collector authid current_user as object (
    errors ct_errors,

    member procedure capture_exception(context        in varchar2 default null,
                                       reference_id   in varchar2 default null),
    member procedure capture_errors_by(strategy in ot_error_detection_strategy),
    member procedure add_error(error in ot_error),
    member procedure add_errors(errors in ct_errors),
    member procedure add_errors(collector in ot_error_collector),
    member procedure add_error( code          in number,
                                message       in varchar2,
                                error_stack   in varchar2 default null,
                                call_stack    in varchar2 default null,
                                context       in varchar2 default null,
                                reference_id  in varchar2 default null),

    member function get_size return number,

    member function has_errors                                                              return boolean,
    member function contains(code           in number)                                      return boolean,
    member function contains(context        in varchar2)                                    return boolean,
    member function contains(reference_id   in varchar2)                                    return boolean,

    member function contains(context in varchar2, code          in number)                  return boolean,
    member function contains(context in varchar2, reference_id  in varchar2)                return boolean,

    member function contains(reference_id in varchar2, code in number)                      return boolean,

    member function contains(context in varchar2, reference_id in varchar2, code in number) return boolean,


    member function get_error_codes                                                                 return ct_error_codes,
    member function get_error_codes_for(context in varchar2)                                        return ct_error_codes,
    member function get_error_codes_for(context in varchar2, reference_id in varchar2)              return ct_error_codes,

    member function filter(code         in number)                                          return ot_error_collector,
    member function filter(context      in varchar2)                                        return ot_error_collector,
    member function filter(reference_id in varchar2)                                        return ot_error_collector,
    
    member function filter(context in varchar2, code            in number)                  return ot_error_collector,
    member function filter(context in varchar2, reference_id    in varchar2)                return ot_error_collector,

    member function filter(reference_id in varchar2, code in varchar2)                      return ot_error_collector,
    member function filter(context in varchar2, reference_id in varchar2, code in number)   return ot_error_collector,

    member function get_error(position in pls_integer)                                              return ot_error,
    member function get_errors                                                                      return ct_errors,
    member function get_errors_for(code         in number)                                          return ct_errors,
    member function get_errors_for(context      in varchar2)                                        return ct_errors,
    member function get_errors_for(reference_id in varchar2)                                        return ct_errors,
    
    member function get_errors_for(context in varchar2, code            in number)                  return ct_errors,
    member function get_errors_for(context in varchar2, reference_id    in varchar2)                return ct_errors,

    member function get_errors_for(reference_id in varchar2, code in varchar2)                      return ct_errors,
    member function get_errors_for(context in varchar2, reference_id in varchar2, code in number)   return ct_errors,

    member function get_contexts                                                                    return ct_error_contexts,

    member procedure clear,

    member function to_json return json_array_t,
    member function to_string return clob,

    constructor function ot_error_collector return self as result
);
/