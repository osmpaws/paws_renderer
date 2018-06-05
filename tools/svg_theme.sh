#!/bin/bash

root="/home/jans/Dokumenty/osm/renderer"
scalecfg="tools/image_scale.cfg"
osmcscalecfg="tools/osmc-symbol-scale.cfg"
transparencycfg="tools/image_transparency.cfg"
svgdir="svg"
svgpatternsdir="svg_patterns"
targetdir="themes_svg"
xmlsourcedir="themes"
themename="paws_4"
themecfg="tools/themes.cfg"
sedscript="$targetdir/sedscript.txt"
padding=1

cd $root

rm -r "$root/$targetdir/"
mkdir -p "$root/$targetdir/$themename"
#mv "$root/$svgdir/patterns" "$root/$svgdir/patterns_orig" && mv "$root/$svgpatternsdir/patterns" "$root/$svgdir/patterns"

files=`find $svgdir -type f -name "*.svg"`
filescount=`echo "$files" | wc -l`

sort -u -t',' -k2,4  "$themecfg" | grep -v "paws_4" |
while IFS=, read origthemename xmlscalefactor txtscalefactor imgscalefactor hiking biking revision
do
	newthemename=`echo $origthemename | sed 's/paws/paws_4/'`
	startsec=`date +%s`
	echo "XML start ."
	sh tools/theme_scaler.sh $xmlscalefactor $txtscalefactor $xmlsourcedir/$themename/$themename.xml | sed 's/\.\.\/renderTheme.xsd" version="[0-9]\+"/https:\/\/raw.githubusercontent.com\/mapsforge\/mapsforge\/dev\/resources\/renderTheme-v4.xsd" version="4" map-background-outside="#EEEEEE"/g
	s/src="file:\//src="file:/g
	s/<circle r="/<circle radius="/g
	s/\.png"/.svg"/g'  > $targetdir/$themename/$newthemename.xml
	echo -n "" > $sedscript
	
	
echo "XML done $((`date +%s`-startsec)) sec."
scale=$imgscalefactor
echo "SVG images scaling:"
filescounter=0
startsec=`date +%s`
echo "$files" | while read line;
do
	#echo $line
	filename=`basename "$line" | cut -d. -f1`
	#filename=`echo $line | rev | cut -d/ -f1 | rev | cut -d. -f1`
	#filepath=`dirname "$line"`
	filepath=`echo $line | rev | cut -d/ -f2- | rev | cut -d/ -f 2-`
	#size=`echo $filename | rev | cut -d- -f1 | rev`
	size=`echo $filename | awk -F '-' '{print $NF}'`
	iconname=`echo $filename | rev | cut -d- -f2- | rev | sed 's/[ -]/_/g'`
	
	scaletmp=`grep -h "^$iconname " $root/$scalecfg $root/$osmcscalecfg`
	extrascaletype=`echo "$scaletmp" | awk '{print $2}'`
	extrascale=`echo "$scaletmp" | awk '{print $3}'`
	
	
	if [ "$extrascaletype" = "" ]; then
		extrascale="1"
		extrascaletype="s"
	fi
	
	if [ "$extrascaletype" = "s" ]; then
		newsize=`echo "$size*$scale*$extrascale" | bc | cut -d. -f1`
		totalscale=`echo "$scale*$extrascale*100" | bc | cut -d. -f1`
	elif [ "$extrascaletype" = "f" ]; then
		if [ "$filepath" = "patterns" ] ; then
			newsize="$size"
		else
			newsize="$extrascale"
		fi
	fi
	
	transparency=`grep "$iconname " $root/$transparencycfg | awk '{print $2}'`
	if [ "$transparency" = "" ]; then
		transparency="1"
	fi
	
	mkdir -p "$targetdir/$themename/$filepath"

	#cp $line $targetdir/$themename/$filepath/$iconname.svg
	if [ ! -f $targetdir/$themename/$filepath/$iconname.svg ]; then
	if [ "$filepath" = "patterns" ] ; then
		#sed -e 's/></>\n</g -e s/;fill-opacity:[Nn]one//g' $line | grep -v 'id="canvas"' > $targetdir/$themename/$filepath/$iconname.svg
		#sed -e 's/></>\n</g' -e 's/;fill-opacity:[Nn]one//g' -e 's/viewBox="0 0 34 34"/viewBox="0 0 32 32"/' -e 's/rect x="1" y="1"/rect x="0" y="0"/' -e 's/transform="translate(1,1)"/transform="translate(0,0)"/' $line | grep -v 'id="canvas"' >$targetdir/$themename/$filepath/$iconname.svg
		line=`echo $line | sed -e 's/svg/svg_patterns/' -e 's/[0-9]\+/??/g'`
		sed -e 's/></>\n</g' -e 's/;[a-ZA-Z]\+-opacity:[Nn]one//g' $line | grep -v 'id="canvas"' > $targetdir/$themename/$filepath/$iconname.svg
	else
		sed -e 's/></>\n</g' -e 's/;[a-ZA-Z]\+-opacity:[Nn]one//g' $line | grep -v 'id="canvas"' > $targetdir/$themename/$filepath/$iconname.svg
	fi
	fi
	if [ "$extrascaletype" = "s" ]; then
		if [ "$filepath" = "osmc-symbols" ] ; then
			echo 's,'"$filepath/$iconname"'\.svg\",'"$filepath/$iconname"'\.svg\" symbol-scaling=\"size\" symbol-width=\"'"$newsize"'\" symbol-height=\"'"$newsize"'\" rotate=\"false\" repeat-start=\"'$((1 + RANDOM % 50))'\" repeat-gap=\"'$((100 + RANDOM % 50))'\" ,' >> $sedscript
		else
			echo 's,'"$filepath/$iconname"'\.svg\",'"$filepath/$iconname"'\.svg\" symbol-scaling=\"size\" symbol-width=\"'"$newsize"'\" symbol-height=\"'"$newsize"'\",' >> $sedscript
		fi
	elif [ "$extrascaletype" = "f" ]; then
		echo 's,'"$filepath/$iconname"'\.svg\",'"$filepath/$iconname"'\.svg\" symbol-scaling=\"size\" symbol-width=\"'"$newsize"'\" symbol-height=\"'"$newsize"'\",' >> $sedscript
	fi
	#filescounter=$((filescounter+1))
	#echo -en "\b\b\b\b\b"
	#progress=`echo "${filescounter}/${filescount}*100" | bc -l | cut -d'.' -f1`
	#echo -n "$progress %"
	#echo -n "."
done
echo "Images done $((`date +%s`-startsec)) sec."

echo ""

echo '/<\s*symbol / s/rotate="[^"]*" //g
/<\s*symbol / s/repeat-start="[^"]*" //g
/<\s*symbol / s/repeat-gap="[^"]*" //g' >> $sedscript
sed -i -f $sedscript $targetdir/$themename/$newthemename.xml

done
#rm $targetdir/$themename/$themename.xml.tmp

#mv "$root/$svgdir/patterns" "$root/$svgpatternsdir/patterns" && mv "$root/$svgdir/patterns_orig" "$root/$svgdir/patterns"
#rm -r $targetdir/$themename/patterns_orig
cd $targetdir
zip -qr $themename.zip $themename && cd ..


