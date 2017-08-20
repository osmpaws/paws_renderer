#!/bin/bash

filename=$2
scale=$1
IFS='%'
while read line; do
	#caption,circle,line,pathtext,area
	echo $line | egrep "<area|<lineSymbol|<symbol" > /dev/null
	if [ $? -eq 0 ]; then
		newline=$line
		
		echo $line | grep " symbol-percent=" > /dev/null
		if [ $? -eq 0 ]; then
			sp=`echo $line | sed 's/.* symbol-percent=\"\([-0-9.]*\).*/\1/'`
			spnew=`echo "$sp*$scale" | bc | sed 's/^\./0./'`
			newline=`echo $newline | sed "s/ symbol-percent=\"$sp\"/ symbol-percent=\"$spnew\"/"`
		fi
		
		echo $line | grep " symbol-width=" > /dev/null
		if [ $? -eq 0 ]; then
			old=`echo $line | sed 's/.* symbol-width=\"\([0-9.]*\).*/\1/'`
			new=`echo "$old*$scale" | bc | sed 's/^\./0./' | sed 's/^0$/0.1/'`
			newline=`echo $newline | sed "s/ symbol-width=\"$old\"/ symbol-width=\"$new\"/"`
		fi
		
		echo $line | grep " symbol-height=" > /dev/null
		if [ $? -eq 0 ]; then
			old=`echo $line | sed 's/.* symbol-height=\"\([0-9.]*\).*/\1/'`
			new=`echo "$old*$scale" | bc | sed 's/^\./0./' | sed 's/^0$/0.1/'`
			newline=`echo $newline | sed "s/ symbol-height=\"$old\"/ symbol-height=\"$new\"/"`
		fi
		
		echo $newline
	else		
		echo $line
	fi
done < "$filename"
