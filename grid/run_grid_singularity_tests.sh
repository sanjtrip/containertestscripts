#!/bin/sh
#
#Copyright (c) 2021 Advanced Micro Devices, Inc. All Rights Reserved.
#Author: Siddharth Srinivasan, Sid.srinivasan@amd.com
#Version: V1.0
#
#This script runs the GRID test commands for docker container using singularity
#
#To run the script, download the script using wget then:
#       sh ./run_grid_singularity_tests.sh
#

echo "=== GRID Log Collection Utility: V2.0 ==="
/bin/date

echo "==== Section: Running on $(/bin/hostname) Node ========"

echo "===== Section: Show which GPU system running scripts on ========== "
rocminfo | grep gfx

echo "=== Section: Pull amdih/grid docker container ======="
singularity pull grid_0.8.2.sif docker://amdih/grid:0.8.2
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

echo "========== Running example GRID benchmark script in non-interactive mode ============ "
singularity run grid_0.8.2.sif Benchmark_ITT --accelerator-threads 8
echo " ============= benchmark script complete ============ "

echo "==== Using $ROCM_VERSION to collect ROCm information.==== "
$ROCM_VERSION/bin/rocm-smi
$ROCM_VERSION/bin/rocm-smi --showhw

echo "======== Section: print logs ========"
/bin/dmesg | grep -E 'gpu|pcie' | tail -100
