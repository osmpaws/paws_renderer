#!/bin/bash

debug=2

root="/home/jans/Dokumenty/osm/renderer"
osmcdflt="osmc-symbol-default"
osmcyaml="osmc-symbol.yaml"
osmcxml="osmc-symbol.xml"
osmcblackbg="osmc-symbol-black.xml"
osmcblackcbg="osmc-symbol-black-circle.xml"
osmcbluebg="osmc-symbol-blue.xml"
osmcbluecbg="osmc-symbol-blue-circle.xml"
osmcbrownbg="osmc-symbol-brown.xml"
osmcgreenbg="osmc-symbol-green.xml"
osmcgreencbg="osmc-symbol-green-circle.xml"
osmcgreenfbg="osmc-symbol-green-frame.xml"
osmcorangebg="osmc-symbol-orange.xml"
osmcorangecbg="osmc-symbol-orange-circle.xml"
osmcpurplebg="osmc-symbol-purple.xml"
osmcredbg="osmc-symbol-red.xml"
osmcredcbg="osmc-symbol-red-circle.xml"
osmcredfbg="osmc-symbol-red-frame.xml"
osmcwhitebg="osmc-symbol-white.xml"
osmcwhitecbg="osmc-symbol-white-circle.xml"
osmcyellowbg="osmc-symbol-yellow.xml"
osmcyellowcbg="osmc-symbol-yellow-circle.xml"
osmcyellowfbg="osmc-symbol-yellow-frame.xml"
pawsyaml="paws.yaml"
pawsosmcyaml="paws-osmc.yaml"
exportdir="export_paws"
scalecfg="osmc-symbol-scale.cfg"
basexml="base2.xml"
tempxml="temp.xml"
themecfg="themes.cfg"
uploadscript="upload.sh"
uploadpath="upload.txt"
lmod="lmod.txt"
logfile="$root/logfile.txt"

bcx="biking-captions.xml"
blhzx="biking-lines-high-zoom.xml"
bllzx="biking-lines-low-zoom.xml"
hlhzx="hiking-lines-high-zoom.xml"
hllzx="hiking-lines-low-zoom.xml"

##################################################
# fixed part
##################################################
cd $root
echo "Debug mode: $debug" > $logfile
rebuildimg=0
lmodf=`find osmic-derivate/ -type f -printf '%T@ %p\n' | sort -n | tail -1 | tr -d '/ .'`
echo " Current state: $lmodf" >> $logfile
lmodo=`cat tools/$lmod`
echo "Original state: $lmodo" >> $logfile

if [ "$lmodf" = "$lmodo" ] ; then
	rebuildimg=0
else
	rebuildimg=1

	cd $root/osmic-derivate/$osmcdflt
	bash replicator.sh
	cp $osmcyaml ../tools/config/
	cp $scalecfg ../../tools/
	cp $osmcxml osmc-symbol-*.xml ../../xml/

	cd ../tools/config
	cat $pawsyaml $osmcyaml > $pawsosmcyaml

	cd ../..
	python tools/export.py tools/config/$pawsosmcyaml
	rm -r ../svg/*
	#rm -r ../png/*
	cp -R $exportdir/. ../svg/
	find ../osmic-derivate/ -type f -printf '%T@ %p\n' | sort -n | tail -1 | tr -d '/ .' > $root/tools/$lmod
fi
echo "Regenerate images: $rebuildimg" >> $logfile
##################################################

if [ $debug -le 1 ]; then
	exit 0
fi

if [ $rebuildimg -eq 1 ]; then
	cd ..
	rm -r themes
fi

mkdir -p themes

uploadstr=""
echo -n "" > $uploadpath
lastimgscale=0
# nazev thmscl imgscl hiking biking
# pokud se poradi zmeni je treba na vstupu zmenit sort
sort -k4,4 -s -t ',' "tools/$themecfg" |
while IFS=, read themename xmlscalefactor txtscalefactor imgscalefactor hiking biking
do
	echo $themename $xmlscalefactor $imgscalefactor
	echo "Theme name: $themename" >> $logfile
	echo " XML scale: $xmlscalefactor" >> $logfile
	echo " text scale: $txtscalefactor" >> $logfile
	echo " image scale: $imgscalefactor" >> $logfile
	echo " include hiking: $hiking" >> $logfile
	echo " include biking: $biking" >> $logfile
	
	mkdir $themename
	cp $root/xml/$basexml $root/xml/$tempxml
	if [ "$hiking" = "1" ]; then
		ls $root/xml/$hlhzx $root/xml/$hllzx $root/xml/$osmcwhitebg $root/xml/$osmcwhitecbg $root/xml/$osmcblackbg $root/xml/$osmcblackcbg $root/xml/$osmcbluebg $root/xml/$osmcbluecbg $root/xml/$osmcbrownbg $root/xml/$osmcgreenbg $root/xml/$osmcgreencbg $root/xml/$osmcgreenfbg $root/xml/$osmcorangebg $root/xml/$osmcorangecbg $root/xml/$osmcpurplebg $root/xml/$osmcredbg $root/xml/$osmcredcbg $root/xml/$osmcredfbg $root/xml/$osmcyellowcbg $root/xml/$osmcyellowfbg
		
		sed -i "/<!--hiking#lines#high#zoom-->/r $root/xml/$hlhzx" $root/xml/$tempxml
		sed -i "/<!--hiking#lines#low#zoom-->/r $root/xml/$hllzx" $root/xml/$tempxml
		sed -i "/<!--OSMC#symbols-->/r $root/xml/$osmcwhitebg" $root/xml/$tempxml
		sed -i "/<!--OSMC#symbols-->/r $root/xml/$osmcwhitecbg" $root/xml/$tempxml
		sed -i "/<!--OSMC#symbols-->/r $root/xml/$osmcblackbg" $root/xml/$tempxml
		sed -i "/<!--OSMC#symbols-->/r $root/xml/$osmcblackcbg" $root/xml/$tempxml
		sed -i "/<!--OSMC#symbols-->/r $root/xml/$osmcbluebg" $root/xml/$tempxml
		sed -i "/<!--OSMC#symbols-->/r $root/xml/$osmcbluecbg" $root/xml/$tempxml
		sed -i "/<!--OSMC#symbols-->/r $root/xml/$osmcbrownbg" $root/xml/$tempxml
		sed -i "/<!--OSMC#symbols-->/r $root/xml/$osmcgreenbg" $root/xml/$tempxml
		sed -i "/<!--OSMC#symbols-->/r $root/xml/$osmcgreencbg" $root/xml/$tempxml
		sed -i "/<!--OSMC#symbols-->/r $root/xml/$osmcgreenfbg" $root/xml/$tempxml
		sed -i "/<!--OSMC#symbols-->/r $root/xml/$osmcorangebg" $root/xml/$tempxml
		sed -i "/<!--OSMC#symbols-->/r $root/xml/$osmcorangecbg" $root/xml/$tempxml
		sed -i "/<!--OSMC#symbols-->/r $root/xml/$osmcpurplebg" $root/xml/$tempxml
		sed -i "/<!--OSMC#symbols-->/r $root/xml/$osmcredbg" $root/xml/$tempxml
		sed -i "/<!--OSMC#symbols-->/r $root/xml/$osmcredcbg" $root/xml/$tempxml
		sed -i "/<!--OSMC#symbols-->/r $root/xml/$osmcredfbg" $root/xml/$tempxml
		sed -i "/<!--OSMC#symbols-->/r $root/xml/$osmcyellowcbg" $root/xml/$tempxml
		sed -i "/<!--OSMC#symbols-->/r $root/xml/$osmcyellowfbg" $root/xml/$tempxml
	fi
	if [ "$biking" = "1" ]; then
		sed -i "/<!--biking#lines#high#zoom-->/r $root/xml/$blhzx" $root/xml/$tempxml
		sed -i "/<!--biking#lines#low#zoom-->/r $root/xml/$bllzx" $root/xml/$tempxml
		sed -i "/<!--biking#captions-->/r $root/xml/$bcx" $root/xml/$tempxml
		sed -i "/<!--OSMC#symbols-->/r $root/xml/$osmcyellowbg" $root/xml/$tempxml
	fi
	
	echo "Temp xml done"
	
	if [ $rebuildimg -eq 1 ]; then
		if [ "$lastimgscale" != "$imgscalefactor" ]; then
			echo " regenerating images" >> $logfile
			sh tools/pnger.sh $imgscalefactor
		fi
	else
		echo " updating only XML" >> $logfile
		mv themes/$themename .
	fi
	
	sh tools/theme_scaler.sh $xmlscalefactor $txtscalefactor $root/xml/$tempxml > $themename/$themename.xml
	mkdir -p $themename/v2
	cat $themename/$themename.xml | sed 's/renderTheme.xsd" version="1"/renderTheme.xsd" version="2"/g
	s/src="file:\//src="file:..\//g 
	s/<circle r="/<circle radius="/g' > $themename/v2/$themename.map.xml
	
	if [ $rebuildimg -eq 1 ]; then
		echo " attaching required images to theme" >> $logfile
		sh tools/completer.sh $themename
	fi
	cp images/paw.png $themename/$themename.png
	echo "zipping"
	zip -r $themename.zip $themename
	mv $themename $themename.zip themes/
	uploadstr=$uploadstr"themes/$themename.zip,"
	echo -n "themes/$themename.zip," >> $uploadpath
	lastimgscale=$imgscalefactor
done

if [ $debug -le 2 ]; then
	exit 0
fi

sh tools/$uploadscript "$root/$uploadpath"
