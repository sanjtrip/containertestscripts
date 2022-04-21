!/bin/sh
#
#Copyright (c) 2021 Advanced Micro Devices, Inc. All Rights Reserved.
#Author: Siddharth Srinivasan, Sid.srinivasan@amd.com
#Version: V1.0
#
#This script runs the NAMD test commands for docker container
#
#To run the script, download the script using wget then:
#       sh ./run_namd_docker_webpage_tests.sh
#

echo "=== NAMD Log Collection Utility: V2.0 ==="
/bin/date

echo "==== Section: Running on $(/bin/hostname) Node ========"

echo "===== Section: Show which GPU system running scripts on ========== "
rocminfo | grep gfx

echo "=== Section: Pull amdih/namd docker container ======="
docker pull amdih/namd:2.15a2-20211101
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

echo "========= Section: Run NAMD benchmark scripts in interactive mode ============"
docker run --rm -it --device=/dev/kfd --device=/dev/dri --security-opt seccomp=unconfined amdih/namd:2.15a2 /bin/bash -c "cd /examples; /opt/namd/bin/namd2 jac/jac.namd +p64 +setcpuaffinity +devices 0 > jac.log; /opt/namd/bin/namd2 apoa1/apoa1.namd +p64 +setcpuaffinity +devices 0 > apoa1.log; /opt/namd/bin/namd2 f1atpase/f1atpase.namd +p64 +setcpuaffinity +devices 0 > f1atpase.log; /opt/namd/bin/namd2 stmv/stmv.namd +p64 +setcpuaffinity +devices 0 > stmv.log; ./ns_per_day.py jac.log; ./ns_per_day.py apoa1.log; ./ns_per_day.py f1atpase.log; ./ns_per_day.py stmv.log"
echo " ============= Section: NAMD benchmark scripts complete =========== "

echo "========= Section: Run NAMD benchmark scripts in non-interactive mode ========"
docker run --rm --device=/dev/kfd --device=/dev/dri --security-opt seccomp=unconfined amdih/namd:2.15a2 namd2 /examples/apoa1/apoa1.namd +p 32 +pemap 0-31 +setcpuaffinity +isomalloc_sync +devices 0
echo "======== Section: NAMD benchmark script complete in non-interactive mode ========="

echo "========== Section: Run NAMD benchmarck non-interactive using mount ============ "
docker run --rm --device=/dev/kfd --device=/dev/dri --security-opt seccomp=unconfined -v $(pwd)/apoa1/:/apoa1 amdih/namd:2.15a2 namd2 /examples/apoa1/apoa1.namd +p64 +setcpuaffinity +devices 0
echo "============ Section: Script Complete ========= "

echo "========== Section: Run NAMD benchmarck interactive using mount =========== "
docker run --rm -it --device=/dev/kfd --device=/dev/dri --security-opt seccomp=unconfined -v $(pwd)/apoa1/:/apoa1 amdih/namd:2.15a2 /bin/bash -c "cd /apoa1; /opt/namd/bin/namd2 +p64 +setcpuaffinity +devices 0,1 apoa1.namd |& tee apoa1.log"
echo "============ Section: Script Complete ========= "

echo "==== Using $ROCM_VERSION to collect ROCm information.==== "
$ROCM_VERSION/bin/rocm-smi
$ROCM_VERSION/bin/rocm-smi --showhw

echo "======== Section: print logs ========"
/bin/dmesg | grep -E 'gpu|pcie' | tail -100






