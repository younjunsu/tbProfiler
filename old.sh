#!/bin/bash
Tibero 6   (DB 6.0 FS07_CS_2005)
Tibero 7   (DB 7.0 FS02) Build 254994
Tibero 5   (DB 5.0 S1419)
Tibero 5 SP1 (DB 5.0 FS02)

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
    echo "#############################"
    echo "# apply trace options"
    echo "#############################"
    echo " - set autot on exp stat plans    : 1"
    echo " - set autot on                   : 2"
    echo " - set autot on exp               : 3"
    echo " - set autot on stat              : 4"
    echo " - set autot on plans             : 5"
    echo " - set autot trace exp stat plans : 6"
    echo " - set autot trace                : 7"
    echo " - set autot trace exp            : 8"
    echo " - set autot trace stat           : 9"
    echo " - set autot trace plans          : 10"
    echo ""
    echo -n "  press key : "
    read setoption_key
    echo ""
    case "$setoption_key" in
        1)
            echo "  - apply : set autot on exp stat plans"
            sed -i '/    ;/c\set autot on exp stat plans    ;' tbsql.login        
        ;;
        2)
            echo "  - apply : set autot on"
            sed -i '/    ;/c\set autot on    ;' tbsql.login
        ;;
        3)
            echo "  - apply : set autot on exp"
            sed -i  '/    ;/c\set autot on exp    ;' tbsql.login
        ;;
        4)
            echo "  - apply : set autot on stat"
            sed -i '/    ;/c\set autot on stat    ;' tbsql.login
        ;;
        5)
            echo "  - apply : set autot on plans"
            sed -i '/    ;/c\set autot on plans    ;' tbsql.login
        ;;
        6)
            echo "  - apply : set autot trace exp stat plans"
            sed -i '/    ;/c\set autot trace exp stat plans    ;' tbsql.login
        ;;
        7)
            echo "  - apply : set autot trace"
            sed -i '/    ;/c\set autot trace    ;' tbsql.login
        ;;
        8)
            echo "  - apply : set autot trace exp"
            sed -i '/    ;/c\set autot trace exp    ;' tbsql.login
        ;;
        9)
            echo "  - apply : set autot trace stat"
            sed -i '/    ;/c\set autot trace stat    ;' tbsql.login
        ;;
        10)
            echo "  - apply : set autot trace plans"
            sed -i '/    ;/c\set autot trace plans    ;' tbsql.login
        ;;
        *)
            echo "error"
        ;;
    esac
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
    # query 
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
    echo "# Xplan"
    echo "#############################"
tbsql -s $TBSQL_USER/$TBSQL_PASSWORD << EOF
    set autot off
    col "SQL Type" format a8
    col "ID" format 99999
    col "PLAN" format a100
    set head off
    set feedback off
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
    echo "# tbprof"
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
    #
    #--------------------------------------------------------------------------------
    echo ""
    echo ""
    echo "#############################"
    echo "# tuning mode tools"
    echo "#############################"
    echo ""
    echo "  - retry  : re"
    echo "  - tbprof : tr"
    echo "-----------------------------"
    echo "    other key exit."
    echo "-----------------------------"
    echo ""
    echo -n  "  press key : "
    read select_key
    #--------------------------------------------------------------------------------


    # select key process
    #--------------------------------------------------------------------------------
    case "$select_key" in 
        "re")
            sql_tuning_mode_progress
        ;;
        "tr")
            sql_tbprof_generator
        ;;
    
        *)
            echo ""
            echo ""
            echo "#############################"
            echo "# tuning mode stop"
            echo "#############################"
            echo " ....exit"
            echo ""
        ;;
    esac
    #--------------------------------------------------------------------------------
}

# Functions
#--------------------------------------------------------------------------------
sql_tuning_mode_progress
#--------------------------------------------------------------------------------