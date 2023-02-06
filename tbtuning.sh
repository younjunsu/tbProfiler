#!/bin/bash

# user configuration.
#--------------------------------------------------------------------------------
TBSQL_USER=tibero # tbsql user
TBSQL_PASSWORD=tmax # tbslq user password
SQL_TRACE_FILE_PATH="/tibero/tibero6/instance/tbUTF8/log/sqltrace" # sql trace file path
TB_SQLPATH=/tibero/work/tuning # working directory
TB_NLS_LANG=MSWIN949  # 5, 6: MSWIN949 / 7: UTF8
#--------------------------------------------------------------------------------
LANG=ko_KR.utf8
stty erase ^H
#stty erase ^?
#--------------------------------------------------------------------------------


# working directory init. 
#--------------------------------------------------------------------------------
rm -f $TB_SQLPATH/log/trc.outfile
rm -f $TB_SQLPATH/log/sql_capture.txt
#rm -f $SQL_TRACE_FILE_PATH/*
#--------------------------------------------------------------------------------


# log directory 
#--------------------------------------------------------------------------------
mkdir $TB_SQLPATH/log
#--------------------------------------------------------------------------------


# sql_tuning_mode start
#--------------------------------------------------------------------------------
function sql_tuning_mode(){
    # tuning mode start message display
    #--------------------------------------------------------------------------------
    cd $TB_SQLPATH
    clear
    echo ""
    echo ""
    echo "#############################"
    echo "# apply tuning mode options"
    echo "#############################"
    #--------------------------------------------------------------------------------


    # tuning mode query press and tools message display
    #--------------------------------------------------------------------------------
    tbsql $TBSQL_USER/$TBSQL_PASSWORD -s 


    # tuning mode start
    #--------------------------------------------------------------------------------
    # tbsql.login file appplying and query press
    #--------------------------------------------------------------------------------
    # tbsql.login
    # query press
}
#--------------------------------------------------------------------------------


# sql xplan generator function
#--------------------------------------------------------------------------------
function sql_xplan_generator(){    
SQL_ID=`grep "SQL ID" $TB_SQLPATH/log/sql_capture.txt |tail -n 1 |awk '{print $NF}'`
CHILD_NUMBER=`grep "Child number" $TB_SQLPATH/log/sql_capture.txt |tail -n 1 |awk '{print $NF}'`

if [ -n "$SQL_ID" ] && [ -n "$CHILD_NUMBER" ]
then    
    local TB_SQLPATH=""
    cd $HOME
    echo ""
    echo ""
    echo "#############################"
    echo "# SQL xplan"
    echo "#############################"
    echo "SQL ID : $SQL_ID"
    echo "Child number : $CHILD_NUMBER"
    echo

tbsql -s $TBSQL_USER/$TBSQL_PASSWORD << EOF
    set autot off
    col "SQL Type" format a8
    col "ID" format 99999
    col "PLAN" format a100
    set lines 200
    select * from table(dbms_xplan.display_cursor('$SQL_ID',$CHILD_NUMBER, 'ALL'));
    exit
EOF
    cd $TB_SQLPATH
elif [ -z "$SQL_ID" ] || [ -z "$CHILD_NUMBER"]
then
    continue
fi
}
#--------------------------------------------------------------------------------


# tbprof generator function
#--------------------------------------------------------------------------------
function sql_tbprof_generator(){
    echo ""
    echo ""
    echo "#############################"
    echo "# SQL tbprof"
    echo "#############################"
    
    session_sql_id=`grep "tbprofinfo" $TB_SQLPATH/log/sql_capture.txt |awk '{printf $2}'`
    session_serial=`grep "tbprofinfo" $TB_SQLPATH/log/sql_capture.txt |awk '{printf $3}'`
    session_pid=`grep "tbprofinfo" $TB_SQLPATH/log/sql_capture.txt |awk '{printf $4}'`
	current_trace_file=`ls $SQL_TRACE_FILE_PATH/tb_sqltrc_"$session_pid"_"$session_sql_id"_"$session_serial".trc`
    if [ -n "$current_trace_file" ]
    then
	    tbprof $current_trace_file $TB_SQLPATH/log/trc.outfile sys=no
        vi $TB_SQLPATH/log/trc.outfile
    elif [ -z "$current_trace_file" ]
    then
        continue
    fi
	
}
#--------------------------------------------------------------------------------

# SQL xplan
#--------------------------------------------------------------------------------
function sql_tuning_mode_progress(){
    sql_tuning_mode
    sql_xplan_generator
    read press_key
    #
    #--------------------------------------------------------------------------------
    echo ""
    echo ""
    echo "#############################"
    echo "# tuning mode tools"
    echo "#############################"
    echo ""
    echo " - SQL retry  : run"
    echo " - SQL tbprof : trc"
    echo "-----------------------------"
    echo "    other key exit."
    echo "-----------------------------"
    echo
    read select_key
    #--------------------------------------------------------------------------------


    # select key process
    #--------------------------------------------------------------------------------
    if [ "$select_key" == "trc" ]
    then
        sql_tbprof_generator 
    elif [ "$select_key" == "run" ]
    then
        sql_tuning_mode_progress
    fi
    echo ""
    echo ""
    echo "#############################"
    echo "# tuning mode stop"
    echo "#############################"
    echo " ....exit"
    echo ""
    #--------------------------------------------------------------------------------
}

# Functions
#--------------------------------------------------------------------------------
sql_tuning_mode_progress
#--------------------------------------------------------------------------------