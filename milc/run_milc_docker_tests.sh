#!/bin/sh
#
#Copyright (c) 2021 Advanced Micro Devices, Inc. All Rights Reserved.
#Author: Siddharth Srinivasan, Sid.srinivasan@amd.com
#Version: V1.0
#
#This script runs the MILC test commands for docker container
#
#To run the script, download the script using wget then:
#	sh ./run_milc_docker_tests.sh
#

echo "Pull amdih/milc docker container"
docker pull amdih/milc:12ddd7d9
echo "Pull complete"

echo "Create an out directory"
mkdir -p out

echo "Run the milc docker and run the run-benchmark script and output to milc-benchmark.out"
docker run --rm -it --device /dev/dri --device /dev/kfd -v `pwd`/out:/benchmark/out --security-opt seccomp=unconfined amdih/milc:12ddd7d9 /bin/bash -c "cd /benchmark; run-benchmark -o milc-benchmark.out"

