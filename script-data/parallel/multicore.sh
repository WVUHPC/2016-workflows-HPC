#!/bin/bash

#PBS -q debug
#PBS -l nodes=1:ppn=4

# Set up namd environment manually
NAMD=/shared/software/chemistry/namd/2.11-multicore/namd2

# Move into your directory
cd $HOME/test/apoa1

$NAMD +p4 apoa1.namd > single_core
