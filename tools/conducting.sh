#!/bin/bash

debug=3
release=0

thisdir=`basename $BASH_SOURCE`
root=`readlink -m "$thisdir/.."`
export PAWS_RENDERER_ROOT="$root"
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
pawsosmcyold="paws-osmc.yold"
exportdir="export_paws"
imgscalecfg="$root/tools/image_scale.cfg"
scalecfg="osmc-symbol-scale.cfg"
basexml="base2.xml"
tempxml="temp.xml"
themecfg="themes.cfg"
templatesrc=`cat tools/${themecfg} | tr ',' ' '  | awk '{print $5,$6,$1}' | sort -k1,1nr -k2,2nr -k3,3 | head -n1 | awk '{print $3}'`
template="template.xml"
template4="template4.xml"
uploadscript="upload.sh"
uploadpath="upload.txt"
lmod="lmod.txt"
logfile="$root/logfile.txt"
errfile="$root/errfile.txt"
osmcsymlst=~/osm/generator/nbh/osmc_symbols.lst
if [ ! -f "$osmcsymlst" ] ; then
	osmcsymlst=osmc_symbols.lst
fi
osmcsymlstold="osmc_symbol.lst"
winter=0
wintercol="winter.sh"
winterprefix="winter_"
winterarg=""
pawswinteryaml="paws_winter.yaml"
buildctrl="build.txt"
releasectrl="release.txt"
sedfile="sed_script.sed"
jarfile=~/.openstreetmap/osmosis/plugins/mapsforge-map-writer-0.15.0-jar-with-dependencies.jar
# mini update
sttscalecfg="$root/tools/image_scale.stt"
osmcscalecfg="tools/osmc-symbol-scale.cfg"
sttosmcscalecfg="tools/osmc-symbol-scale.stt"
transparencycfg="tools/image_transparency.cfg"
statusfile="$root/imagestatus.txt"
refreshlist="$root/imagerefresh.lst"
workstatusfile="$root/imagestatus.wrk"
toucher="$root/tools/toucher.sh"

bcx="biking-captions.xml"
blhzx="biking-lines-high-zoom.xml"
bllzx="biking-lines-low-zoom.xml"
bcx4="biking-captions-4.xml"
blhzx4="biking-lines-high-zoom-4.xml"
bllzx4="biking-lines-low-zoom-4.xml"
bbhzx4="biking-beads-high-zoom-4.xml"
bblzx4="biking-beads-low-zoom-4.xml"
hlhzx="hiking-lines-high-zoom.xml"
hllzx="hiking-lines-low-zoom.xml"
hlhzx4="hiking-lines-high-zoom-4.xml"
hllzx4="hiking-lines-low-zoom-4.xml"
cwl="cycleway-lane.xml"
cwl4="cycleway-lane-4.xml"
mtbs4="mtb-scale-4.xml"
gp="guidepost.xml"
gp4="guidepost-4.xml"
mapper4="mapper-4.xml"

##################################################
# fixed part
##################################################
cd $root
echo "Debug mode: $debug" > $logfile

if ! xmllint --noout "$root/xml/$basexml" ; then
	echo "Base XML is invalid. Exit."
	exit 1
fi

rebuildimg=0

while [ $# -gt 0 ] ; do
	case $1 in
		-r)
			release=1
		;;
		-w) 
			winter=1
			winterarg="-w" 
		;;
		-c)
			rebuildimg=1
		;;
		*)
			echo "neznámý argument $1"
		;;
	esac
	shift
done
echo "Release mode: $release" >> $logfile

#if ! diff -q $osmcsymlst $osmcsymlstold &> /dev/null; then
#	cp $osmcsymlst $osmcsymlstold
#	touch $root/osmic-derivate/$osmcdflt/force_rebuild
#fi

if [ $winter -eq 1 ]; then
	#lmodf=`find osmic-derivate/ -type f -printf '%T@ %p\n' | sort -n | tail -1 | tr -d '/ .' | sed 's/$/w/'`
	lmodf="w"
else
	#lmodf=`find osmic-derivate/ -type f -printf '%T@ %p\n' | sort -n | tail -1 | tr -d '/ .' | sed 's/$/s/'`
	lmodf="s"
fi


echo " Current state: $lmodf" >> $logfile
lmodo=`cat tools/$lmod`
echo "Original state: $lmodo" >> $logfile

month=`date +%m | awk '{printf("%d", $1)}'`
if [ $month -ge 12 ] || [ $month -le 3 ]; then
	if grep -q '<layer id="l_piste_nordic" enabled="false">' $root/xml/$stylev4setup ; then
		sed -i '/<layer id="l_piste_nordic"/ s/enabled="false"/enabled="true"/' $root/xml/$stylev4setup
	fi
else
	if grep -q '<layer id="l_piste_nordic" enabled="true">' $root/xml/$stylev4setup ; then
		sed -i '/<layer id="l_piste_nordic"/ s/enabled="true"/enabled="false"/' $root/xml/$stylev4setup
	fi
fi

#bash tools/minimalupdate.sh
#refreshlist="imagerefresh.lst"

if [ "$lmodo" = "w" ] ; then
#	rebuildimg=0
#	if [ $winter -eq 1 ]; then
		bash tools/winter_rename.sh $uploadpath -r
#	fi
fi
#else
#if [ `cat "$refreshlist" | wc -l` -gt 0 ] ; then
if [ 1 -gt 0 ] ; then
	#rebuildimg=1
	if ! diff -q $osmcsymlst $osmcsymlstold ; then
		cp $osmcsymlst $osmcsymlstold
		cd $root/osmic-derivate/$osmcdflt
		startsec=`date +%s`
		bash replicator.sh
		echo "replication done in: $((`date +%s`-startsec)) sec" >> $logfile
		cp $osmcyaml ../tools/config/
		cp $scalecfg ../../tools/
		rm ../../xml/osmc-symbol-*.xml
		cp $osmcxml osmc-symbol-*.xml ../../xml/
	fi
	
	cd $root/osmic-derivate/$osmcdflt
	cd ../tools/config
	
	if [ $winter -eq 1 ]; then
		startsec=`date +%s`
		bash $root/tools/$wintercol $pawsyaml > $pawswinteryaml
		echo "winter modification done in: $((`date +%s`-startsec)) sec" >> $logfile
		pawsyaml="$pawswinteryaml"
	fi
	
	#cd tools/config
	mv $pawsosmcyaml $pawsosmcyold
	cat $pawsyaml $osmcyaml > $pawsosmcyaml
	if ! diff $pawsosmcyold $pawsosmcyaml > /dev/null ; then
		diff <(sed 's/^\([a-z]\)/#$#$#\1/' $pawsosmcyold | tr -d '\n' | sed -e 's/$/\n/g' -e 's/#$#$#/\n/g') <(sed 's/^\([a-z]\)/#$#$#\1/' $pawsosmcyaml | tr -d '\n' | sed -e 's/$/\n/g' -e 's/#$#$#/\n/g') | grep '^>' | awk '{print $2}' | tr ':' ' ' | $toucher
	fi
	
	if ! diff "$sttscalecfg" "$imgscalecfg" > /dev/null ; then
		diff "$sttscalecfg" "$imgscalecfg" | grep '^>' | awk '{print $2}' | $toucher
		
		cp "$imgscalecfg" "$sttscalecfg"
	fi
	
	sed -e 's/^  - name: ".*symbols"/#/' -e 's/output_basedir:.*/output_basedir: "..\/svg_patterns"/' -e '/^  padding:.*/d' $pawsyaml > $pawspatternsyaml
	
	cd ../..
	
	find symbols patterns -type f -printf '%p %T@\n' > "$workstatusfile"
	find osmc-symbols -type f -printf '%p\n' >> "$workstatusfile"
	sort -o "$workstatusfile" "$workstatusfile"
	if [ $rebuildimg -ge 1 ]; then
		echo -n '' > "$statusfile"
	fi
	if [ -f "$statusfile" ]; then
		comm -13 "$statusfile" "$workstatusfile" | sort | awk '{print $1}' | sed 's/^/.\//' | rev | cut -d'-' -f2- | rev > "$refreshlist"
	fi
	mv "$workstatusfile" "$statusfile"
	
	python tools/export.py tools/config/$pawsosmcyaml
	rm -r ../svg/
	rm -r ../png/
	mkdir -p ../png
	cp -R $exportdir/. ../svg/
	if [ $winter -eq 1 ]; then
		#find ../osmic-derivate/ -type f -printf '%T@ %p\n' | sort -n | tail -1 | tr -d '/ .' | sed 's/$/w/' > $root/tools/$lmod
		echo "w" > $root/tools/$lmod
	else
		#find ../osmic-derivate/ -type f -printf '%T@ %p\n' | sort -n | tail -1 | tr -d '/ .' | sed 's/$/s/' > $root/tools/$lmod
		echo "s" > $root/tools/$lmod
	fi
	
	rm -r ../svg_patterns/*
	python tools/export.py tools/config/$pawspatternsyaml
	cd ..
	
fi
echo "Regenerate images: $rebuildimg" >> $logfile
##################################################

if [ $debug -le 1 ]; then
	exit 0
fi

if [ $rebuildimg -eq 1 ]; then
	rm -r themes
fi

mkdir -p themes

uploadstr=""
buildstr=`awk '{printf("%05d",$0+1)}' tools/$buildctrl`
releasestr=`awk '{printf("%05d",$0+1)}' tools/$releasectrl`

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
	
###	cp $root/xml/$basexml $root/xml/$tempxml
###	echo "s/<!--#version#-->/<!--#r${releasestr}b${buildstr}#-->/" > $themename_$sedfile
	echo "$buildstr" > tools/$buildctrl
	if [ "$release" -eq "1" ]; then
		echo "$releasestr" > tools/$releasectrl
	fi
	
	if [ "$revision" -eq "4" ]; then
###		echo 's/\.\.\/renderTheme.xsd" version="[0-9]\+"/https:\/\/raw.githubusercontent.com\/mapsforge\/mapsforge\/dev\/resources\/renderTheme-v4.xsd" version="4" map-background-outside="#EEEEEE"/g
###	s/src="file:\//src="file:/g
###	s/<circle r="/<circle radius="/g' >> $themename_$sedfile
		sed 's/\.\.\/renderTheme.xsd" version="[0-9]\+"/https:\/\/raw.githubusercontent.com\/mapsforge\/mapsforge\/dev\/resources\/renderTheme-v4.xsd" version="4" map-background-outside="#EEEEEE"/g
	s/src="file:\//src="file:/g
	s/<circle r="/<circle radius="/g' $root/xml/$basexml > $root/xml/$tempxml
	
###		echo "/<!--style#v4#setup-->/r $root/xml/$stylev4setup
###		/<!--national#park#pattern-->/r $root/xml/national-park-4.xml
###		/<!--mapper#pois-->/r $root/xml/$mapper4
###		/<!--#guidepost#-->/r $root/xml/$gp4" >> $themename_$sedfile
		
		sed -i -e "/<!--style#v4#setup-->/r $root/xml/$stylev4setup" \
		       -e "/<!--national#park#pattern-->/r $root/xml/national-park-4.xml" \
		       -e "/<!--piste#nordic-->/r $root/xml/piste-nordic-4.xml" \
		       -e "/<!--piste#downhill-->/r $root/xml/piste-downhill-4.xml" \
		       -e "/<!--mapper#pois-->/r $root/xml/mapper-4.xml" \
		       -e "/<!--#guidepost#-->/r $root/xml/guidepost-4.xml" \
		       -e "/<!--#restriction#-->/r $root/xml/restrictions-4.xml" \
		       -e "/<!--trail#visibility-->/r $root/xml/trail-visibility-4.xml" \
		       -e "/<!--natural#cliff-->/r $root/xml/cliff-4.xml" \
		       -e "/<!--horsing#lines#low#zoom-->/r $root/xml/horsing-lines-low-zoom-4.xml" \
		       -e "/<!--contour#lines-->/r $root/xml/contour-lines-4.xml" \
		       -e "/<!--highway#cores-->/r $root/xml/highway-cores-4.xml" \
		       -e "/<!--highway#casings-->/r $root/xml/highway-casing-4.xml" \
		       -e "/<!--#forest#-->/r $root/xml/forest-4.xml" \
		       -e "/<!--#landuse#-->/r $root/xml/landuse-4.xml" \
		       -e "/<!--#natural#-->/r $root/xml/natural-4.xml" \
		       -e "/<!--#railway#no#tunnel#-->/r $root/xml/railway-4.xml" \
		       -e "/<!--nature#reserve-->/r $root/xml/nature-reserve-4.xml" \
		       -e "/<!--protected#area-->/r $root/xml/protected-area-4.xml" \
		       -e "s/<!--#version#-->/<!--#r${releasestr}b${buildstr}#-->/" $root/xml/$tempxml
	else
		if [ $month -ge 12 ] || [ $month -le 3 ]; then
			pistenordic="piste-nordic.xml"
		else
			pistenordic="empty.xml"
		fi
		cp $root/xml/$basexml $root/xml/$tempxml
###		echo "/<!--piste#nordic-->/r $root/xml/piste-nordic.xml
###		      /<!--#guidepost#-->/r $root/xml/$gp" >> $themename_$sedfile
		sed -i -e "/<!--piste#nordic-->/r $root/xml/$pistenordic" \
		       -e "/<!--piste#downhill-->/r $root/xml/piste-downhill.xml" \
		       -e "/<!--#guidepost#-->/r $root/xml/guidepost.xml" \
		       -e "/<!--#restriction#-->/r $root/xml/restrictions.xml" \
		       -e "/<!--natural#cliff-->/r $root/xml/cliff.xml" \
		       -e "/<!--contour#lines-->/r $root/xml/contour-lines.xml" \
		       -e "/<!--highway#cores-->/r $root/xml/highway-cores.xml" \
		       -e "/<!--highway#casings-->/r $root/xml/highway-casing.xml" \
		       -e "/<!--#forest#-->/r $root/xml/forest.xml" \
		       -e "/<!--#landuse#-->/r $root/xml/landuse.xml" \
		       -e "/<!--#natural#-->/r $root/xml/natural.xml" \
		       -e "/<!--#railway#no#tunnel#-->/r $root/xml/railway.xml" \
		       -e "/<!--nature#reserve-->/r $root/xml/nature-reserve.xml" \
		       -e "/<!--protected#area-->/r $root/xml/protected-area.xml" \
		       -e "s/<!--#version#-->/<!--#r${releasestr}b${buildstr}#-->/" $root/xml/$tempxml
	fi
	
	if [ "$hiking" = "1" ]; then
				
		if [ "$revision" -eq "4" ]; then
###			echo "/<!--hiking#lines#high#zoom#4-->/r $root/xml/$hlhzx4 
###			       /<!--hiking#lines#low#zoom-->/r $root/xml/$hllzx" >> $themename_$sedfile
			       
			sed -i -e "/<!--hiking#lines#high#zoom#4-->/r $root/xml/$hlhzx4" \
			       -e "/<!--hiking#lines#low#zoom-->/r $root/xml/$hllzx4" \
			       -e "/<!--hiking#restrictions-->/r $root/xml/hiking-restrictions-4.xml" \
			       -e "/<!--sac#scale-->/r $root/xml/sac-scale-4.xml" \
			       -e '/<!--OSMC#symbols-->/r '<(sed 's/k="osmc_background"/cat="hike_symbol_lines" k="osmc_background"/g' `find $root/xml -name 'osmc-symbol-*.xml' -not -name '*-node.xml'`) $root/xml/$tempxml
			# nodes
			if [ 1 -eq 1 ]; then
				sed -i -e '/<!--OSMC#symbols-->/r '<(sed 's/k="osmc_background"/cat="hike_symbol_nodes" k="osmc_background"/g' $root/xml/osmc-symbol-*-node.xml) \
				       -e "/<!--OSMC#symbol#node#ref-->/r $root/xml/$osmcrefnd" $root/xml/$tempxml
###				echo "/<!--OSMC#symbol#node#ref-->/r $root/xml/$osmcrefnd" >> $themename_$sedfile
			fi
		else
			sed -i -e "/<!--hiking#lines#high#zoom-->/r $root/xml/$hlhzx" \
			       -e "/<!--hiking#lines#low#zoom-->/r $root/xml/$hllzx" \
			       -e "/<!--hiking#restrictions-->/r $root/xml/hiking-restrictions.xml" \
			       -e "/<!--OSMC#symbols-->/r "<(cat `find $root/xml -name 'osmc-symbol-*.xml' -not -name '*-node.xml'`) $root/xml/$tempxml
###			echo "/<!--hiking#lines#high#zoom-->/r $root/xml/$hlhzx
###			      /<!--hiking#lines#low#zoom-->/r $root/xml/$hllzx" >> $themename_$sedfile
		fi
	fi
	if [ "$biking" = "1" ]; then
		if [ "$revision" -eq "4" ]; then
###			echo "/<!--biking#lines#high#zoom-->/r $root/xml/$blhzx4
###			       /<!--biking#lines#low#zoom-->/r $root/xml/$bllzx4
###			       /<!--biking#captions-->/r $root/xml/$bcx4
###			       /<!--cycleway#lane-->/r $root/xml/$cwl4" >> $themename_$sedfile
			sed -i -e "/<!--biking#lines#high#zoom-->/r $root/xml/$blhzx4" \
			       -e "/<!--biking#lines#low#zoom-->/r $root/xml/$bllzx4" \
			       -e "/<!--biking#lines#high#zoom-->/r $root/xml/$bbhzx4" \
			       -e "/<!--biking#lines#low#zoom-->/r $root/xml/$bblzx4" \
			       -e "/<!--biking#captions-->/r $root/xml/$bcx4" \
			       -e "/<!--mtb#scale-->/r $root/xml/$mtbs4" \
			       -e "/<!--biking#restrictions-->/r $root/xml/biking-restrictions-4.xml" \
			       -e "/<!--cycleway#lane-->/r $root/xml/$cwl4" $root/xml/$tempxml
		else
###			echo "/<!--biking#lines#high#zoom-->/r $root/xml/$blhzx
###			      /<!--biking#lines#low#zoom-->/r $root/xml/$bllzx
###			      /<!--biking#captions-->/r $root/xml/$bcx
###			      /<!--cycleway#lane-->/r $root/xml/$cwl" >> $themename_$sedfile
			sed -i -e "/<!--biking#lines#high#zoom-->/r $root/xml/$blhzx" \
			       -e "/<!--biking#lines#low#zoom-->/r $root/xml/$bllzx" \
			       -e "/<!--biking#captions-->/r $root/xml/$bcx" \
			       -e "/<!--biking#restrictions-->/r $root/xml/biking-restrictions.xml" \
			       -e "/<!--cycleway#lane-->/r $root/xml/$cwl" $root/xml/$tempxml
		fi
	fi
	
###	sed -f $themename_$sedfile -i $root/xml/$tempxml
###	rm $themename_$sedfile
	
	echo "Temp xml done"
	
	if [ "$lastimgscale" != "$imgscalefactor" ]; then
		echo " regenerating images"
		echo " regenerating images" >> $logfile
		startsec=`date +%s`
		sh tools/pnger.sh $imgscalefactor
		echo ""
		echo "PNGs created in: $((`date +%s`-startsec)) sec" >> $logfile
	fi
	mv themes/$themename .
	echo " updating XML"
	echo " updating XML" >> $logfile
		
	
	startsec=`date +%s`
	bash tools/theme_scaler.sh $xmlscalefactor $txtscalefactor $root/xml/$tempxml > $themename/$themename.xml
	echo "theme scaled in: $((`date +%s`-startsec)) sec" >> $logfile
	
	if [ "$winter" -eq "1" ]; then
		startsec=`date +%s`
		bash tools/$wintercol $themename/$themename.xml > $root/xml/$tempxml && cp $root/xml/$tempxml $themename/$themename.xml
		echo "winter theme changes in: $((`date +%s`-startsec)) sec" >> $logfile
	fi
	
	if ! xmllint --noout "$themename/$themename.xml" ; then
		echo "Theme XML is invalid."
	fi
	
	mkdir -p $themename/v2
	cat $themename/$themename.xml | sed 's/renderTheme.xsd" version="[0-9]\+"/renderTheme.xsd" version="2"/g
	s/src="file:\//src="file:..\//g 
	s/<circle r="/<circle radius="/g' > $themename/v2/$themename.map.xml
	
	if [ $rebuildimg -ge 0 ]; then
		echo " attaching required images to theme"
		echo " attaching required images to theme" >> $logfile
		startsec=`date +%s`
		bash tools/completer.sh $themename
		echo ""
		echo "PNGs copied in: $((`date +%s`-startsec)) sec" >> $logfile
	fi
	if [ "$winter" -eq "1" ]; then
		cp images/winter_paw.png $themename/$themename.png
	else
		cp images/paw.png $themename/$themename.png
	fi
	
	if [ ! -f $themename/.nomedia ]; then
		touch $themename/.nomedia
	fi
	
	echo "zipping"
	zip -qr $themename.zip $themename
	mv $themename $themename.zip themes/
	uploadstr=$uploadstr"themes/$themename.zip,"
	echo -n "themes/$themename.zip," >> $uploadpath
	lastimgscale=$imgscalefactor
done

bash $root/tools/svg_theme.sh
uploadstr=$uploadstr"themes_svg/paws_4.zip,"
echo -n "themes_svg/paws_4.zip," >> $uploadpath

bash $root/tools/locus_theme.sh "$winterarg"
uploadstr=$uploadstr"themes_svg/paws_4_LE.zip,"
echo -n "themes_svg/paws_4_LE.zip," >> $uploadpath

if [ "$winter" -eq "1" ]; then
	bash tools/winter_rename.sh $uploadpath
fi

localuploadtool="$root/tools/local_upload.sh"
if [ -f "$localuploadtool" ] ; then
	if [ "$winter" -eq "1" ]; then
		bash "$localuploadtool" `sed -e 's/themes\/winter_paws_4.zip//' -e 's/,/ /g' $uploadpath`
	else
		bash "$localuploadtool" `sed -e 's/themes\/paws_4.zip//' -e 's/,/ /g' $uploadpath`
	fi
fi

if [ -f "$errfile" ] ; then
	if [ -s "$errfile" ] ; then
		echo "There is an error:"
		cat "$errfile" | sed 's/^/ /'
		echo -n "Do you want to clear error log? (y/N):"
		read -r answer
		if [ "$answer" = "y" ] || [ "$answer" = "Y" ] ; then
			rm "$errfile"
		fi
	fi
fi

if [ "$release" -ne "1" ]; then
	if [ -f "$jarfile" ] ; then
		rm tag-mapping.xml
		unzip "$jarfile" tag-mapping.xml
		if [ -f tag-mapping.xml ] ; then
			if [ `diff tag-mapping.xml "$root/osmic-derivate/osmc-symbol-default/tag-mapping.xml" | grep '^>' | wc -l` -gt "0" ] ; then
				echo "There is some new symbol not included to map file.";
				echo "diff tag-mapping.xml $root/osmic-derivate/osmc-symbol-default/tag-mapping.xml";
			fi
		fi
	fi
	echo "Press return to see git status."
	read ans
	if [ "$ans" != "n" ]; then
		git status
	fi
	exit 0
fi

cp themes/$templatesrc/${templatesrc}.xml $template
cp themes_svg/paws_4/paws_4.xml $template4

git status
git commit -a -m "This is automatic commit of release r$releasestr ( build b$buildstr )"
git push

sh tools/$uploadscript "$root/$uploadpath" "$winterarg"
sh tools/notify.sh
