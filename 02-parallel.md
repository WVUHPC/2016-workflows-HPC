---
layout: page
title: Parallel computing
---

## Run single core namd

~~~ {.bash}
$ qsub -q training multicore.sh
~~~

Run at single core and 4 core.

## Run MPI namd

~~~ {.bash}
$ qsub mpi.sh
~~~

Run at 16 cores and 32 cores (single node and multiple nodes)


> ## Different physical executables {.callout}
>
> [NAMD download 
> page](http://www.ks.uiuc.edu/Development/Download/download.cgi?PackageName=NAMD)
