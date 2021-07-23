#!/bin/sh
#
#Copyright (c) 2021 Advanced Micro Devices, Inc. All Rights Reserved.
#Author: Siddharth Srinivasan, Sid.srinivasan@amd.com
#Version: V1.1
#
#This script runs the MILC test commands for docker container
#
#To run the script, download the script using wget then:
#	sh ./run_milc_docker_tests.sh
#


echo "=== MILC Log Collection Utility: V2.0 ==="
/bin/date

echo "=== Section: Pull amdih/milc docker container ======"
docker pull amdih/milc:12ddd7d9
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


echo " ===== Section: Run MILC docker run-benchmark script and output to file ======="
docker run --rm -it --device /dev/dri --device /dev/kfd --security-opt seccomp=unconfined amdih/milc:12ddd7d9 /bin/bash -c "cd /benchmark; run-benchmark -o milc-benchmark.out"
echo "milc run-benchmark script complete"


echo "==== Using $ROCM_VERSION to collect ROCm information.==== "
$ROCM_VERSION/bin/rocm-smi
$ROCM_VERSION/bin/rocm-smi --showhw

echo "===== Section: Show logs ==========="
/bin/dmesg | grep -E 'gpu|pcie' | tail -100
