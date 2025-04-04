create or replace package elox_types authid current_user as

    subtype error_collector is ot_error_collector;
    subtype error_detection_strategy is ot_error_detection_strategy;

end elox_types;
/