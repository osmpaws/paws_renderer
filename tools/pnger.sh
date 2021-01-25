#!/bin/bash

curworkdir=`pwd`
root="$PAWS_RENDERER_ROOT"
scalecfg="tools/image_scale.cfg"
osmcscalecfg="tools/osmc-symbol-scale.cfg"
transparencycfg="tools/image_transparency.cfg"
commfile="process.com"
refreshlist="imagerefresh.lst"
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
	#pattern=`echo "$filepath" | rev | cut -d. -f2- | rev | sed -e 's/[^a-z/]/./g'`
	if ! grep -qF -m1 `echo "$line" | rev | cut -d- -f2- | rev` $refreshlist ; then
		continue
	else
		echo -n "."
	fi
	while [ `cat $commfile` -ge $bgplimit ]; do
		sleep .1;
	done
	
	echo $((`cat $commfile`+1)) > $commfile
	
	(
	filename=`echo $line | rev | cut -d/ -f1 | rev | cut -d. -f1`
	#filename=`basename "$line"`
	filepath=`echo $line | rev | cut -d/ -f2- | rev | cut -d/ -f 2-`
	#filepath=`dirname "$line"`
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
	
	mkdir -p "$targetdir/$filepath/"
	inkscape -z -e "$targetdir/$filepath/tmp_$iconname.png" -w $newsize "$sourcedir/$line" > /dev/null || ( echo "$targetdir/$filepath/tmp_$iconname.png , $newsize , $sourcedir/$line" ; exit 1)
	convert "$targetdir/$filepath/tmp_$iconname.png" -trim -alpha set -channel A -evaluate Divide $transparency "$targetdir/$filepath/$iconname.png" > /dev/null  || ( echo "$targetdir/$filepath/tmp_$iconname.png $newsize , $transparency , $sourcedir/$line" ; exit 1)
	rm "$targetdir/$filepath/tmp_$iconname.png" 
	echo $((`cat $commfile`-1)) > $commfile )&
		
done

wait

cd $curworkdir
