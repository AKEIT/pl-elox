create or replace type body ot_dml_error_log_detection_strategy as 
    constructor function ot_dml_error_log_detection_strategy(log_table_name      in varchar2,
                                                             error_tag           in varchar2,
                                                             reference_id_column in varchar2,
                                                             context             in varchar2 default null,
                                                             log_table_owner     in varchar2 default null) return self as result 
    as  l_stmt              varchar2(4000 char);
        error_log_cursor    SYS_REFCURSOR;
        type r_error_log_type is record(code            pls_integer,
                                        message         varchar2(4000 char),
                                        reference_id    varchar2(4000 char));
        r_error_log r_error_log_type;
    begin 
        self.errors := ct_errors();
        l_stmt := '';
        l_stmt := l_stmt||' select  -ORA_ERR_NUMBER$                    as code,';
        l_stmt := l_stmt||'         ORA_ERR_MESG$                       as message,';
        l_stmt := l_stmt||'         to_char('||reference_id_column||')  as reference_id';
        l_stmt := l_stmt||' from    '||case 
                                        when log_table_owner is not null 
                                        then log_table_owner||'.'||log_table_name
                                        else log_table_name 
                                       end;
        l_stmt := l_stmt||' where   ORA_ERR_TAG$ = :error_tag';
        
        open error_log_cursor for l_stmt using error_tag;
        LOOP
            fetch error_log_cursor into r_error_log;
            EXIT WHEN error_log_cursor%NOTFOUND;
            self.errors.extend();
            self.errors(self.errors.count) := ot_error( code            =>r_error_log.code,
                                                        message         =>r_error_log.message,
                                                        context         => nvl(context, error_tag),
                                                        reference_id    =>r_error_log.reference_id,
                                                        error_stack     => DBMS_UTILITY.FORMAT_ERROR_BACKTRACE , -- todo: add error stack detection
                                                        call_stack      => DBMS_UTILITY.FORMAT_CALL_STACK, -- todo: add call stack detection
                                                        time_stamp      =>systimestamp);
        END LOOP;
        close error_log_cursor;

        return;
        exception 
            when others 
            then if error_log_cursor%isopen then 
                    close error_log_cursor;
                 end if;
                 raise;
    end ot_dml_error_log_detection_strategy;
end ot_dml_error_log_detection_strategy;
/