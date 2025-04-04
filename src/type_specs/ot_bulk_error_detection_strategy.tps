create or replace type ot_bulk_error_detection_strategy authid current_user under ot_error_detection_strategy (
    constructor function ot_bulk_error_detection_strategy(exception_index   in pls_integer,
                                                          context           in varchar2 default null,
                                                          reference_id      in varchar2 default null,
                                                          custom_message    in varchar2 default null) return self as result
);
/