#!/bin/bash

curworkdir=`pwd`
root="/home/jans/Dokumenty/osm/renderer"
scalecfg="tools/image_scale.cfg"
osmcscalecfg="tools/osmc-symbol-scale.cfg"
transparencycfg="tools/image_transparency.cfg"
commfile="process.com"
sourcedir="svg"
targetdir="png"
if [ "$#" -lt 1 ]; then
	echo "Missing the scale factor!"
	exit
fi
scale=$1
IFS='%'
cd $root/$sourcedir
files=`find . -type f -name "*.svg"`
cd ..

echo "0" > $commfile
bgplimit=600

echo "$files" | while read line;
do
	while [ `cat $commfile` -ge $bgplimit ]; do
		sleep .1;
	done
	
	echo $((`cat $commfile`+1)) > $commfile
	
	(
	filename=`echo $line | rev | cut -d/ -f1 | rev | cut -d. -f1`
	filepath=`echo $line | rev | cut -d/ -f2- | rev | cut -d/ -f 2-`
	size=`echo $filename | rev | cut -d- -f1 | rev`
	iconname=`echo $filename | rev | cut -d- -f2- | rev | sed 's/[ -]/_/g'`
	
	scaletmp=`grep -h "^$iconname " $root/$scalecfg $root/$osmcscalecfg`
	extrascaletype=`echo "$scaletmp" | awk '{print $2}'`
	extrascale=`echo "$scaletmp" | awk '{print $3}'`
	if [ "$extrascale" = "" ]; then
		extrascale="1"
		extrascaletype="s"
	fi
	if [ "$extrascaletype" = "s" ]; then
		newsize=`echo "$size*$scale*$extrascale" | bc`
	elif [ "$extrascaletype" = "f" ]; then
		newsize="$extrascale"
	fi
	
	transparency=`grep "$iconname " $root/$transparencycfg | awk '{print $2}'`
	if [ "$transparency" = "" ]; then
		transparency="1"
	fi
	
	inkscape -z -e "$targetdir/$filepath/tmp_$iconname.png" -w $newsize "$sourcedir/$line" > /dev/null || echo "$targetdir/$filepath/tmp_$iconname.png , $newsize , $sourcedir/$line"
	mkdir -p "$targetdir/$filepath"
	convert "$targetdir/$filepath/tmp_$iconname.png" -trim -alpha set -channel A -evaluate Divide $transparency "$targetdir/$filepath/$iconname.png" > /dev/null  || echo "$targetdir/$filepath/tmp_$iconname.png $newsize , $transparency , $sourcedir/$line"
	rm "$targetdir/$filepath/tmp_$iconname.png" 
	echo $((`cat $commfile`-1)) > $commfile )&
		
done

wait

cd $curworkdir
