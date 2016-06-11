---
layout: page
title: Workflows on HPC systems
subtitle: High-throughput
minutes: 50
---

> ## Learning Objectives {.objectives}
>
> * Learn to break a job up into parts to reduce execution time
> * Learn to use the debug queue to ensure the job is running
> * Learn job dependencies to ensure correct job ordering

Create submission shell script submit-stats-workflow.sh

~~~
# Calculate reduced stats for A and Site B data files at J = 100 c/bp
for datafile in [AB].txt
do
	qsub -v datafile=$datafile run-stats.sh
done
~~~

Create job script run-stats.sh

~~~
cd $HOME/script-data
echo $datafile
bash goostats -J 100 -r $datafile stats-$datafile
~~~

Make sure run-stats.sh works correctly

~~~ {.bash}
$ debug
~~~
~~~ {.output}
qsub: waiting for job 103248.mountaineer to start
qsub: job 103248.mountaineer ready

[mcarlise@compute-01-25 ~]$
~~~

Set up environment and run an instance of the script

~~~ {.bash}
$ export datafile=NENE01729A.txt
$ cd $HOME/script-data
$ bash run-stats.sh
~~~
~~~ {.output}
NENE01729A.txt
~~~

Check the output

~~~ {.bash}
$ pwd
$ ls
~~~
~~~ {.output}
/users/mcarlise/script-data

do-stats.sh  goostats        NENE01729B.txt  NENE01751A.txt  NENE01843B.txt  stats-NENE01729A.txt
goodiff      NENE01729A.txt  NENE01736A.txt  NENE01751B.txt  run-stats.sh    submit-stats-workflow.sh
~~~

You can see that stats-NENE01729A.txt exists.  And you can verify the output 
using the `less` or `cat` command.

Submit the entire workflow

~~~ {.bash}
$ bash submit-stats-workflow.sh
~~~
~~~ {.output}
103250.mountaineer
103251.mountaineer
103252.mountaineer
103253.mountaineer
103254.mountaineer
103255.mountaineer
103256.mountaineer
~~~

Verify all the running jobs

~~~ {.bash}
$ showq -u training01
~~~
~~~ {.output}
active jobs------------------------
JOBID              USERNAME      STATE PROCS   REMAINING            STARTTIME

103250             mcarlise    Running     1     1:59:47  Sat Jun 11 16:33:12
103251             mcarlise    Running     1     1:59:47  Sat Jun 11 16:33:12
103253             mcarlise    Running     1     1:59:47  Sat Jun 11 16:33:12
103252             mcarlise    Running     1     1:59:47  Sat Jun 11 16:33:12
103256             mcarlise    Running     1     1:59:47  Sat Jun 11 16:33:12
103254             mcarlise    Running     1     1:59:47  Sat Jun 11 16:33:12
103255             mcarlise    Running     1     1:59:47  Sat Jun 11 16:33:12

7 active jobs             7 of 384 processors in use by local jobs (1.82%)
						  22 of 32 nodes active      (68.75%)

eligible jobs----------------------
JOBID              USERNAME      STATE PROCS     WCLIMIT            QUEUETIME


0 eligible jobs   

blocked jobs-----------------------
JOBID              USERNAME      STATE PROCS     WCLIMIT            QUEUETIME


0 blocked jobs   

Total jobs:  7
~~~

You can use `ls` to verify that all the stats files appeared.  You can use the 
`ls -l` command to check if any errors occurred.

~~~ {.bash}
$ ls -l run-stats.sh.e??????
~~~
~~~ {.output}
-rw------- 1 mcarlise wvu-hpc 0 Jun 11 16:33 run-stats.sh.e103250
-rw------- 1 mcarlise wvu-hpc 0 Jun 11 16:33 run-stats.sh.e103251
-rw------- 1 mcarlise wvu-hpc 0 Jun 11 16:33 run-stats.sh.e103252
-rw------- 1 mcarlise wvu-hpc 0 Jun 11 16:33 run-stats.sh.e103253
-rw------- 1 mcarlise wvu-hpc 0 Jun 11 16:33 run-stats.sh.e103254
-rw------- 1 mcarlise wvu-hpc 0 Jun 11 16:33 run-stats.sh.e103255
-rw------- 1 mcarlise wvu-hpc 0 Jun 11 16:33 run-stats.sh.e103256
~~~

You can see all the error output files have a size of 0.  
