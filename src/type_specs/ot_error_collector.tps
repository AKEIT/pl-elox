create or replace type ot_error_collector authid current_user as object (
    errors ct_errors,

    member procedure capture_exception,
    member procedure capture_errors_by(strategy in ot_error_detection_strategy),
    member procedure add_error(error in ot_error),
    member procedure add_error( code          in number,
                                message       in varchar2,
                                error_stack   in varchar2 default null,
                                call_stack    in varchar2 default null,
                                context       in varchar2 default null,
                                reference_id  in varchar2 default null),
    member procedure add_bulk_error(exception_index in pls_integer,
                                    context         in varchar2 default null,
                                    reference_id    in varchar2 default null,
                                    custom_message  in varchar2 default null),
    member procedure add_bulk_errors(context         in varchar2 default null),
    member procedure add_dml_error_logs(log_table_name      in varchar2,
                                        error_tag           in varchar2,
                                        reference_id_column in varchar2,
                                        context             in varchar2 default null,
                                        log_table_owner     in varchar2 default null),
    member procedure add_errors(errors in ct_errors),
    member function get_errors return ct_errors,
    member function get_error(position in pls_integer) return ot_error,
    member function get_size return number,
    member function has_errors return boolean,

    member function contains(code in number) return boolean,
    member function contains(context in varchar2, code in number) return boolean,
    member function contains(reference_id in varchar2) return boolean,
    member function contains(context in varchar2, reference_id in varchar2) return boolean,

    member function get_error_codes return sys.odcivarchar2list,
    member function get_error_codes_for(context in varchar2) return sys.odcivarchar2list,
    member function get_error_codes_for(context in varchar2, reference_id in varchar2) return sys.odcivarchar2list,

    member function get_errors_for(code in number) return ct_errors,
    member function get_errors_for(context in varchar2, code in number) return ct_errors,
    member function get_errors_for(reference_id in varchar2) return ct_errors,
    member function get_errors_for(context in varchar2, reference_id in varchar2) return ct_errors,

    member procedure clear,

    member function to_string return clob,

    constructor function ot_error_collector return self as result
);
/