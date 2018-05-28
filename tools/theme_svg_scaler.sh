#!/bin/bash

filename=$2
scale=$1
IFS='%'
useawk=1

if [ "$useawk" -eq "1" ] ; then
	awk -v "scale=$scale"  '/<area|<lineSymbol|<symbol/ {
	fnw = match($0,"<")
	printf "%s",substr($0,0,fnw-1)
	for(i=1;i<=NF;i++) {
		if ( $i ~ /symbol-percent=|symbol-width=|symbol-height=/ ) { 
			split($i,workfields,"\"");
			printf"%s\"%-0.1f\"%s ",workfields[1],(workfields[2]*scale < 0.1)?0.1:workfields[2]*scale,workfields[3];
		} else {
			printf "%s ",$i;
		}
	}
	printf "\n";
	}
	!/<area|<lineSymbol|<symbol/ {print $0}' "$filename"
else

while read line; do
	#caption,circle,line,pathtext,area
	if echo $line | egrep -q "<area|<lineSymbol|<symbol" ; then
		newline=$line		
		
		if echo $line | grep -q " symbol-percent=" ; then
			sp=`echo $line | sed 's/.* symbol-percent=\"\([-0-9.]*\).*/\1/'`
			spnew=`echo "$sp*$scale" | bc | sed 's/^\./0./'`
			newline=`echo $newline | sed "s/ symbol-percent=\"$sp\"/ symbol-percent=\"$spnew\"/"`
		fi
		
		if echo $line | grep -q " symbol-width=" ; then
			old=`echo $line | sed 's/.* symbol-width=\"\([0-9.]*\).*/\1/'`
			new=`echo "$old*$scale" | bc | sed 's/^\./0./' | sed 's/^0$/0.1/'`
			newline=`echo $newline | sed "s/ symbol-width=\"$old\"/ symbol-width=\"$new\"/"`
		fi
		
		if echo $line | grep -q " symbol-height=" ; then
			old=`echo $line | sed 's/.* symbol-height=\"\([0-9.]*\).*/\1/'`
			new=`echo "$old*$scale" | bc | sed 's/^\./0./' | sed 's/^0$/0.1/'`
			newline=`echo $newline | sed "s/ symbol-height=\"$old\"/ symbol-height=\"$new\"/"`
		fi
		
		echo $newline
	else		
		echo $line
	fi
done < "$filename"
fi
