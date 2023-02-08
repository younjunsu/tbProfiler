[tibero@4777c5805ab6 tbtuning]$ sh tbtuning.sh 
```
#############################
 tbsql tuning mode help
#############################
 usage: sh tbtuning.sh [option]
-----------------------------
  run  : start tbtuning
  help : help message
-----------------------------
```

```
[tibero@4777c5805ab6 tbtuning]$ cat tbtuning.sh  |more
# user configuration
#--------------------------------------------------------------------------------
TBSQL_USER="" # tbsql user
TBSQL_PASSWORD="" # tbslq user password
TB_SQLPATH="" # working directory
SQL_TRACE_FILE_PATH="" # sql trace file path
#--------------------------------------------------------------------------------
#TB_NLS_LANG=MSWIN949  # 5, 6: MSWIN949 / 7: UTF8
#LANG=ko_KR.utf8
stty erase ^H
#stty erase ^?
#--------------------------------------------------------------------------------
````
