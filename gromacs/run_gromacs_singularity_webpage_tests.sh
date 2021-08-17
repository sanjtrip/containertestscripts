##!/bin/sh
#
#Copyright (c) 2021 Advanced Micro Devices, Inc. All Rights Reserved.
#Author: Siddharth Srinivasan, Sid.srinivasan@amd.com
#Version: V2.0
#
#This script runs the Gromacs test commands for docker container
#
#To run the script, download the script using wget then:
#       sh ./run_gromacs_singularity_webpage__tests.sh
#

echo "=== GROMACS Log Collection Utility: V2.0 ==="
/bin/date

echo "==== Section: Running on $(/bin/hostname) Node ========"

echo "======== Section: Show which GPU running script on =========== "
rocminfo | grep gfx

echo "=== Section: Pull amdih/gromacs docker container ======"
singularity pull gromacs_version_tags.sif docker://amdih/gromacs:2020.3
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

echo "======== Section: Rum Gromacs with adh_dodec script using MPI using singularity =========="
singularity run ./gromacs_version_tags.sif gmx grompp -f /benchmarks/data/tmpi/adh_dodec/pme_verlet.mdp -c /benchmarks/data/tmpi/adh_dodec/conf.gro -p /benchmarks/data/tmpi/adh_dodec/topol.top -maxwarn 20

singularity run ./gromacs_version_tags.sif mpirun -np 2 gmx_mpi mdrun -nsteps 100000 -resetstep 90000 -ntomp 24 -noconfout -nb gpu -bonded cpu -pme gpu -npme 1 -v -nstlist 400 -gpu_id 0 -s $(pwd)/topol.tpr
echo "========= Script adh_dodec using MPI run Complete"

echo " =========== Section: Run Gromacs adh_dodc script using threaded MPI using singularity ==========="
singularity run ./gromacs_version_tags.sif gmx grompp -f /benchmarks/data/tmpi/adh_dodec/pme_verlet.mdp -c /benchmarks/data/tmpi/adh_dodec/conf.gro -p /benchmarks/data/tmpi/adh_dodec/topol.top -maxwarn 20

singularity run ./gromacs_version_tags.sif gmx mdrun -pin on -nsteps 100000 -resetstep 90000 -ntmpi 2 -ntomp 28 -noconfout -nb gpu -bonded cpu -pme gpu -npme 1 -v -gpu_id 0 -s $(pwd)/topol.tpr
echo "========= Section: adh_dodec script using threaded MPI complete ==========="

echo "==== Using $ROCM_VERSION to collect ROCm information.==== "
$ROCM_VERSION/bin/rocm-smi
$ROCM_VERSION/bin/rocm-smi --showhw

echo "===== Section: Show logs ==========="
/bin/dmesg | grep -E 'gpu|pcie' | tail -100
