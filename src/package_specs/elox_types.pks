create or replace package elox_types authid current_user as

    subtype error is ot_error;
    subtype errors is ct_errors;
    subtype error_codes is ct_error_codes;
    subtype error_contexts is ct_error_contexts;
    subtype error_collector is ot_error_collector;
    subtype error_detection_strategy is ot_error_detection_strategy;

end elox_types;
/