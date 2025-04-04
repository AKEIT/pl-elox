create or replace type ot_error authid current_user as object (
  code          number,
  message       varchar2(4000 char),
  error_stack   varchar2(32767 char),
  call_stack    varchar2(32767 char),
  context       varchar2(4000 char),
  reference_id  varchar2( 256 char),
  time_stamp    timestamp,

  constructor function ot_error(code          number,
                                message       varchar2,
                                context       varchar2  default null,
                                reference_id  varchar2  default null,
                                error_stack   varchar2  default null,
                                call_stack    varchar2  default null,
                                time_stamp    timestamp default systimestamp()) return self as result
);
/