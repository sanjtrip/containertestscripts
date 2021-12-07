#!/bin/sh
#
#Copyright (c) 2021 Advanced Micro Devices, Inc. All Rights Reserved.
#Author: Siddharth Srinivasan, Sid.srinivasan@amd.com
#Version: V1.1
#
#This script runs the Mini-HACC test commands for docker container
#
#To run the script, download the script using wget then:
#       sh ./run_mini_hacc_docker_tests.sh
#


echo "=== MINI-HACC Log Collection Utility: V2.0 ==="
/bin/date

echo "==== Section: Running on $(/bin/hostname) Node ========"

echo "=== Section: Pull amdih/minihacc docker container ======"
docker pull amdih/minihacc:1.0.0
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

echo "============ Section: Running benchmark script with FP32 ========== "
docker run --rm -it --ipc=host --device=/dev/kfd --device=/dev/dri --security-opt seccomp=unconfined amdih/minihacc:1.0.0 mini-HACC

echo "============ Section: Running benchmark script with FP64 ========== "
docker run --rm -it --ipc=host --device=/dev/kfd --device=/dev/dri --security-opt seccomp=unconfined amdih/minihacc:1.0.0 mini-HACC-fp64

echo "==== Using $ROCM_VERSION to collect ROCm information.==== "
$ROCM_VERSION/bin/rocm-smi
$ROCM_VERSION/bin/rocm-smi --showhw

echo "===== Section: Show logs ==========="
/bin/dmesg | grep -E 'gpu|pcie' | tail -100
