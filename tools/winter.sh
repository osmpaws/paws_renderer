#!/bin/bash

#$1
infile=$1
patterns=0

if [ ! -f $infile ]; then
	exit 1
fi

targetcol="6090F8"
tr=`echo $targetcol | awk '{print toupper(substr($0, 1, 2))}'`
tg=`echo $targetcol | awk '{print toupper(substr($0, 3, 2))}'`
tb=`echo $targetcol | awk '{print toupper(substr($0, 5, 2))}'`

while IFS= read line ; do
	if echo $line | grep -q '<!--winter#skip-->' ; then
		echo "$line" | sed 's/\s*<!--winter#skip-->//'
	elif echo $line | grep -q 'area.* .*fill' ; then
		hex=`echo $line | sed 's/.* fill="#\([^"]\{3,8\}\)" .*/\1/'`
		or=`echo $hex | awk '{print toupper(substr($0, 1, 2))}'`
		og=`echo $hex | awk '{print toupper(substr($0, 3, 2))}'`
		ob=`echo $hex | awk '{print toupper(substr($0, 5, 2))}'`
		nr=`echo "ibase=16;($or+$og+$ob)/7*2" | bc | awk '{ printf("%02X", ($0 > 255) ? 255 : $0)}'`
		ng=`echo "ibase=16;($or+$og+$ob)/3" | bc | awk '{ printf("%02X", ($0 > 255) ? 255 : $0)}'`
		nb=`echo "ibase=16;($ob+$tb)/2" | bc | awk '{ printf("%02X", ($0 > 255) ? 255 : $0)}'`
		newhex="$nr$ng$nb"
		newline=`echo "$line" | sed "s/fill=\"#$hex\"/fill=\"#$newhex\"/"`
		echo "$newline"
	elif echo "$line" | grep -q '^#patterns' ; then
		patterns=1
		echo "$line"
	elif echo "$line" | grep -q '^    fill:' ; then
		if [ $patterns -eq 1 ]; then
			hex=`echo "$line" | sed 's/    fill: "#\([^"]\{3,8\}\)".*/\1/'`
			or=`echo $hex | awk '{print toupper(substr($0, 1, 2))}'`
			og=`echo $hex | awk '{print toupper(substr($0, 3, 2))}'`
			ob=`echo $hex | awk '{print toupper(substr($0, 5, 2))}'`
			nr=`echo "ibase=16;(($or+$og+$ob)/4)" | bc | awk '{ printf("%02x", ($0 > 255) ? 255 : $0)}'`
			ng=`echo "ibase=16;(($or+$og+$ob)/3)" | bc | awk '{ printf("%02x", ($0 > 255) ? 255 : $0)}'`
			nb=`echo "ibase=16;($ob+$tb)/2" | bc | awk '{ printf("%02x", ($0 > 255) ? 255 : $0)}'`
			newhex="$nr$ng$nb"
			newline=`echo "$line" | sed "s/fill: \"#$hex\"/fill: \"#$newhex\"/"`
			echo "$newline"
		else
			echo "$line"
		fi
	else 
		echo "$line"
	fi
done < "$infile"
