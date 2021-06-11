#!/bin/bash

set -e

if [ -z $1 ]; then
    echo "empty string"
    echo "exp: ./setup.sh TAU-RunIISummer19UL18wmLHEGEN-00006"
    exit
fi

NAME=$1
ARCH=`grep -w "SCRAM_ARCH" $1 | awk -F "=" '{print $2}'`
CMSSW=`grep -w "scram p CMSSW" $1 | awk -F " " '{print $NF}'`
CMSDRIVER=`grep -w "cmsDriver.py" $1`
NUMBER=`grep "EVENTS=" $1 | awk -F "=" '{print $NF}'`
NTHREAD="1"

arg(){
    echo $(echo $CMSDRIVER | awk -F "$1 " '{print $NF}' | awk -F " " '{print $1}')
}

export VO_CMS_SW_DIR=/cvmfs/cms.cern.ch
source $VO_CMS_SW_DIR/cmsset_default.sh
source /cvmfs/grid.cern.ch/etc/profile.d/setup-cvmfs-ui.sh

export SCRAM_ARCH=${ARCH}
source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r ${CMSSW}/src ] ; then
    echo release ${CMSSW} already exists
else
    scram p CMSSW ${CMSSW}
fi
cd ${CMSSW}/src
eval `scram runtime -sh`

# Download fragment from McM                                                                                                                                                                                 
curl -s -k https://cms-pdmv.cern.ch/mcm/public/restapi/requests/get_fragment/${NAME} --retry 3 --create-dirs -o Configuration/GenProduction/python/${NAME}-fragment.py
[ -s Configuration/GenProduction/python/${NAME}-fragment.py ] || exit $?;
# Check if fragment contais gridpack path ant that it is in cvmfs
if grep -q "gridpacks" Configuration/GenProduction/python/${NAME}-fragment.py; then
    if ! grep -q "/cvmfs/cms.cern.ch/phys_generator/gridpacks" Configuration/GenProduction/python/${NAME}-fragment.py; then
	echo "Gridpack inside fragment is not in cvmfs."
	exit -1
	fi
fi
scram b
cd ../..

echo "McM Fragment name : $NAME"
echo "SCRAM_ARCH        : $ARCH"
echo "CMSSW version     : $CMSSW"

mkdir -p ${NAME}_cmdLog
cd ${NAME}_cmdLog

cat <<EOF> cmdLog
#!/bin/bash

# step1 LHE step
cmsDriver.py Configuration/GenProduction/python/${NAME}-fragment.py \
--conditions `arg "--conditions"` \
--step LHE \
--datatier LHE,GEN \
--eventcontent LHE,RAWSIM \
--beamspot `arg "--beamspot"` \
--number ${NUMBER} \
--nThreads ${NTHREAD} \
--python_filename ${NAME}-fragment_LHE.py \
--no_exec \
--fileout file:step1.root > step1_$NAME.log  2>&1

# step2 GEN-SIM step
cmsDriver.py Configuration/GenProduction/python/${NAME}-fragment.py \
--conditions `arg "--conditions"` \
--step GEN \
--datatier GEN \
--eventcontent RAWSIM \
--beamspot `arg "--beamspot"` \
--number ${NUMBER} \
--nThreads ${NTHREAD} \
--geometry `arg "--geometry"` \
--era `arg "--era"` \
--python_filename ${NAME}-fragment_GEN.py \
--no_exec \
--filein file:step1.root \
--fileout file:step2.root > step2_$NAME.log  2>&1
EOF

chmod +x cmdLog
./cmdLog

echo "setup complete: ${1}_cmdLog"

#--customise Configuration/DataProcessing/Utils.addMonitoring \

#https://twiki.cern.ch/twiki/bin/view/CMSPublic/CRAB3FAQ#Illegal_parameter_found_in_confi
#--customise_commands `arg "--customise_commands"` \
#----- Begin Fatal Exception 11-Jun-2021 08:13:21 CEST-----------------------
#An exception of category 'Configuration' occurred while
#   [0] Constructing the EventProcessor
#   [1] Validating configuration of input source of type PoolSource
#Exception Message:
#Illegal parameter found in configuration.  The parameter is named:
# 'numberEventsInLuminosityBlock'
#You could be trying to use a parameter name that is not
#allowed for this plugin or it could be misspelled.
#----- End Fatal Exception -------------------------------------------------
