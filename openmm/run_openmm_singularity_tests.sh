#!/bin/sh

# Copyright (c) 2021 Advanced Micro Devices, Inc. All Rights Reserved.

cd ~

singularity pull openmm_version_tags.sif docker://amdih/openmm:7.4.2

singularity run ./openmm_version_tags.sif run-benchmarks

singularity run --pwd $(pwd) ./openmm_version_tags.sif python3 simulation.py
