create or replace type ot_error_detection_strategy authid current_user as object (
    errors ct_errors,
    member function get_detected_errors return ct_errors,
    constructor function ot_error_detection_strategy(context        in varchar2 default null,
                                                     reference_id   in varchar2 default null) return self as result
) not final;
/