#!/bin/sh
#
#Copyright (c) 2021 Advanced Micro Devices, Inc. All Rights Reserved.
#Author: Siddharth Srinivasan, Sid.srinivasan@amd.com
#Version: V1.0
#
#This script runs the PyTorch test commands for docker container
#
#To run the script, download the script using wget then:
#       sh ./run_pytorch_docker_tests.sh
#


echo "=== PyTorch Log Collection Utility: V1.0 ==="
/bin/date

echo "==== Section: Running on $(/bin/hostname) Node ========"

echo "=== Section: Pull amdih/pytorch docker container ======"
docker pull amdih/pytorch:rocm4.2_ubuntu18.04_py3.6_pytorch_1.9.0
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

echo " =========== Section: Run PyTorch docker container in interactive mode ========="
docker run --device=/dev/kfd --device=/dev/dri --group-add video --shm-size=4g --cap-add=SYS_PTRACE --security-opt seccomp=unconfined --ipc=host -it --rm -v $(pwd)/scripts:/scripts amdih/pytorch:rocm4.2_ubuntu18.04_py3.6_pytorch_1.9.0 -c "ls"
echo " ========== Docker ran succesfully in interactive mode ========= "

echo " ========== Section: Run PyTorch docker container in non interactive mode =========== "
docker run --device=/dev/kfd --device=/dev/dri --group-add video --shm-size=4g --cap-add=SYS_PTRACE --security-opt seccomp=unconfined --ipc=host --rm -v $(pwd)/scripts:/scripts amdih/pytorch:rocm4.2_ubuntu18.04_py3.6_pytorch_1.9.0 "ls"
echo " ========== Docker ran sucessfully in non interactive mode ========== "

echo "==== Using $ROCM_VERSION to collect ROCm information.==== "
$ROCM_VERSION/bin/rocm-smi
$ROCM_VERSION/bin/rocm-smi --showhw

echo "===== Section: Show logs ==========="
/bin/dmesg | grep -E 'gpu|pcie' | tail -100

