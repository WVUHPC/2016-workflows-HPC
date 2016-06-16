#!/bin/bash

#PBS -l nodes=1:ppn=16

### load ibverbs version of NAMD
module load mpi/intel/4.1.1.036
module load chemistry/namd/mpi

### set directory for job execution, ~netid = home directory path
cd /users/mcarlise/test/apoa1

### run your executable program with begin and end date and time output
mpirun -np 16 -hostfile $PBS_NODESFILE $NAMD apoa1.namd > singlenode.log

