!/bin/sh
#
#Copyright (c) 2021 Advanced Micro Devices, Inc. All Rights Reserved.
#Author: Siddharth Srinivasan, Sid.srinivasan@amd.com
#Version: V1.0
#
#This script runs the OpenMM test commands for docker container
#
#To run the script, download the script using wget then:
#       sh ./run_openmm_docker_webpage_tests.sh
#

cho "=== NAMD Log Collection Utility: V2.0 ==="
/bin/date

echo "==== Section: Running on $(/bin/hostname) Node ========"

echo "===== Section: Show which GPU system running scripts on ========== "
rocminfo | grep gfx

echo "=== Section: Pull amdih/openmm docker container ======="
docker pull amdih/openmm:7.6.0
echo "Pull complete"

echo "===== Section: Available ROCm versions ==============="
/bin/ls -v -d /opt/rocm*
ROCM_VERSION=`/bin/ls -v -d /opt/rocm-[3-4]* | /usr/bin/tail -1`
if [ "$ROCM_VERSION"x = "x" ]
then
    ROCM_VERSION=`/bin/ls -v -d /opt/rocm* | /usr/bin/tail -1`
fi
echo "==== Using $ROCM_VERSION to collect ROCm information.==== "
$ROCM_VERSION/bin/rocm-smi
$ROCM_VERSION/bin/rocm-smi --showhw

echo "========= Section: Run OpenMM benchmark scripts in interactive mode ============"
docker run --rm -it --device=/dev/kfd --device=/dev/dri --security-opt seccomp=unconfined amdih/openmm:7.6.0 /bin/bash -c "run-benchmarks; python3 $OPENMM_PATH/examples/benchmarks.py --help"
echo "=============== Section: OpenMM benchmark script complete ==========="

echo "========= Section: Run OpenMM benchmark scripts in non-interactive mode ============"
docker run --rm -it --device=/dev/kfd --device=/dev/dri --security-opt seccomp=unconfined amdih/openmm:7.6.0 run-benchmarks
echo "=============== Section: OpenMM benchmark script complete ==========="

echo "==== Using $ROCM_VERSION to collect ROCm information.==== "
$ROCM_VERSION/bin/rocm-smi
$ROCM_VERSION/bin/rocm-smi --showhw

echo "======== Section: print logs ========"
/bin/dmesg | grep -E 'gpu|pcie' | tail -100




