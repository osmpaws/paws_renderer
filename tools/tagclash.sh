files=`ls */*-latest.osm.pbf`

tempfile="commontags.tmp"
workfile="commontags.wrk"
mappingfile="commontags.tma"

rm $tempfile
touch $tempfile

unzip ~/.openstreetmap/osmosis/plugins/mapsforge-map-writer-0.15.0-jar-with-dependencies.jar tag-mapping.xml
sed '/<*!--.\+--/d' tag-mapping.xml | grep '<osm-tag' | sed '/!--/,/--/d' | grep -v 'enabled="false"' | sed 's/.* key=\(".*"\) .*value="\(.*\)" .*/\1 "\2"/' | awk '{print $1,$2}' | sort -u > $mappingfile

cp $mappingfile $tempfile
while read key value; do
	common=`grep -F " $value" $tempfile | grep -v $key`
	count=`echo "$common" | sed '/^$/d' | wc -l`
	if [ $count -gt 0 ]; then
		echo "$key" "$value" $count
		echo "$common" | awk '{print "  ",$1,$2}'
	fi
	
	echo "$key $value\n$common" | sed '/^$/d' | grep -vF -f - $tempfile > $workfile
	cp $workfile $tempfile
	counter=$((counter+1))
done < $mappingfile
