##!/bin/sh
#
#Copyright (c) 2021 Advanced Micro Devices, Inc. All Rights Reserved.
#Author: Siddharth Srinivasan, Sid.srinivasan@amd.com
#Version: V1.0
#
#This script runs the Gromacs test commands for docker container
#
#To run the script, download the script using wget then:
#       sh ./run_gromacs_docker_tests.sh
#

echo "=== MILC Log Collection Utility: V2.0 ==="
/bin/date

echo "==== Section: Running on $(/bin/hostname) Node ========"

echo "=== Section: Pull amdih/gromacs docker container ======"
docker pull amdih/gromacs:2020.3
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

echo "======== Section: Rum Gromacs docker adh_dodec benchmark script in interactive mode =========="
docker run --rm -it --device=/dev/kfd --device=/dev/dri --security-opt seccomp=unconfined  amdih/gromacs:2020.3 /bin/bash -c "cd /benchmarks/data/mpi/adh_dodec; gmx_mpi grompp -f pme_verlet.mdp -c conf.gro -p topol.top -maxwarn 20; mpirun --allow-run-as-root -np 2 gmx_mpi mdrun -nsteps 100000 -resetstep 90000 -ntomp 24 -noconfout -nb gpu -bonded cpu -pme gpu -npme 1 -v -nstlist 400 -gpu_id 0 -s topol.tpr; gmx_mpi grompp -f pme_verlet.mdp -c conf.gro -p topol.top -maxwarn 20; mpirun --allow-run-as-root -np 4 gmx_mpi mdrun -pin on -nsteps 100000 -resetstep 90000 -ntomp 12 -noconfout -nb gpu -bonded cpu -pme gpu -npme 1 -v --gputasks 0001 -s topol.tpr; gmx_mpi grompp -f pme_verlet.mdp -c conf.gro -p topol.top -maxwarn 20; # mpirun --allow-run-as-root -np 8 gmx_mpi mdrun -pin on -nsteps 100000 -resetstep 90000 -ntomp 4 -noconfout -nb gpu -bonded cpu -pme gpu -npme 1 -v  --gputasks 00011223" 
echo "========= Script run Complete"

echo " =========== Section: Run Gromacs STMV benchmark script in interactive mode ==========="
docker run --rm -it --device=/dev/kfd --device=/dev/dri --security-opt seccomp=unconfined  amdih/gromacs:2020.3 /bin/bash -c "cd /benchmarks/data/mpi/stmv; gmx_mpi grompp -f pme_verlet.mdp -c stmv.gro -p stmv.top -maxwarn 20; gmx mdrun -pin on -nsteps 100000 -resetstep 90000 -ntmpi 2 -ntomp 28 -noconfout -nb gpu -bonded cpu -pme gpu -npme 1 -v -gpu_id 0 -s topol.tpr; gmx_mpi grompp -f pme_verlet.mdp -c stmv.gro -p stmv.top -maxwarn 20; gmx mdrun -pin on -nsteps 100000 -resetstep 90000 -ntmpi 4 -ntomp 16 -noconfout -nb gpu -bonded gpu -pme gpu -npme 1 -v -gpu_id 01 -s topol.tpr; gmx_mpi grompp -f pme_verlet.mdp -c stmv.gro -p stmv.top -maxwarn 20; gmx mdrun -pin on -nsteps 100000 -resetstep 90000 -ntmpi 4 -ntomp 18 -noconfout -nb gpu -bonded gpu -pme gpu -npme 1 -v -gpu_id 0123 -s topol.tpr"
echo "========= Section: STMV Script complete ==========="

echo "========= Section: Run ADH_DODEC benchmark Script non-interactive mode ==========="
mkdir -p out
docker run --device=/dev/dri --device=/dev/kfd --security-opt seccomp=unconfined --rm -v $(pwd)/out:/out -w /out amdih/gromacs:2020.3 gmx grompp -f /benchmarks/data/tmpi/adh_dodec/pme_verlet.mdp -c /benchmarks/data/tmpi/adh_dodec/conf.gro -p /benchmarks/data/tmpi/adh_dodec/topol.top -maxwarn 20
echo " =========== Section: adh_dodec script complete =========="

echo " ======== Section: Run STMV becnhmark script in non-interactive mode ======== "
mkdir -p out
docker run --device=/dev/dri --device=/dev/kfd --security-opt seccomp=unconfined --rm -v $(pwd)/out:/out -w /out amdih/gromacs:2020.3 gmx mdrun -pin on -nsteps 100000 -resetstep 90000 -ntmpi 2 -ntomp 28 -noconfout -nb gpu -bonded cpu -pme gpu -npme 1 -v -gpu_id 0 -s topol.tpr
echo " ============ Section: Run STMV benchmark script complete ========"

echo "==== Using $ROCM_VERSION to collect ROCm information.==== "
$ROCM_VERSION/bin/rocm-smi
$ROCM_VERSION/bin/rocm-smi --showhw

echo "===== Section: Show logs ==========="
/bin/dmesg | grep -E 'gpu|pcie' | tail -100
