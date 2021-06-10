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

NUMBER="100"
#EVENTS="1437"
EVENTS="100"
NTHREAD="1"

cat <<EOF> cmdLog
#!/bin/bash

# step1 LHE step
cmsDriver.py Configuration/GenProduction/python/${NAME}-fragment.py \
--conditions `arg "--conditions"` \
-s LHE \
--datatier GEN \
--beamspot `arg "--beamspot"` \
-n ${EVENTS} \
--eventcontent LHE \
--number ${NUMBER} \
--nThreads ${NTHREAD} \
--customise Configuration/DataProcessing/Utils.addMonitoring \
--customise_commands `arg "--customise_commands"` \
--python_filename ${NAME}-fragment_LHE.py \
--no_exec \
--fileout file:step1.root > step1_$NAME.log  2>&1

# step2 GEN-SIM step
cmsDriver.py Configuration/GenProduction/python/${NAME}-fragment.py \
--conditions `arg "--conditions"` \
-s GEN \
--datatier GEN-SIM \
--beamspot `arg "--beamspot"` \
-n ${EVENTS} \
--eventcontent RAWSIM \
--number ${NUMBER} \
--nThreads ${NTHREAD} \
--customise Configuration/DataProcessing/Utils.addMonitoring \
--customise_commands `arg "--customise_commands"` \
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
