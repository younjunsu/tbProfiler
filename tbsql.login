-- spool apply
spool log/sql_capture.txt
prompt

-- session infomation
set feedback off
select 'tbprofinfo' tbprof, sid, serial#, pid from v$session where sid = (select SESS_ID from vt_mysessid);
prompt

-- session parameter
alter session set sql_trace=yes;
prompt

-- tbsql system env apply
set head on
set feedback on
set pagesize 1000
set linesize 100
set timing on
    ;


-- tbsql display message
prompt
prompt #############################
prompt # Please execute the query.
prompt #############################
prompt
