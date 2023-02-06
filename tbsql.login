/* 
 * session parameter
*/ 
prompt DDL: alter session set sql_trace=yes;
alter session set sql_trace=yes;
prompt
/* 
 * spool 
*/ 
spool log/sql_capture.txt
prompt
/*
 *  sql trace file check
*/
set feedback off
select 'tbprofinfo' tbprof, sid, serial#, pid from v$session where sid = (select SESS_ID from vt_mysessid);
prompt

/* 
 * tbsql system env
*/ 
set head on
set feedback on
set pagesize 1000
set timing on
set autot on

/* 
 * display message
*/ 
prompt
prompt
prompt #############################
prompt # Query press
prompt #############################
prompt