#!/bin/bash

tmwtf="tmw.tmp"
tmntf="tmn.tmp"
mxtf="mx.tmp"

# pozor, je treba priradit equivalent values !!!
set -f

sed '/<*!--.\+--/d' $1 | sed '/!--/,/--/d' | sed -n '/<ways>/,/<\/ways>/p' | grep '<osm-tag' | grep -v 'enabled="false"' | sed 's/^\s*//' | awk '{print $2,$3}' | sort -u > $tmwtf
sed '/<*!--.\+--/d' $1 | sed '/!--/,/--/d' | sed -n '/<pois>/,/<\/pois>/p' | grep '<osm-tag' | grep -v 'enabled="false"' | sed 's/^\s*//' | awk '{print $2,$3}' | sort -u > $tmntf

sed '/<*!--.\+--/d' $2 | sed '/!--/,/--/d' | grep '<rule' | grep -v 'enabled="false"' | sed 's/^\s*//' | awk '{print $3,$4,$2}' | tr -d '>' | sort -u | sed 's/\*/.*/g' > $mxtf
#| sed 's/\*/\x27.*\x27/g'

SAVEIFS=$IFS

while read okey ovalue otype; do
	key=`echo "$okey" | cut -d '"' -f2`
	value=`echo "$ovalue" | cut -d '"' -f2`
	type=`echo "$otype" | cut -d '"' -f2`
	
	#if [ "$key" = "*" ] || [ "$value" = "~" ] || [ "$value" = "*" ]; then
		#echo "Skipping:" "$key" "$value"
	#	continue
	#fi
		
	IFS='|'
	for k in $key; do
		IFS=$SAVEIFS
		if [ "$k" = "*" ]; then
			continue
		fi
		IFS='|'
		for v in $value; do
			counter=0
			IFS=$SAVEIFS
			if [ "$v" = "~" ]; then
				#echo "skipping $v"
				continue
			fi
			#echo " " "$k" "$v"
			if [ "$type" = "way" ]; then
				grep -q "key=\"$k\"\s*value=\"$v\"" $tmwtf
				if [ $? -eq 0 ]; then
					counter=$((counter+1))
				fi
			elif [ "$type" = "node" ]; then
				grep -q "key=\"$k\"\s*value=\"$v\"" $tmntf
				if [ $? -eq 0 ]; then
					counter=$((counter+1))
				fi
			elif [ "$type" = "any" ]; then
				grep -q "key=\"$k\"\s*value=\"$v\"" $tmwtf
				if [ $? -eq 0 ]; then
					counter=$((counter+1))
				fi
				
				grep -q "key=\"$k\"\s*value=\"$v\"" $tmntf
				if [ $? -eq 0 ]; then
					counter=$((counter+1))
				fi
			fi
			if [ $counter -eq 0 ]; then
				echo "$k" "$v"
			fi
		done		
		
	done
done < $mxtf

rm $mxtf $tmntf $tmwtf

