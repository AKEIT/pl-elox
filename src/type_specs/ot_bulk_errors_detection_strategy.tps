create or replace type ot_bulk_errors_detection_strategy authid current_user under ot_error_detection_strategy (
    constructor function ot_bulk_errors_detection_strategy(context in varchar2 default null) return self as result
);
/