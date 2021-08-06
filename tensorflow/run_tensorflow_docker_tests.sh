#!/bin/sh
#
#Copyright (c) 2021 Advanced Micro Devices, Inc. All Rights Reserved.
#Author: Siddharth Srinivasan, Sid.srinivasan@amd.com
#Version: V1.0
#
#This script runs the TensorFlow test commands for docker container
#
#To run the script, download the script using wget then:
#       sh ./run_tensorflow_docker_tests.sh
#


echo "=== TensorFlow Log Collection Utility: V1.0 ==="
/bin/date

echo "==== Section: Running on $(/bin/hostname) Node ========"

echo "=== Section: Pull amdih/milc docker container ======"
docker pull amdih/tensorflow:rocm4.2-tf2.5-dev
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

echo " =========== Section: Run TensorFlow docker container in interactive mode ========="
docker run -it --network=host --device=/dev/kfd --device=/dev/dri --ipc=host --shm-size 16G --group-add video --cap-add=SYS_PTRACE --security-opt seccomp=unconfined --rm -v $HOME/dockerx:/dockerx amdih/tensorflow:rocm4.2-tf2.5-dev -c "ls"
echo " ========== Docker ran succesfully in interactive mode ========= "

echo " ========== Section: Run TensorFlow docker container in non interactive mode =========== "
docker run --network=host --device=/dev/kfd --device=/dev/dri --ipc=host --shm-size 16G --group-add video --cap-add=SYS_PTRACE --security-opt seccomp=unconfined --rm -v $HOME/dockerx:/dockerx amdih/tensorflow:rocm4.2-tf2.5-dev "ls"
echo " ========== Docker ran sucessfully in non interactive mode ========== "

echo "==== Using $ROCM_VERSION to collect ROCm information.==== "
$ROCM_VERSION/bin/rocm-smi
$ROCM_VERSION/bin/rocm-smi --showhw

echo "===== Section: Show logs ==========="
/bin/dmesg | grep -E 'gpu|pcie' | tail -100

