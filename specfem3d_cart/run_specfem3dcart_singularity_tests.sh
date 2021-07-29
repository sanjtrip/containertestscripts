#!/bin/sh
#
#Copyright (c) 2021 Advanced Micro Devices, Inc. All Rights Reserved.
#Author: Siddharth Srinivasan, Sid.srinivasan@amd.com
#Version: V1.0
#
#This script runs the SPECFEM3D Cartesian test commands for singularity docker container
#
#To run the script, download the script using wget then:
#       sh ./run_specfem3dcart_singularity_tests.sh
#

echo "=== SPECFEM3D CARTESIAN Log Collection Utility: V2.0 ==="
/bin/date

echo "==== Section: Running on $(/bin/hostname) Node ========"

echo "=== Section: Pull amdih/specfem3d docker container ======"
singularity pull --docker-login specfem3d_9c0626d1.sif docker://amdih/specfem3d:9c0626d1
echo "Pull complete"

echo " ========== Section: Run example script using singularity =========="
singularity run --writable-tmpfs specfem3d_9c0626d1.sif /bin/bash -c "cd /opt/specfem3d/EXAMPLES/homogeneous_poroelastic/; ./run_this_example.sh"
echo " ========== Run Complete =========="

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


echo "==== Using $ROCM_VERSION to collect ROCm information.==== "
$ROCM_VERSION/bin/rocm-smi
$ROCM_VERSION/bin/rocm-smi --showhw

echo "===== Section: Show logs ==========="
/bin/dmesg | grep -E 'gpu|pcie' | tail -100
