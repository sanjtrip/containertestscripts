#!/bin/sh

# Copyright (c) 2021 Advanced Micro Devices, Inc. All Rights Reserved.

docker pull amdih/milc:12ddd7d9

mkdir -p out

docker run --rm -it --device /dev/dri --device /dev/kfd --security-opt seccomp=unconfined amdih/milc:12ddd7d9 /bin/bash -c "cd /benchmark; run-benchmark -o milc-benchmark.out"

