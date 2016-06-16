
# Calculate reduced stats for A and Site B data files at J = 100 c/bp
for datafile in *[AB].txt
do
	echo $datafile
	bash goostats -J 100 -r $datafile stats-$datafile
done
