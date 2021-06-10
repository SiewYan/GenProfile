#!/bin/bash

set -e

if [ -z $1 ]; then
    echo "empty string"
    echo "./profile_mem.sh TAU-RunIISummer19UL18wmLHEGEN-00006"
    exit
fi

cd ${1}_cmdLog

## --For web-based report
## -step1
igprof-analyse --sqlite -v -d -g -r MEM_LIVE igprofMEM_step1.gz | sqlite3 igprofMEM_step1.sql3 >& MEMsql_step1.log
## -step2
igprof-analyse --sqlite -v -d -g -r MEM_LIVE igprofMEM_step2.gz | sqlite3 igprofMEM_step2.sql3 >& MEMsql_step2.log

## --For ascii-based report
## -step1
igprof-analyse  -v -d -g -r MEM_LIVE igprofMEM_step1.gz >& RES_MEM_step1.txt
## -step2
igprof-analyse  -v -d -g -r MEM_LIVE igprofMEM_step2.gz >& RES_MEM_step2.txt
