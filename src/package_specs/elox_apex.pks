create or replace package elox_apex as 

    subtype error_type              is elox_types.error;
    subtype errors_type             is elox_types.errors;
    subtype error_collector_type    is elox_types.error_collector;

    procedure to_collection(in_error                in error_type,
                            in_collection_name      in varchar2,
                            in_create_collection    in boolean default false);

    procedure to_collection(in_errors               in errors_type,
                            in_collection_name      in varchar2,
                            in_create_collection    in boolean default false);

    procedure to_collection(in_collector            in error_collector_type,
                            in_collection_name      in varchar2,
                            in_create_collection    in boolean default false);

    procedure add_as_apex_error(in_error              in error_type,
                                in_display_location   in varchar2,
                                in_page_item_name     in varchar2 default null);

    procedure add_as_apex_errors(in_errors             in errors_type,
                                 in_display_location   in varchar2,
                                 in_page_item_name     in varchar2 default null);

    procedure add_as_apex_errors(in_collector          in error_collector_type,
                                 in_display_location   in varchar2,
                                 in_page_item_name     in varchar2 default null);
    
end elox_apex;
/