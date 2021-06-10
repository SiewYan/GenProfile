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
igprof -pp -z -o ./igprofCPU_step1.gz -- cmsRun $WRAPPER ${1}-fragment_LHE.py >& step1_cpu.log

echo "cpu step2"
igprof -pp -z -o ./igprofCPU_step2.gz -- cmsRun $WRAPPER ${1}-fragment_GEN.py >& step2_cpu.log
