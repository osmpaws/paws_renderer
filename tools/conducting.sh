#!/bin/bash

debug=2

root="/home/jans/Dokumenty/osm/renderer"
osmcdflt="osmc-symbol-default"
osmcyaml="osmc-symbol.yaml"
osmcxml="osmc-symbol.xml"
stylev4setup="style_v4_setup.xml"
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
osmcnonebg="osmc-symbol-none.xml"
# node
osmcblackbgnd="osmc-symbol-black-node.xml"
osmcblackcbgnd="osmc-symbol-black-circle-node.xml"
osmcbluebgnd="osmc-symbol-blue-node.xml"
osmcbluecbgnd="osmc-symbol-blue-circle-node.xml"
osmcbrownbgnd="osmc-symbol-brown-node.xml"
osmcgreenbgnd="osmc-symbol-green-node.xml"
osmcgreencbgnd="osmc-symbol-green-circle-node.xml"
osmcgreenfbgnd="osmc-symbol-green-frame-node.xml"
osmcorangebgnd="osmc-symbol-orange-node.xml"
osmcorangecbgnd="osmc-symbol-orange-circle-node.xml"
osmcpurplebgnd="osmc-symbol-purple-node.xml"
osmcredbgnd="osmc-symbol-red-node.xml"
osmcredcbgnd="osmc-symbol-red-circle-node.xml"
osmcredfbgnd="osmc-symbol-red-frame-node.xml"
osmcwhitebgnd="osmc-symbol-white-node.xml"
osmcwhitecbgnd="osmc-symbol-white-circle-node.xml"
osmcyellowbgnd="osmc-symbol-yellow-node.xml"
osmcyellowcbgnd="osmc-symbol-yellow-circle-node.xml"
osmcyellowfbgnd="osmc-symbol-yellow-frame-node.xml"
osmcnonebgnd="osmc-symbol-none-node.xml"
osmcrefnd="osmc-node-ref-4.xml"
# cfg
pawsyaml="paws.yaml"
pawspatternsyaml="paws_patterns.yaml"
pawsosmcyaml="paws-osmc.yaml"
exportdir="export_paws"
scalecfg="osmc-symbol-scale.cfg"
basexml="base2.xml"
tempxml="temp.xml"
themecfg="themes.cfg"
templatesrc=`cat tools/${themecfg} | tr ',' ' '  | awk '{print $5,$6,$1}' | sort -k1,1nr -k2,2nr -k3,3 | head -n1 | awk '{print $3}'`
template="template.xml"
uploadscript="upload.sh"
uploadpath="upload.txt"
lmod="lmod.txt"
logfile="$root/logfile.txt"
osmcsymlst=~hts/osm/nbh/osmc_symbols.lst
osmcsymlstold="osmc_symbol.lst"
winter=0
wintercol="winter.sh"
pawswinteryaml="paws_winter.yaml"
buildctrl="build.txt"
releasectrl="release.txt"
sedfile="sed_script.sed"

bcx="biking-captions.xml"
blhzx="biking-lines-high-zoom.xml"
bllzx="biking-lines-low-zoom.xml"
bcx4="biking-captions-4.xml"
blhzx4="biking-lines-high-zoom-4.xml"
bllzx4="biking-lines-low-zoom-4.xml"
hlhzx="hiking-lines-high-zoom.xml"
hllzx="hiking-lines-low-zoom.xml"
hlhzx4="hiking-lines-high-zoom-4.xml"
hllzx4="hiking-lines-low-zoom-4.xml"
cwl="cycleway-lane.xml"
cwl4="cycleway-lane-4.xml"
gp="guidepost.xml"
gp4="guidepost-4.xml"
mapper4="mapper-4.xml"

##################################################
# fixed part
##################################################
cd $root
echo "Debug mode: $debug" > $logfile

if ! diff -q $osmcsymlst $osmcsymlstold &> /dev/null; then
	cp $osmcsymlst $osmcsymlstold
	touch $root/osmic-derivate/$osmcdflt/force_rebuild
fi

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
	startsec=`date +%s`
	bash replicator.sh
	echo "replication done in: $((`date +%s`-startsec)) sec" >> $logfile
	cp $osmcyaml ../tools/config/
	cp $scalecfg ../../tools/
	rm ../../xml/osmc-symbol-*.xml
	cp $osmcxml osmc-symbol-*.xml ../../xml/

	cd ../tools/config
	
	if [ $winter -eq 1 ]; then
		startsec=`date +%s`
		bash $root/tools/$wintercol $pawsyaml > $pawswinteryaml
		echo "winter modification done in: $((`date +%s`-startsec)) sec" >> $logfile
		pawsyaml="$pawswinteryaml"
	fi
	
	cat $pawsyaml $osmcyaml > $pawsosmcyaml
	sed -e 's/^  - name: ".*symbols"/#/' -e 's/output_basedir:.*/output_basedir: "..\/svg_patterns"/' -e '/^  padding:.*/d' $pawsyaml > $pawspatternsyaml

	cd ../..
	python tools/export.py tools/config/$pawsosmcyaml
	rm -r ../svg/*
	#rm -r ../png/*
	cp -R $exportdir/. ../svg/
	find ../osmic-derivate/ -type f -printf '%T@ %p\n' | sort -n | tail -1 | tr -d '/ .' > $root/tools/$lmod
	
	rm -r ../svg_patterns/*
	python tools/export.py tools/config/$pawspatternsyaml
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
buildstr=`awk '{printf("%$0+1)}' tool/$buildctrl`
releasestr=`awk '{printf("%$0+1)}' tool/$releasectrl`

echo -n "" > $uploadpath
lastimgscale=0
# nazev thmscl imgscl hiking biking
# pokud se poradi zmeni je treba na vstupu zmenit sort
sort -k4,4 -s -t ',' "tools/$themecfg" |
while IFS=, read themename xmlscalefactor txtscalefactor imgscalefactor hiking biking revision
do
	echo $themename $xmlscalefactor $imgscalefactor
	echo "Theme name: $themename" >> $logfile
	echo " XML scale: $xmlscalefactor" >> $logfile
	echo " text scale: $txtscalefactor" >> $logfile
	echo " image scale: $imgscalefactor" >> $logfile
	echo " include hiking: $hiking" >> $logfile
	echo " include biking: $biking" >> $logfile
	echo " revision: $revision" >> $logfile
	echo " build: $buildstr" >> $logfile
	echo " release: $releasestr" >> $logfile
	
	mkdir $themename	
	
	cp $root/xml/$basexml $root/xml/$tempxml
	echo "s/<!--#version#-->/<!--#r${releasestr}${buildstr}#-->" >> $themename/$sedfile
	echo "$buildstr" > tool/$buildctrl
	if [ "$debug" -ge "3" ]; then
		echo "$releasestr" > tool/$releasectrl
	fi
	
	if [ "$revision" -eq "4" ]; then
		echo 's/\.\.\/renderTheme.xsd" version="[0-9]\+"/https:\/\/raw.githubusercontent.com\/mapsforge\/mapsforge\/dev\/resources\/renderTheme-v4.xsd" version="4" map-background-outside="#EEEEEE"/g
	s/src="file:\//src="file:/g
	s/<circle r="/<circle radius="/g' >> $themename/$sedfile
##		sed 's/\.\.\/renderTheme.xsd" version="[0-9]\+"/https:\/\/raw.githubusercontent.com\/mapsforge\/mapsforge\/dev\/resources\/renderTheme-v4.xsd" version="4" map-background-outside="#EEEEEE"/g
##	s/src="file:\//src="file:/g
##	s/<circle r="/<circle radius="/g' $root/xml/$basexml > $root/xml/$tempxml
	
		echo "/<!--style#v4#setup-->/r $root/xml/$stylev4setup
		/<!--national#park#pattern-->/r $root/xml/national-park-4.xml
		/<!--mapper#pois-->/r $root/xml/mapper-4.xml
		/<!--#guidepost#-->/r $root/xml/guidepost-4.xml" >> $themename/$sedfile
		
##		sed -i -e "/<!--style#v4#setup-->/r $root/xml/$stylev4setup" \
##	    -e "/<!--national#park#pattern-->/r $root/xml/national-park-4.xml" \
##	    -e "/<!--piste#nordic-->/r $root/xml/piste-nordic-4.xml" \
##	    -e "/<!--mapper#pois-->/r $root/xml/mapper-4.xml" \
##	    -e "/<!--#guidepost#-->/r $root/xml/guidepost-4.xml" $root/xml/$tempxml
	else
##		cp $root/xml/$basexml $root/xml/$tempxml
		echo "/<!--piste#nordic-->/r $root/xml/piste-nordic.xml
		      /<!--#guidepost#-->/r $root/xml/guidepost.xml" >> $themename/$sedfile
##		sed -i -e "/<!--piste#nordic-->/r $root/xml/piste-nordic.xml" \
##		       -e "/<!--#guidepost#-->/r $root/xml/guidepost.xml" $root/xml/$tempxml
	fi
	
	if [ "$hiking" = "1" ]; then
				
		if [ "$revision" -eq "4" ]; then
			echo "/<!--hiking#lines#high#zoom#4-->/r $root/xml/$hlhzx4 
			       /<!--hiking#lines#low#zoom-->/r $root/xml/$hllzx" >> $themename/$sedfile
			       
##			sed -i -e "/<!--hiking#lines#high#zoom#4-->/r $root/xml/$hlhzx4" \
##			       -e "/<!--hiking#lines#low#zoom-->/r $root/xml/$hllzx" \
			sed -i -e '/<!--OSMC#symbols-->/r '<(sed 's/k="osmc_background"/cat="hike_symbol_lines" k="osmc_background"/g' `find $root/xml -name 'osmc-symbol-*.xml' -not -name '*-node.xml'`) $root/xml/$tempxml
			# nodes
			if [ 1 -eq 1 ]; then
				sed -i -e '/<!--OSMC#symbols-->/r '<(sed 's/k="osmc_background"/cat="hike_symbol_nodes" k="osmc_background"/g' $root/xml/osmc-symbol-*-node.xml) ##/
##				       -e "/<!--OSMC#symbol#node#ref-->/r $root/xml/$osmcrefnd" $root/xml/$tempxml
				echo "/<!--OSMC#symbol#node#ref-->/r $root/xml/$osmcrefnd" >> $themename/$sedfile
			fi
		else
##			sed -i -e "/<!--hiking#lines#high#zoom-->/r $root/xml/$hlhzx" \
##			       -e "/<!--hiking#lines#low#zoom-->/r $root/xml/$hllzx" \
			echo "/<!--hiking#lines#high#zoom-->/r $root/xml/$hlhzx
			      /<!--hiking#lines#low#zoom-->/r $root/xml/$hllzx" >> $themename/$sedfile
			sed -i -e "/<!--OSMC#symbols-->/r "<(cat `find $root/xml -name 'osmc-symbol-*.xml' -not -name '*-node.xml'`) $root/xml/$tempxml
			
		fi
	fi
	if [ "$biking" = "1" ]; then
		if [ "$revision" -eq "4" ]; then
			echo "/<!--biking#lines#high#zoom-->/r $root/xml/$blhzx4
			       /<!--biking#lines#low#zoom-->/r $root/xml/$bllzx4
			       /<!--biking#captions-->/r $root/xml/$bcx4
			       /<!--cycleway#lane-->/r $root/xml/$cwl4" >> $themename/$sedfile
##			sed -i -e "/<!--biking#lines#high#zoom-->/r $root/xml/$blhzx4" \
##			       -e "/<!--biking#lines#low#zoom-->/r $root/xml/$bllzx4" \
##			       -e "/<!--biking#captions-->/r $root/xml/$bcx4" \
##			       -e "/<!--cycleway#lane-->/r $root/xml/$cwl4" $root/xml/$tempxml
		else
			echo "/<!--biking#lines#high#zoom-->/r $root/xml/$blhzx
			      /<!--biking#lines#low#zoom-->/r $root/xml/$bllzx
			      /<!--biking#captions-->/r $root/xml/$bcx
			      /<!--cycleway#lane-->/r $root/xml/$cwl" >> $themename/$sedfile
##			sed -i -e "/<!--biking#lines#high#zoom-->/r $root/xml/$blhzx" \
##			       -e "/<!--biking#lines#low#zoom-->/r $root/xml/$bllzx" \
##			       -e "/<!--biking#captions-->/r $root/xml/$bcx" \
##			       -e "/<!--cycleway#lane-->/r $root/xml/$cwl" $root/xml/$tempxml
		fi
	fi
	
	sed -i -f $themename/$sedfile $root/xml/$tempxml
	
	echo "Temp xml done"
	
	if [ $rebuildimg -eq 1 ]; then
		if [ "$lastimgscale" != "$imgscalefactor" ]; then
			echo " regenerating images" >> $logfile
			startsec=`date +%s`
			sh tools/pnger.sh $imgscalefactor
			echo "PNGs created in: $((`date +%s`-startsec)) sec" >> $logfile
		fi
	else
		echo " updating only XML" >> $logfile
		mv themes/$themename .
	fi
	
	startsec=`date +%s`
	bash tools/theme_scaler.sh $xmlscalefactor $txtscalefactor $root/xml/$tempxml > $themename/$themename.xml
	echo "theme scaled in: $((`date +%s`-startsec)) sec" >> $logfile
	
	if [ "$winter" -eq "1" ]; then
		startsec=`date +%s`
		bash tools/$wintercol $themename/$themename.xml > $root/xml/$tempxml && cp $root/xml/$tempxml $themename/$themename.xml
		echo "winter theme changes in: $((`date +%s`-startsec)) sec" >> $logfile
	fi
	
	mkdir -p $themename/v2
	cat $themename/$themename.xml | sed 's/renderTheme.xsd" version="[0-9]\+"/renderTheme.xsd" version="2"/g
	s/src="file:\//src="file:..\//g 
	s/<circle r="/<circle radius="/g' > $themename/v2/$themename.map.xml
	
	if [ $rebuildimg -eq 1 ]; then
		echo " attaching required images to theme" >> $logfile
		startsec=`date +%s`
		sh tools/completer.sh $themename
		echo "PNGs copied in: $((`date +%s`-startsec)) sec" >> $logfile
	fi
	cp images/paw.png $themename/$themename.png
	echo "zipping"
	zip -r $themename.zip $themename
	mv $themename $themename.zip themes/
	uploadstr=$uploadstr"themes/$themename.zip,"
	echo -n "themes/$themename.zip," >> $uploadpath
	lastimgscale=$imgscalefactor
done

bash $root/tools/svg_theme.sh
uploadstr=$uploadstr"themes_svg/paws_4.zip,"
echo -n "themes_svg/paws_4.zip," >> $uploadpath

bash $root/tools/locus_theme.sh
uploadstr=$uploadstr"themes_svg/paws_4_LE.zip,"
echo -n "themes_svg/paws_4_LE.zip," >> $uploadpath

if [ $debug -le 2 ]; then
	exit 0
fi

cp themes/$templatesrc/${templatesrc}.xml $template

sh tools/$uploadscript "$root/$uploadpath"
