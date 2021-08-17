#!/bin/sh
#
#Copyright (c) 2021 Advanced Micro Devices, Inc. All Rights Reserved.
#Author: Siddharth Srinivasan, Sid.srinivasan@amd.com
#Version: V1.0
#
#This script runs the CP2k test commands for docker container
#
#To run the script, download the script using wget then:
#       sh ./run_cp2k_singularity_webpage_tests.sh
#

echo "=== CP2k Log Collection Utility: V2.0 ==="
/bin/date

echo "==== Section: Running on $(/bin/hostname) Node ========"

echo "===== Section: Show which GPU system running scripts on ========== "
rocminfo | grep gfx

echo "=== Section: Pull amdih/cp2k docker container ======="
singularity pull cp2k_version_tags.sif docker://amdih/cp2k:87ec1599
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

echo "=========== Section: run cp2k script with 8 GPUS in interactive mode ========= "
singularity run --writable-tmpfs --bind $(pwd):/tmp ./cp2k_version_tags.sif benchmark 32-H2O-RPA --gpu-count 8 --cpu-count 128 --omp-thread-count 8 --ranks 8 --rank-stride 16 --output /tmp/out_32
echo "======= Section: cp2k script complete with 8 GPUs ========"

echo "=========== Section: run cp2k script with 4 GPUS in interactive mode ========= "
singularity run --writable-tmpfs --bind $(pwd):/tmp ./cp2k_version_tags.sif benchmark 32-H2O-RPA --gpu-count 4 --cpu-count 128 --omp-thread-count 8 --ranks 4 --rank-stride 32 --output /tmp/out_32
echo "======= Section: cp2k script complete with 4 GPUs ========"

echo "==== Using $ROCM_VERSION to collect ROCm information.==== "
$ROCM_VERSION/bin/rocm-smi
$ROCM_VERSION/bin/rocm-smi --showhw

echo "======== Section: print logs ========"
/bin/dmesg | grep -E 'gpu|pcie' | tail -100


