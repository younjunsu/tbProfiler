#!/bin/bash


# user configuration.
#--------------------------------------------------------------------------------
TBSQL_USER=tibero # tbsql user
TBSQL_PASSWORD=tmax # tbslq user password
TB_SQLPATH=/tibero/work/tbtuning # working directory
SQL_TRACE_FILE_PATH="/tibero/tibero6/instance/tbUTF8/log/sqltrace" # sql trace file path
#--------------------------------------------------------------------------------
#TB_NLS_LANG=MSWIN949  # 5, 6: MSWIN949 / 7: UTF8
#LANG=ko_KR.utf8
stty erase ^H
#stty erase ^?
#--------------------------------------------------------------------------------

# working directory init. 
#--------------------------------------------------------------------------------
mkdir $TB_SQLPATH/log
rm -f $TB_SQLPATH/log/trc.outfile
rm -f $TB_SQLPATH/log/sql_capture.txt
#rm -f $SQL_TRACE_FILE_PATH/*
#--------------------------------------------------------------------------------

function fn_help_message(){
    echo ""
    echo "#############################"
    echo " tbsql tuning mode help"
    echo "#############################"
    echo " usage: sh tbtuning.sh [option]"
    echo "-----------------------------"
    echo "  run : start tbtuning"
    echo "  help : help message"
    echo "-----------------------------"
    echo ""
}

function fn_error_check(){
    error_check="success"

    if [ -z "$TBSQL_USER" ]
    then
        echo "ERROR : TBSQL_USER"
        error_check="error"
    fi

    if [ -z "$TBSQL_PASSWORD" ]
    then
        echo "ERROR : TBSQL_PASSWORD"
        error_check="error"
    fi

    if [ -z "$TB_SQLPATH" ]
    then
        echo "ERROR : TB_SQLPATH"
        error_check="error"
    fi

    if [ -z "$SQL_TRACE_FILE_PATH" ]
    then
        echo "ERROR : SQL_TRACE_FILE_PATH"
        error_check="error"
    fi

    if [ "$error_check" == "error" ]
    then
        exit 1
    elif [ "$erorr_check" == "success" ]
    then
        continue
    else
        exit 0
    fi
}

function fn_tibero_version_check(){
    tibero_version=`tbboot -version |grep "Tibero"`
}

function fn_set_autot_trace_check(){
    cd $TB_SQLPATH
    echo ""
    echo "#############################"
    echo "# trace options"
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
    read press_key
    echo ""
    case "$press_key" in
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
}

function fn_tuning_mode(){
    # tuning mode query press and tools message display
    #--------------------------------------------------------------------------------
    cd $TB_SQLPATH
    tbsql $TBSQL_USER/$TBSQL_PASSWORD -s 
    # tbsql.login apply  
    # query running
    #--------------------------------------------------------------------------------
}


function fn_xplan_gather(){
    sql_id=`grep "SQL ID" $TB_SQLPATH/log/sql_capture.txt |tail -n 1 |awk '{print $NF}'`
    child_number=`grep "Child number" $TB_SQLPATH/log/sql_capture.txt |tail -n 1 |awk '{print $NF}'`

    if [ -n "$sql_id" ] && [ -n "$child_number" ]
    then    
        local TB_SQLPATH=""
        cd $HOME
        echo ""
        echo ""
        echo "#############################"
        echo "# Xplan"
        echo "#############################"
tbsql -s $TBSQL_USER/$TBSQL_PASSWORD <<EOF
    set autot off
    col "SQL Type" format a8
    col "ID" format 99999
    col "PLAN" format a100
    set head off
    set feedback off
    set lines 200
    select * from table(dbms_xplan.display_cursor('$SQL_ID',$child_number, 'ALL'));
    exit
EOF
    
    cd $TB_SQLPATH
    
    elif [ -z "$SQL_ID" ] || [ -z "$child_number"]
    then
        continue
    fi
}

function fn_tbporf_gather(){
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

function fn_exit(){
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
    read press_key
    #--------------------------------------------------------------------------------

    #
    #--------------------------------------------------------------------------------
    case "$press_key" in 
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
    vaild_option=$1
    case "$vaild_option" in
        "run")
            fn_error_check
            fn_tibero_version_check
            fn_set_autot_trace_check
            fn_tuning_mode
            fn_xplan_gather
            fn_tbporf_gather
            fn_exit
        ;;
        *)
            fn_help_message
        ;;
    esac
#--------------------------------------------------------------------------------