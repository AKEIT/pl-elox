create or replace type ot_dml_error_log_detection_strategy authid current_user under ot_error_detection_strategy (
    constructor function ot_dml_error_log_detection_strategy(log_table_name      in varchar2,
                                                             error_tag           in varchar2,
                                                             reference_id_column in varchar2,
                                                             context             in varchar2 default null,
                                                             log_table_owner     in varchar2 default null) return self as result
);
/