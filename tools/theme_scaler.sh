#!/bin/bash

filename=$3
scale=$1
txtscale=$2
IFS='%'
while read line; do
	#caption,circle,line,pathtext,area
	echo $line | egrep "<area|<caption|<circle|<line|<pathText" > /dev/null
	if [ $? -eq 0 ]; then
		newline=$line
		
		echo $line | grep " dy=" > /dev/null
		if [ $? -eq 0 ]; then
			dy=`echo $line | sed 's/.* dy=\"\([-0-9]*\).*/\1/'`
			#dynew=`echo "if($dy>0){$dy+$scale}else{$dy-$scale}" | bc`
			dynew=`echo "$dy*$txtscale" | bc | sed 's/^\./0./'`
			newline=`echo $newline | sed "s/ dy=\"$dy\"/ dy=\"$dynew\"/"`
		fi
		
		echo $line | grep " r=" > /dev/null
		if [ $? -eq 0 ]; then
			old=`echo $line | sed 's/.* r=\"\([0-9.]*\).*/\1/'`
			new=`echo "$old*$scale" | bc | sed 's/^\./0./' | sed 's/^0$/0.1/'`
			newline=`echo $newline | sed "s/ r=\"$old\"/ r=\"$new\"/"`
		fi
		
		echo $line | grep " stroke-width=" > /dev/null
		if [ $? -eq 0 ]; then
			old=`echo $line | sed 's/.* stroke-width=\"\([0-9.]*\).*/\1/'`
			new=`echo "$old*$scale" | bc | sed 's/^\./0./' | sed 's/^0$/0.1/'`
			newline=`echo $newline | sed "s/ stroke-width=\"$old\"/ stroke-width=\"$new\"/"`
		fi
		
		echo $line | grep " stroke-dasharray=" > /dev/null
		if [ $? -eq 0 ]; then
			old=`echo $line | sed 's/.* stroke-dasharray=\"\([0-9,. ]*\).*/\1/'`
			new=`echo "$old" | tr ',' ' ' |  awk -v "scale=$scale" '{for(i=1;i<NF;i++)printf"%s",$i*scale OFS;if(NF)printf"%s",$NF*scale;printf ORS}' | tr ' ' ','`
			newline=`echo $newline | sed "s/ stroke-dasharray=\"$old\"/ stroke-dasharray=\"$new\"/"`
		fi
		
		echo $line | grep " font-size=" > /dev/null
		if [ $? -eq 0 ]; then
			old=`echo $line | sed 's/.* font-size=\"\([0-9.]*\).*/\1/'`
			new=`echo "$old*$txtscale" | bc | sed 's/^\./0./'`
			newline=`echo $newline | sed "s/ font-size=\"$old\"/ font-size=\"$new\"/"`
		fi
		echo $newline
	else		
		echo $line
	fi
done < "$filename"
