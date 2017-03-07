#!/bin/bash

debug=1

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
osmcgreenbg="osmc-symbol-green-circle.xml"
osmcgreenfbg="osmc-symbol-green-frame.xml"
osmcorangebg="osmc-symbol-orange.xml"
osmcorangecbg="osmc-symbol-orange-circle.xml"
osmcpurplebg="osmc-symbol-purple.xml"
osmcredbg="osmc-symbol-red.xml"
osmcredfbg="osmc-symbol-red-frame.xml"
osmcwhitebg="osmc-symbol-white.xml"
osmcwhitecbg="osmc-symbol-white-circle.xml"
osmcwhitefbg="osmc-symbol-white-frame.xml"
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

bcx="biking-captions.xml"
blhzx="biking-lines-high-zoom.xml"
bllzx="biking-lines-low-zoom.xml"
hlhzx="hiking-lines-high-zoom.xml"
hllzx="hiking-lines-low-zoom.xml"

##################################################
# fixed part
##################################################
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
##################################################

if [ $debug -gt 0 ]; then
	exit 0
fi

cd ..
rm -r themes
mkdir -p themes

uploadstr=""
# nazev thmscl imgscl hiking biking

while IFS=, read themename xmlscalefactor txtscalefactor imgscalefactor hiking biking
do
	echo $themename $xmlscalefactor $imgscalefactor
	mkdir $themename
	cp $root/xml/$basexml $root/xml/$tempxml
	if [ "$hiking" = "1" ]; then
		sed -i "/<!--hiking#lines#high#zoom-->/r $root/xml/$hlhzx" $root/xml/$tempxml
		sed -i "/<!--hiking#lines#low#zoom-->/r $root/xml/$hllzx" $root/xml/$tempxml		
		sed -i "/<!--OSMC#symbols-->/r $root/xml/$osmcwhitebg" $root/xml/$tempxml		
		sed -i "/<!--OSMC#symbols-->/r $root/xml/$osmcwhitecbg" $root/xml/$tempxml		
		sed -i "/<!--OSMC#symbols-->/r $root/xml/$osmcwhitefbg" $root/xml/$tempxml
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
	#sh tools/pnger.sh $imgscalefactor
	sh tools/theme_scaler.sh $xmlscalefactor $txtscalefactor $root/xml/$tempxml > $themename/$themename.xml
	sh tools/completer.sh $themename
	
	zip -r $themename.zip $themename
	mv $themename $themename.zip themes/
	uploadstr=$uploadstr"themes/$themename.zip,"
done < tools/$themecfg

#sh upload.sh $uploadstr
