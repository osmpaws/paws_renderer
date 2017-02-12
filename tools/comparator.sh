#!/bin/bash

tmwtf="tmw.tmp"
tmntf="tmn.tmp"
mxtf="mx.tmp"
lineseparator="--- --- --- ---"

# pozor, je treba priradit equivalent values !!!
set -f

sed '/<*!--.\+--/d' $1 | sed '/!--/,/--/d' | sed -n '/<ways>/,/<\/ways>/p' | grep '<osm-tag' | grep -v 'enabled="false"' | sed 's/^\s*//' | sed 's/,/|/g' | sed 's/"\s*equivalent_values="//' | awk '{print $2,$3}' | sort -u > $tmwtf
sed '/<*!--.\+--/d' $1 | sed '/!--/,/--/d' | sed -n '/<pois>/,/<\/pois>/p' | grep '<osm-tag' | grep -v 'enabled="false"' | sed 's/^\s*//' | sed 's/,/|/g' | sed 's/"\s*equivalent_values="//' | awk '{print $2,$3}' | sort -u > $tmntf

sed '/<*!--.\+--/d' $2 | sed '/!--/,/--/d' | grep '<rule' | grep -v 'enabled="false"' | sed 's/^\s*//' | awk '{print $3,$4,$2}' | tr -d '>' | sort -u | sed 's/\*/.*/g' > $mxtf
#| sed 's/\*/\x27.*\x27/g'

SAVEIFS=$IFS

ways=" "
pois=" "
while read okey ovalue otype; do
	key=`echo "$okey" | cut -d '"' -f2`
	value=`echo "$ovalue" | cut -d '"' -f2`
	type=`echo "$otype" | cut -d '"' -f2`
	
	if [ "$key" = ".*" ] && [ "$value" = ".*" ]; then
		#echo "Skipping:" "$key" "$value"
		continue
	fi
		
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
					lineno=`grep -n "key=\"$k\"\s*value=\"$v\"" $tmwtf | cut -d: -f1`
					ways="$ways $lineno"
					#echo $k $v $lineno >> wayln.txt
				fi
			elif [ "$type" = "node" ]; then
				grep -q "key=\"$k\"\s*value=\"$v\"" $tmntf
				if [ $? -eq 0 ]; then
					counter=$((counter+1))
					lineno=`grep -n "key=\"$k\"\s*value=\"$v\"" $tmntf | cut -d: -f1`
					pois="$pois $lineno"
					#echo $k $v $lineno >> poiln.txt
				fi
			elif [ "$type" = "any" ]; then
				grep -q "key=\"$k\"\s*value=\"$v\"" $tmwtf
				if [ $? -eq 0 ]; then
					counter=$((counter+1))
					lineno=`grep -n "key=\"$k\"\s*value=\"$v\"" $tmwtf | cut -d: -f1`
					ways="$ways $lineno"
					#echo $k $v $lineno >> wayln.txt
				fi
				
				grep -q "key=\"$k\"\s*value=\"$v\"" $tmntf
				if [ $? -eq 0 ]; then
					counter=$((counter+1))
					lineno=`grep -n "key=\"$k\"\s*value=\"$v\"" $tmntf | cut -d: -f1`
					pois="$pois $lineno"
					#echo $k $v $lineno >> poiln.txt
				fi
			fi
			
			if [ $counter -eq 0 ]; then
				echo "- $k=$v $type http://taginfo.openstreetmap.org/tags/$k=$v"
			fi
		done		
		
	done
done < $mxtf

#echo $pois
#echo "--"
#echo $ways

pois="$pois "
ways="$ways "
echo $lineseparator
pois=`echo $pois | tr ' ' '\n' | sort -un | tr '\n' ' '`
counter=1
while read line; do
	echo $pois | grep -q "\b$counter\b"
	if [ $? -ne 0 ]; then
		key=`echo "$line" | cut -d '"' -f2`
		value=`echo "$line" | cut -d '"' -f4`
		echo "+ $key=$value node http://taginfo.openstreetmap.org/tags/$key=$value"
	fi
	counter=$((counter+1))
done < $tmntf

echo $lineseparator
ways=`echo $ways | tr ' ' '\n' | sort -un | tr '\n' ' '`
counter=1
while read line; do
	echo $ways | grep -q "\b$counter\b"
	if [ $? -ne 0 ]; then
		key=`echo "$line" | cut -d '"' -f2`
		value=`echo "$line" | cut -d '"' -f4`
		echo "+ $key=$value way http://taginfo.openstreetmap.org/tags/$key=$value"
	fi
	counter=$((counter+1))
done < $tmwtf

#wc -l $tmntf 
#echo $pois | tr ' ' '\n' | wc -l
#echo $pois | tr ' ' '\n' | head -n1
#echo $pois | tr ' ' '\n' | tail -n1
#wc -l $tmwtf 
#echo $ways | tr ' ' '\n' | wc -l
#echo $ways | tr ' ' '\n' | head -n1
#echo $ways | tr ' ' '\n' | tail -n1

rm $mxtf $tmntf $tmwtf

