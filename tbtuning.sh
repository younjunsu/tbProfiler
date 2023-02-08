#!/bin/bash
# Readme
#--------------------------------------------------------------------------------
#
#
#
#
#
#--------------------------------------------------------------------------------


# user configuration
#--------------------------------------------------------------------------------
TBSQL_USER="tibero" # tbsql user
TBSQL_PASSWORD="tmax" # tbslq user password
TB_SQLPATH="/tibero/work/tbtuning" # working directory
SQL_TRACE_FILE_PATH="/tibero/tibero6/instance/tbUTF8/log/sqltrace" # sql trace file path
#--------------------------------------------------------------------------------
#TB_NLS_LANG=MSWIN949  # 5, 6: MSWIN949 / 7: UTF8
#LANG=ko_KR.utf8
stty erase ^H
#stty erase ^?
#--------------------------------------------------------------------------------


# working directory init
#--------------------------------------------------------------------------------
mkdir $TB_SQLPATH/log 2>/dev/null
rm -f $TB_SQLPATH/log/trc.outfile 2>/dev/null
rm -f $TB_SQLPATH/log/sql_capture.txt 2>/dev/null
#--------------------------------------------------------------------------------


# display init function
#--------------------------------------------------------------------------------
function fn_display_init(){
    clear
}
#--------------------------------------------------------------------------------


#
#--------------------------------------------------------------------------------
function fn_system_env_check(){
    TB_SQLPATH_COPY="$TB_SQLPATH"
    
    if [ -z "$db_charset" ]
    then
        cd $HOME
db_charset=`
tbsql "$TBSQL_USER/$TBSQL_PASSWORD" -s <<EOF
select 'db_charset', CHARACTERSET_NAME, NCHAR_CHARACTERSET_NAME from sys._vt_nls_character_set;
EOF
`
        db_nls_charset=`echo "$db_charset" |grep "db_charset" |awk '{print $2}'`
        db_national_charset=`echo "$db_charset" |grep "db_charset" |awk '{print $3}'`
    fi

    tiber_proc_check=`ps -ef|grep tbsvr |grep -w $TB_SID` 2>/dev/null
}
#--------------------------------------------------------------------------------

# help message function
#--------------------------------------------------------------------------------
function fn_help_message(){
    echo ""
    echo "#############################"
    echo " tbsql tuning mode help"
    echo "#############################"
    echo " usage: sh tbtuning.sh [option]"
    echo "-----------------------------"
    echo "  run  : start tbtuning"
    echo "  help : help message"
    echo "-----------------------------"
    echo ""
}
#--------------------------------------------------------------------------------


# tibero version check function
#-------------------------------------------------------------------------------
function fn_tibero_version_check(){
    tibero_version=`tbboot -version |grep "Tibero" |sed 's/   / /g'`
}
#-------------------------------------------------------------------------------


# exception check function 
#-------------------------------------------------------------------------------
function fn_error_check(){
    error_check="success"
    
    fn_tibero_version_check
    fn_system_env_check
    
    if [ -z "$tiber_proc_check" ]
    then
        echo " ERROR : tbsvr process check"
        error_check="error"
    fi

    if [ -z "$TB_SID" ]
    then
        echo " ERROR : TB_SID"
        error_check="error"
    fi

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
    elif [ "$error_check" == "success" ]
    then
        continue
    else
        exit 0
    fi
}
#-------------------------------------------------------------------------------


# tbtuning meta display message function
#-------------------------------------------------------------------------------
function fn_tbtuning_options_message(){
    fn_display_init    
    fn_tibero_version_check
    echo "#############################"
    echo "# tuning mode options"
    echo "#############################"
    echo "  - TIBERO VERSION             : $tibero_version"
    echo "  - TIBERO USER                : $TBSQL_USER"
    echo "  - TB_SQLPATH                 : $TB_SQLPATH"
    echo "  - SQL_TRACE_FILE_PATH        : $SQL_TRACE_FILE_PATH"
    echo "  - TB_NLS_LANG                : $TB_NLS_LANG"
    echo "  - DB CHARACTERSET_NAME       : $db_nls_charset"
    echo "  - DB NCHAR_CHARACTERSET_NAME : $db_national_charset"
    echo "-----------------------------"
    echo "  sql trace file : "`ls $SQL_TRACE_FILE_PATH |wc -l`
    echo "-----------------------------"
    echo ""
}
#-------------------------------------------------------------------------------


# sql autot trace apply function
#-------------------------------------------------------------------------------
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
    echo "-----------------------------"
    echo " - quit : q"
    echo "-----------------------------"
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
        "q")
            exit 0
        ;;
        *)
            echo "  - no trace option"
        ;;
    esac
    echo ""
}
#-------------------------------------------------------------------------------


# tuning mode function
#-------------------------------------------------------------------------------
function fn_tuning_mode(){
    # tuning mode options display
    #---------------------------------------------------------------------------        
    fn_tbtuning_options_message
    #---------------------------------------------------------------------------        
        
    # autot setting
    #---------------------------------------------------------------------------        
    fn_set_autot_trace_check
    #---------------------------------------------------------------------------

    # tuning mode query press and tools message display
    #---------------------------------------------------------------------------
    cd $TB_SQLPATH

    echo "#############################"
    echo "# tuning mode options apply"
    echo "#############################"
    echo ""
    rlwrap_check=`whereis rlwrap |sed 's/rlwrap://g'`
    if [ -z "$rlwrap_check" ]
    then
        tbsql $TBSQL_USER/$TBSQL_PASSWORD -s 
    elif [ -n "$rlwrap_check" ]
    then
        rlwrap tbsql $TBSQL_USER/$TBSQL_PASSWORD -s 
    fi       
    # tbsql.login apply  
    # query running
    #---------------------------------------------------------------------------

    # xplan running
    #---------------------------------------------------------------------------
    fn_xplan_gather
    #---------------------------------------------------------------------------
}
#-------------------------------------------------------------------------------


# xplan gather function
#-------------------------------------------------------------------------------
function fn_xplan_gather(){
    sql_id=`grep "SQL ID" $TB_SQLPATH/log/sql_capture.txt |tail -n 1 |awk '{print $NF}'`
    child_number=`grep "Child number" $TB_SQLPATH/log/sql_capture.txt |tail -n 1 |awk '{print $NF}'`

    if [ -n "$sql_id" ] && [ -n "$child_number" ]
    then    
        TB_SQLPATH=""
        cd $HOME
        echo ""
        echo ""
        echo "#############################"
        echo "# Xplan"
        echo "#############################"
tbsql -s $TBSQL_USER/$TBSQL_PASSWORD <<EOF
    col "SQL Type" format a8
    col "ID" format 99999
    col "PLAN" format a100
    set autot off
    set head off
    set feedback off
    set lines 200
    select * from table(dbms_xplan.display_cursor('$sql_id',$child_number, 'ALL'));
    exit
EOF
        TB_SQLPATH=$TB_SQLPATH_COPY
        cd $TB_SQLPATH

    elif [ -z "$sql_id" ] || [ -z "$child_number"]
    then
        continue
    fi

    # fn_exit
    #---------------------------------------------------------------------------
    fn_exit
    #---------------------------------------------------------------------------
}


# tbprof gather function
#-------------------------------------------------------------------------------
function fn_tbporf_gather(){
    echo ""
    echo "#############################"
    echo "# tbprof"
    echo "#############################"
    
    session_sql_id=`grep "tbprofinfo" $TB_SQLPATH/log/sql_capture.txt |tail -n 1|awk '{printf $2}'`
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

    # fn_exit
    #---------------------------------------------------------------------------
    fn_exit
    #---------------------------------------------------------------------------
}


# exit message function
#-------------------------------------------------------------------------------
function fn_exit(){
    echo ""
    echo "#############################"
    echo "# tuning mode tools"
    echo "#############################"
    echo ""
    echo "  - tuning  : re"
    echo "  - tbprof  : tr"
    echo "  - quit    : q"
    echo "-----------------------------"
    echo "    other key retry."
    echo "-----------------------------"
    echo ""
    echo -n  "  press key : "
    read press_key

    case "$press_key" in 
        "re")
            fn_tuning_mode
        ;;
        "tr")
            fn_tbporf_gather
        ;;
        "q")
            echo ""
            echo "#############################"
            echo "# tuning mode stop"
            echo "#############################"
            echo " ....exit"
            echo ""
            exit 1
        ;;
        *)
            fn_exit
        ;;
    esac
}
#-------------------------------------------------------------------------------


# functions process
#--------------------------------------------------------------------------------
    vaild_option=$1
    case "$vaild_option" in
        "run")
            fn_error_check
            fn_tuning_mode
        ;;
        *)
            fn_help_message
        ;;
    esac
#--------------------------------------------------------------------------------