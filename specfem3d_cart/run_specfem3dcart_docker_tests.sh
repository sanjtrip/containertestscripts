#!/bin/sh
#
#Copyright (c) 2021 Advanced Micro Devices, Inc. All Rights Reserved.
#Author: Siddharth Srinivasan, Sid.srinivasan@amd.com
#Version: V1.0
#
#This script runs the SPECFEM3D Cartesian test commands for docker container
#
#To run the script, download the script using wget then:
#       sh ./run_specfem3dcart_docker_tests.sh
#

echo "=== SPECFEM3D CARTESIAN Log Collection Utility: V2.0 ==="
/bin/date

echo "==== Section: Running on $(/bin/hostname) Node ========"

echo "=== Section: Pull amdih/specfem3d docker container ======"
docker pull amdih/specfem3d:9c0626d1
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

echo " ======= Section: Run CARTESIAN benchmark with 64 cores using 4 GPUs ============="
docker run --rm -it --device=/dev/dri --device=/dev/kfd --security-opt seccomp=unconfined amdih/specfem3d:9c0626d1 /bin/bash -c "export OMPI_ALLOW_RUN_AS_ROOT=1; export OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1; benchmark cartesian -g 4 -c 0 -s 288x256 -o /tmp/run1 --mpi-args='--bind-to cpu-list:ordered --cpu-list "0,8,16,24,64,72,80,88" --report-bindings'"
echo " ========= Run Complete =========="

echo " ======= Section: Run CARTESIAN benchmark with 64 cores using 8 GPUs ============="
docker run --rm -it --device=/dev/dri --device=/dev/kfd --security-opt seccomp=unconfined amdih/specfem3d:9c0626d1 /bin/bash -c "export OMPI_ALLOW_RUN_AS_ROOT=1; export OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1; benchmark cartesian -g 8 -c 0 -s 288x256 -o /tmp/run1 --mpi-args='--bind-to cpu-list:ordered --cpu-list "0,8,16,24,64,72,80,88" --report-bindings'"
echo " ========= Run Complete =========="

echo " ======= Section: Run CARTESIAN benchmark with 32 cores using 4 GPUs ============="
docker run --rm -it --device=/dev/dri --device=/dev/kfd --security-opt seccomp=unconfined amdih/specfem3d:9c0626d1 /bin/bash -c "export OMPI_ALLOW_RUN_AS_ROOT=1; export OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1; benchmark cartesian -g 4 -c 0 -s 288x256 -o /tmp/run2 --mpi-args='--bind-to cpu-list:ordered --cpu-list "0,8,16,24,32,40,48,52" --report-bindings'"
echo " ========= Run Complete =========="

echo " ======= Section: Run CARTESIAN benchmark with 32 cores using 4 GPUs ============="
docker run --rm -it --device=/dev/dri --device=/dev/kfd --security-opt seccomp=unconfined amdih/specfem3d:9c0626d1 /bin/bash -c "export OMPI_ALLOW_RUN_AS_ROOT=1; export OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1; benchmark cartesian -g 8 -c 0 -s 288x256 -o /tmp/run2 --mpi-args='--bind-to cpu-list:ordered --cpu-list "0,8,16,24,32,40,48,52" --report-bindings'"
echo " ========= Run Complete =========="

echo "==== Using $ROCM_VERSION to collect ROCm information.==== "
$ROCM_VERSION/bin/rocm-smi
$ROCM_VERSION/bin/rocm-smi --showhw

echo "===== Section: Show logs ==========="
/bin/dmesg | grep -E 'gpu|pcie' | tail -100
