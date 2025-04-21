create or replace view elox_apex_collections as 
select  collection_name     collection_name,
        seq_id              seq_id,
        c001                context,
        c002                reference_id,
        n001                code,
        c003                message,
        d001                time_stamp,
        c003                error_stack,
        c004                call_stack
  from  apex_collections;