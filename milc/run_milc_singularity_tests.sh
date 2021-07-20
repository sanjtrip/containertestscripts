#!/bin/sh

# Copyright (c) 2021 Advanced Micro Devices, Inc. All Rights Reserved.

mkdir -p out
singularity pull --docker-login milc_12ddd7d9.sif docker://amdih/milc:12ddd7d9

singularity run --pwd /benchmark --bind $(pwd)/out:/tmp/bench --writable-tmpfs milc_12ddd7d9.sif run-benchmark -o /tmp/bench/bench-np1.txt 

