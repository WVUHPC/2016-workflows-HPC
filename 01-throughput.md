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

## Adding a second job to the workflow

The workflow is not complete at only doing the stats part.  We also have 
another program to run called `goodiff`.  `goodiff` compares the output of 
`goostat` to a validated dataset and either outputs the difference or tells us 
they are identical.  The shell script to run `goodiff` is located as 
`do-diff.sh`:

~~~
	# Calculate reduced stats for A and Site B data files at J = 100 c/bp
	for datafile in stats-*[AB].txt
	do
		echo $datafile
		bash goodiff $datafile validated-data.txt > diff-$datafile
	done
~~~

As with do-stats.sh.  We need to break this up into a script that runs only 
goodiff, and a script that runs `qsub` to launch all of the jobs.

~~~
	# Calculate reduced stats for A and Site B data files at J = 100 c/bp
	for datafile in stats-*[AB].txt
	do
		qsub -v datafile=$datafile run-diff.sh
	done
~~~

run-diff.sh

~~~
	cd $HOME/script-data
	echo $datafile
	bash goodiff $datafile validated-data.txt > diff-$datafile
~~~

This is very similar to how we did the stats portion of the workflow.  Now, we 
can use the debug queue to make sure run-diff.sh works correctly given a single 
datafile.

~~~ {.bash}
$ debug -v datafile=stats-NENE01729A.txt
~~~
~~~ {.output}
$ qsub: waiting for job 103269.mountaineer to start
qsub: job 103269.mountaineer ready

[mcarlise@compute-01-25 ~]$
~~~

Verify the value of datafile, and run run-diff.sh to make sure it works

~~~ {.bash}
$ cd $HOME/script-data
$ echo $datafile
$ bash run-diff.sh
$ cat diff-stats-NEN01729A.txt
~~~

Typing `exit` will get you out of the job.  Submit entire workflow.

~~~ {.bash}
$ bash submit-diff-workflow.sh
~~~
~~~ {.output}
103271.mountaineer
103272.mountaineer
103273.mountaineer
103274.mountaineer
103275.mountaineer
103276.mountaineer
~~~

You can use `showq` to verify that the jobs are queued/running.

~~~ {.bash}
	$ cat diff-stats-NENE01*
~~~
~~~ {.output}
0.21598
0.3136
0.29846
0.1382
0.29863
0.4571
~~~

## Automating through job dependencies

We had to execute two submit bash scripts that run qsub commands.  This is to 
ensure that the `goostats` program runs before the `goodiff` program.  However, 
this requires that you run the `goostats` portion.  Wait until it finishes, and 
come back later to run the `goostats` part.  If you have 10 or 12 steps of the 
workflow, this can add a considerable amount of time.  

Combine the submit workflow scripts.

~~~
	# Calculate reduced stats for A and Site B data files at J = 100 c/bp
	for datafile in *[AB].txt
	do
		JOBID=`qsub -v datafile=$datafile run-stats.sh`
		qsub -v datafile=stats-$datafile -W depend=afterok:$JOBID run-diff.sh
	done
~~~

Capturing a commands output.  `-W` option allows you to define attributes of 
the job.  One of them is dependencies.  This instance, the second submitted job 
(running `goodiff`) will not run until after the `run-stats.sh` job completes 
and without error.

~~~ {.bash}
$ bash submit-stats-workflow.sh
~~~

~~~ {.output}
103284.mountaineer
103286.mountaineer
103288.mountaineer
103290.mountaineer
103292.mountaineer
103294.mountaineer
~~~

Notice that you only get 6 jobIDs.  Additionally, they skip a number.

~~~ {.bash}
$ showq -u training01
~~~
~~~ {.output}
active jobs------------------------
JOBID              USERNAME      STATE PROCS   REMAINING            STARTTIME

103293             mcarlise    Running     1     1:59:55  Sun Jun 12 13:25:50
103291             mcarlise    Running     1     1:59:55  Sun Jun 12 13:25:50
103285             mcarlise    Running     1     1:59:55  Sun Jun 12 13:25:50
103289             mcarlise    Running     1     1:59:55  Sun Jun 12 13:25:50
103287             mcarlise    Running     1     1:59:55  Sun Jun 12 13:25:50
103283             mcarlise    Running     1     1:59:55  Sun Jun 12 13:25:50

6 active jobs             6 of 384 processors in use by local jobs (1.56%)
						  21 of 32 nodes active      (65.62%)

eligible jobs----------------------
JOBID              USERNAME      STATE PROCS     WCLIMIT            QUEUETIME


0 eligible jobs   

blocked jobs-----------------------
JOBID              USERNAME      STATE PROCS     WCLIMIT            QUEUETIME

103284             mcarlise       Hold     1     2:00:00  Sun Jun 12 13:25:10
103286             mcarlise       Hold     1     2:00:00  Sun Jun 12 13:25:10
103288             mcarlise       Hold     1     2:00:00  Sun Jun 12 13:25:10
103290             mcarlise       Hold     1     2:00:00  Sun Jun 12 13:25:10
103292             mcarlise       Hold     1     2:00:00  Sun Jun 12 13:25:11
103294             mcarlise       Hold     1     2:00:00  Sun Jun 12 13:25:11

6 blocked jobs   

Total jobs:  12
~~~

Notice 6 blocked jobs.  They are not eligible until after the previous running 
jobs complete.  The scheduler is ensuring the correct job order.

Check your output

~~~ {.bash}
	$ cat diff-stats-NENE01*
~~~
~~~ {.output}
0.1531
0.12977
0.26874
0.27960
0.9072
0.10941
~~~

You get the difference of 6 datasets.  Exactly what we expect.


> ## Better organization {.challenge}
>
>  Can we re-write the scripts to have a better organization.  Instead of 
>  dumping everything to a single directory.
