
# Calculate reduced stats for A and Site B data files at J = 100 c/bp
for datafile in stats-*[AB].txt
do
	echo $datafile
	bash goodiff $datafile validated-data.txt > diff-$datafile
done
