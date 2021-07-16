#!/bin/sh

# Copyright (c) 2021 Advanced Micro Devices, Inc. All Rights Reserved.
#docker login

docker pull amdih/openmm:7.4.2

#docker logout

docker run --rm -it --device=/dev/kfd --device=/dev/dri --security-opt seccomp=unconfined amdih/openmm:7.4.2 /bin/bash -c "run-benchmarks"

OPENMM_PATH=/opt/openmm

docker run --rm -it --device=/dev/kfd --device=/dev/dri --security-opt seccomp=unconfined amdih/openmm:7.4.2 /bin/bash -c "python3 $OPENMM_PATH/examples/benchmark.py --help"

docker run --rm -it --device=/dev/kfd --device=/dev/dri --security-opt seccomp=unconfined amdih/openmm:7.4.2 run-benchmarks

mkdir -p sim

cd sim/

cat > amd_openmm_sim.py

docker run -it --device=/dev/kfd --device=/dev/dri --security-opt seccomp=unconfined -v `pwd`:/sim amdih/openmm:7.4.2 /bin/bash -c "cp ./opt/openmm/examples/input.pdb /sim"

docker run --rm -it --device /dev/dri --device /dev/kfd  --security-opt seccomp=unconfined -v `pwd`:/sim -w /sim amdih/openmm:7.4.2 python3 amd_openmm_sim.py

