#!/bin/sh
#
#Copyright (c) 2021 Advanced Micro Devices, Inc. All Rights Reserved.
#Author: Siddharth Srinivasan, Sid.srinivasan@amd.com
#Version: V1.1
#
#This script runs the MILC test commands for singularity container
#
#To run the script, download the script using wget then:
#	sh ./run_milc_singularity_tests.sh
#

echo "=== MILC Log Collection Utility: V2.0 ==="
/bin/date

echo "=== Section: Pull amdih/milc docker container ======"
singularity pull --docker-login milc_12ddd7d9.sif docker://amdih/milc:12ddd7d9
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

echo " ===== Section: Run MILC using singularity docker run-benchmark script and output to file ======="
singularity run --pwd /benchmark --bind $(pwd)/out:/tmp/bench --writable-tmpfs milc_12ddd7d9.sif run-benchmark -o /tmp/bench/bench-np1.txt 
echo "======= milc run-benchmark script complete ===="

echo "==== Using $ROCM_VERSION to collect ROCm information.==== "
$ROCM_VERSION/bin/rocm-smi
$ROCM_VERSION/bin/rocm-smi --showhw

echo "======= Section: Show logs ======"
/bin/dmesg | grep -E 'gpu|pcie' | tail -100

