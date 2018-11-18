#!/bin/bash

filename=$3
scale=$1
txtscale=$2
IFS='%'
useawk=1

if [ "$useawk" -eq "1" ] ; then
	awk -v "scale=$scale" -v "txtscale=$txtscale" '/<area|<caption|<circle|<line|<pathText/ {
	fnw = match($0,"<")
	printf "%s",substr($0,0,fnw-1)
	for(i=1;i<=NF;i++) {
		if ( $i ~ /^r=|^stroke-width=/ ) { 
			split($i,workfields,"\"");
			printf"%s\"%-0.2f\"%s",workfields[1],(workfields[2]*scale < 0.1)?0.1:workfields[2]*scale,workfields[3];
		} else if ( $i ~ /^dy=|^font-size=/ ) { 
			split($i,workfields,"\"");
			printf"%s\"%-0.2f\"%s",workfields[1],(workfields[2]*txtscale < 0.1) && (workfields[2]*scale > -0.1 )?0.1:workfields[2]*txtscale,workfields[3];
		} else if ( $i ~ /^stroke-dasharray=/ ) { 
			split($i,workfields,"\"");
			printf"%s\"",workfields[1];
			nsd = split(workfields[2],dasharray,",");
			for(j=1;j<nsd;j++) {
				printf"%-0.2f,",dasharray[j]*scale;
			}
			printf"%-0.1f%s\"",dasharray[nsd]*scale,workfields[3];
		} else {
			printf "%s",$i;
		}
		if ( i < NF ) {
			printf " ";
		}
	}
	printf "\n";
	}
	!/<area|<caption|<circle|<line|<pathText/ {print $0}' "$filename"
else

while read line; do
	#caption,circle,line,pathtext,area
	
	
	
	if echo $line | grep -q -e "<area" -e "<caption" -e "<circle" -e "<line" -e "<pathText" ; then
		newline=$line
		
		if echo $line | grep -q " dy=" ; then
			dy=`echo $line | sed 's/.* dy=\"\([-0-9.]*\).*/\1/'`
			#dynew=`echo "if($dy>0){$dy+$scale}else{$dy-$scale}" | bc`
			dynew=`echo "$dy*$txtscale" | bc | sed -e 's/^\./0./' -e 's/^-\./-0./'`
			newline=`echo $newline | sed "s/ dy=\"$dy\"/ dy=\"$dynew\"/"`
		fi
		
		
		if echo $line | grep -q " r=" ; then
			old=`echo $line | sed 's/.* r=\"\([0-9.]*\).*/\1/'`
			new=`echo "$old*$scale" | bc | sed -e 's/^\./0./' -e 's/^-\./-0./' -e 's/^0$/0.1/'`
			newline=`echo $newline | sed "s/ r=\"$old\"/ r=\"$new\"/"`
		fi
		
		
		if echo $line | grep -q " stroke-width=" ; then
			old=`echo $line | sed 's/.* stroke-width=\"\([0-9.]*\).*/\1/'`
			new=`echo "$old*$scale" | bc | sed -e 's/^\./0./' -e 's/^-\./-0./' -e 's/^0$/0.1/'`
			newline=`echo $newline | sed "s/ stroke-width=\"$old\"/ stroke-width=\"$new\"/"`
		fi
		
		
		if echo $line | grep -q " stroke-dasharray=" ; then
			old=`echo $line | sed 's/.* stroke-dasharray=\"\([0-9,. ]*\).*/\1/'`
			new=`echo "$old" | tr ',' ' ' |  awk -v "scale=$scale" '{for(i=1;i<NF;i++)printf"%s",$i*scale OFS;if(NF)printf"%s",$NF*scale;printf ORS}' | tr ' ' ','`
			newline=`echo $newline | sed "s/ stroke-dasharray=\"$old\"/ stroke-dasharray=\"$new\"/"`
		fi
		
		
		if echo $line | grep -q " font-size="; then
			old=`echo $line | sed 's/.* font-size=\"\([0-9.]*\).*/\1/'`
			new=`echo "$old*$txtscale" | bc | sed -e 's/^\./0./' -e 's/^-\./-0./'`
			newline=`echo $newline | sed "s/ font-size=\"$old\"/ font-size=\"$new\"/"`
		fi
		echo $newline
	else		
		echo $line
	fi
done < "$filename"

fi
