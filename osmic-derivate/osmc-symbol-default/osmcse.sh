cd ~/osm/generator/nbh
files=`ls */*-latest.osm.pbf`

tempfile="osmc_symbols.lst"
workfile="osmc_symbols.wrk"

rm $tempfile $workfile
touch $tempfile

echo "searching osmc:symbol tags"
for file in $files; do
	echo "  $file"
	rm $tempfile
	./osmconvert $file | grep -F 'k="osmc:symbol' | sort -u >> $tempfile
	cat $tempfile >> $workfile
done

sort -u $workfile | awk '{print $3}' | cut -d: -f2-3 | sort -u | sed 's/v="//' | sed 's/"\/>//' > $tempfile
rm $workfile
