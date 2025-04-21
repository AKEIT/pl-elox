create or replace package body elox_apex as 

    procedure init_collection(in_collection_name in varchar2) as
    begin 
        if not apex_collection.collection_exists(p_collection_name => in_collection_name) then 
            apex_collection.create_collection(p_collection_name => in_collection_name);
        end if;
    end init_collection;

    procedure to_collection(in_error                in error_type,
                            in_collection_name      in varchar2,
                            in_create_collection    in boolean default false)
    as
    begin 
        to_collection(in_errors             => ct_errors(in_error),
                      in_collection_name    => in_collection_name,
                      in_create_collection  => in_create_collection);
    end to_collection;

    procedure to_collection(in_errors               in errors_type,
                            in_collection_name      in varchar2,
                            in_create_collection    in boolean default false)
    as  t_codes         APEX_APPLICATION_GLOBAL.N_ARR;
        t_messages      APEX_APPLICATION_GLOBAL.VC_ARR2;
        t_error_stacks  APEX_APPLICATION_GLOBAL.VC_ARR2;
        t_call_stacks   APEX_APPLICATION_GLOBAL.VC_ARR2;
        t_contexts      APEX_APPLICATION_GLOBAL.VC_ARR2;
        t_reference_ids APEX_APPLICATION_GLOBAL.VC_ARR2;
        t_time_stamps   APEX_APPLICATION_GLOBAL.D_ARR;
    begin 
        if in_create_collection then init_collection(in_collection_name => in_collection_name); end if;

        for idx in 1..in_errors.count loop
            t_codes(idx)            := in_errors(idx).code;
            t_messages(idx)         := in_errors(idx).message;
            t_error_stacks(idx)     := substr(in_errors(idx).error_stack,1,4000);
            t_call_stacks(idx)      := substr(in_errors(idx).call_stack,1,4000);
            t_contexts(idx)         := in_errors(idx).context;
            t_reference_ids(idx)    := in_errors(idx).reference_id;
            t_time_stamps(idx)      := in_errors(idx).time_stamp;
        end loop;

        apex_collection.add_members(p_collection_name => in_collection_name,
                                    p_c001            => t_contexts,
                                    p_c002            => t_reference_ids,
                                    p_c003            => t_messages,
                                    p_c004            => t_error_stacks,
                                    p_c005            => t_call_stacks,
                                    p_n001            => t_codes,
                                    p_d001            => t_time_stamps);

    end to_collection;

    procedure to_collection(in_collector            in error_collector_type,
                            in_collection_name      in varchar2,
                            in_create_collection    in boolean default false) as
    begin 
        to_collection(in_errors             => in_collector.get_errors(),
                      in_collection_name    => in_collection_name,
                      in_create_collection  => in_create_collection);
    end to_collection;

    function build_apex_error_additional_info_by(in_error in error_type) return varchar2 
    as lf constant varchar2(2 char) := '\r';
    begin 
        return  case when in_error.context      is not null then 'context: '        ||in_error.context      ||lf end
            ||  case when in_error.reference_id is not null then 'reference_id: '   ||in_error.reference_id ||lf end
            ||  case when in_error.code         is not null then 'code: '           ||in_error.code         ||lf end
            ||  case when in_error.time_stamp   is not null then 'timestamp: '      ||in_error.time_stamp   ||lf end;
    end build_apex_error_additional_info_by;

    procedure add_as_apex_error(in_error              in error_type,
                                in_display_location   in varchar2,
                                in_page_item_name     in varchar2 default null)
    as 
    begin 
        apex_error.add_error(p_message          => in_error.message,
                             p_display_location => in_display_location,
                             p_additional_info  => build_apex_error_additional_info_by(in_error => in_error),
                             p_page_item_name   => in_page_item_name);
    end add_as_apex_error;

    procedure add_as_apex_errors(in_errors             in errors_type,
                                 in_display_location   in varchar2,
                                 in_page_item_name     in varchar2 default null)
    as 
    begin 
        for idx in 1..in_errors.count loop
            add_as_apex_error(in_error              => in_errors(idx),
                              in_display_location   => in_display_location,
                              in_page_item_name     => in_page_item_name);
        end loop;
    end add_as_apex_errors;

    procedure add_as_apex_errors(in_collector          in error_collector_type,
                                 in_display_location   in varchar2,
                                 in_page_item_name     in varchar2 default null)
    as 
    begin 
        add_as_apex_errors(in_errors             => in_collector.get_errors(),
                           in_display_location   => in_display_location,
                           in_page_item_name     => in_page_item_name);
    end add_as_apex_errors;

end elox_apex;
/