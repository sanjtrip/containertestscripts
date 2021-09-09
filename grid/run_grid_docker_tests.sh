#!/bin/sh
#
#Copyright (c) 2021 Advanced Micro Devices, Inc. All Rights Reserved.
#Author: Siddharth Srinivasan, Sid.srinivasan@amd.com
#Version: V1.0
#
#This script runs the GRID test commands for docker container
#
#To run the script, download the script using wget then:
#       sh ./run_grid_docker_tests.sh
#

echo "=== GRID Log Collection Utility: V2.0 ==="
/bin/date

echo "==== Section: Running on $(/bin/hostname) Node ========"

echo "===== Section: Show which GPU system running scripts on ========== "
rocminfo | grep gfx

echo "=== Section: Pull amdih/grid docker container ======="
docker pull amdih/grid:0.8.2
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

echo "========== Running example GRID benchmark script in interactive mode ============ "
docker run --rm -it --device /dev/dri --device /dev/kfd --security-opt seccomp=unconfined -e OMPI_ALLOW_RUN_AS_ROOT=1 -e OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1 amdih/grid:0.8.2 /bin/bash -c "Benchmark_ITT --accelerator-threads 8"
echo " ============= benchmark script complete ============ "

echo "============== Running example GRID benchmark script with 1 GPUs in interactive mode ============ "
docker run --rm -it --device /dev/dri --device /dev/kfd --security-opt seccomp=unconfined -e OMPI_ALLOW_RUN_AS_ROOT=1 -e OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1 amdih/grid:0.8.2 /bin/bash -c "mpirun -np 1 /benchmark/gpu_bind.sh Benchmark_ITT --accelerator-threads 8 --mpi 1.1.1.1"
echo " ============= benchmark script complete ============ "

echo "============== Running example GRID benchmark script with 2 GPUs in interactive mode ============ "
docker run --rm -it --device /dev/dri --device /dev/kfd --security-opt seccomp=unconfined -e OMPI_ALLOW_RUN_AS_ROOT=1 -e OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1 amdih/grid:0.8.2 /bin/bash -c "mpirun -np 2 /benchmark/gpu_bind.sh Benchmark_ITT --accelerator-threads 8 --mpi 1.1.1.2"
echo " ============= benchmark script complete ============ "

echo "============== Running example GRID benchmark script with 4 GPUs in intera
ctive mode ============ "
docker run --rm -it --device /dev/dri --device /dev/kfd --security-opt seccomp=unconfined -e OMPI_ALLOW_RUN_AS_ROOT=1 -e OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1 amdih/grid:0.8.2 /bin/bash -c "mpirun -np 4 /benchmark/gpu_bind.sh Benchmark_ITT --accelerator-threads 8 --mpi 1.1.1.4"
echo " ============= benchmark script complete ============ "

echo "============== Running example GRID benchmark script with 8 GPUs in intera
ctive mode ============ "
docker run --rm -it --device /dev/dri --device /dev/kfd --security-opt seccomp=unconfined -e OMPI_ALLOW_RUN_AS_ROOT=1 -e OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1 amdih/grid:0.8.2 /bin/bash -c "mpirun -np 8 /benchmark/gpu_bind.sh Benchmark_ITT --accelerator-threads 8 --mpi 1.1.1.8"
echo " ============= benchmark script complete ============ "

echo "==== Using $ROCM_VERSION to collect ROCm information.==== "
$ROCM_VERSION/bin/rocm-smi
$ROCM_VERSION/bin/rocm-smi --showhw

echo "======== Section: print logs ========"
/bin/dmesg | grep -E 'gpu|pcie' | tail -100
