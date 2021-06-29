# GenProfile
scripts for profiling generator application

## Environment
```
Linux cms-oc-gpu-01.cern.ch 3.10.0-1160.24.1.el7.x86_64
```

## Profiling

After setup.sh, you have to set the CMSSW_BASE environment by doing ```cmsenv``` to use igprof
```
./setup.sh TAU-RunIISummer19UL18wmLHEGEN-00006
./run_cpu.sh TAU-RunIISummer19UL18wmLHEGEN-00006
./run_cpu.sh TAU-RunIISummer19UL18wmLHEGEN-00006
```

## Generate report
```
./profile.sh TAU-RunIISummer19UL18wmLHEGEN-00006
./profile_mem.sh TAU-RunIISummer19UL18wmLHEGEN-00006
```

## Processes
| Process                                                                      | McM                                 |
| ---------------------------------------------------------------------------- | ----------------------------------- |
| DY4JetsToLL_M-50_TuneCP5_13TeV-madgraphMLM-pythia8                           | TAU-RunIISummer19UL18wmLHEGEN-00006 |
| TTJets_TuneCP5_13TeV-amcatnloFXFX-pythia8                                    | TOP-RunIISummer19UL18wmLHEGEN-00006 |
| WplusJetsToMuNu_TuneCP5_13TeV-powhegMiNNLO-pythia8-photos                    | SMP-RunIISummer20UL16wmLHEGEN-00022 | 
| WplusH_HToZZTo2L2Nu_M2500_TuneCP5_13TeV_powheg2-minlo-HWJ_JHUGenV735_pythia8 | HIG-RunIISummer20UL18wmLHEGEN-00657 |
