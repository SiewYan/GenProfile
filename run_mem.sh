#!/bin/bash

set -e

if [ -z $1 ]; then
    echo "empty string"
    echo "./run_cpu.sh TAU-RunIISummer19UL18wmLHEGEN-00006"
    exit
fi

WRAPPER="--"

cd ${1}_cmdLog

# step1
echo "cpu step1"
igprof -mp -o ./igprofMEM_step1.gz -- cmsRun $WRAPPER ${1}-fragment_LHE.py >& step1_mem.log

echo "cpu step2"
igprof -mp -o ./igprofMEM_step2.gz -- cmsRun $WRAPPER ${1}-fragment_GEN.py >& step2_mem.log
