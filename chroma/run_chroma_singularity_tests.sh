#!/bin/sh
#
#Copyright (c) 2021 Advanced Micro Devices, Inc. All Rights Reserved.
#Author: Siddharth Srinivasan, Sid.srinivasan@amd.com
#Version: V1.1
#
#This script runs the Chroma test commands for singularity container
#
#To run the script, download the script using wget then:
#       sh ./run_chroma_singularity_tests.sh
#

echo "Pull amdih/milc container"
singularity pull --docker-login chroma_3.43.0.sif docker://amdih/chroma:3.43.0
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

echo "Run chroma docker using singularity and run the run-benchmark script with 1 gpu"
singularity run --pwd /benchmark --writable-tmpfs chroma_3.43.0.sif run-benchmark --ngpus 1
echo "chroma run-benchmark script complete"

echo "==== Using $ROCM_VERSION to collect ROCm information.==== "
$ROCM_VERSION/bin/rocm-smi
$ROCM_VERSION/bin/rocm-smi --showhw

echo "Show logs"
/bin/dmesg | grep -E 'gpu|pcie' | tail -100
