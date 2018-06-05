#!/bin/bash

root="/home/jans/Dokumenty/osm/renderer"
scalecfg="tools/image_scale.cfg"
osmcscalecfg="tools/osmc-symbol-scale.cfg"
transparencycfg="tools/image_transparency.cfg"
svgdir="svg"
svgpatternsdir="svg_patterns"
targetdir="themes_svg"
xmlsourcedir="themes"
srcthemename="paws_4"
themename="paws_4_LE"
themecfg="tools/themes.cfg"
sedscript="$targetdir/sedscript.txt"
padding=1

cd $root

rm -r "$root/$targetdir/$themename"
mkdir -pv "$root/$targetdir/$themename"

cp images/paw.png $targetdir/$themename/$themename.png

sed -e 's/renderTheme-v4.xsd" version="4" map-background-outside="#EEEEEE"/renderTheme.xsd" version="1" locus-extended="1" fill-sea-areas="0"/' -e 's/src="file:/src="file:\//g' -e 's/<circle radius="/<circle r="/g' -e 's/symbol-width="\([0-9.]*\)"/symbol-width="\1dp"/' -e 's/ dy="\(-*[0-9.]*\)"/ dy="\1dp"/' -e 's/symbol-scaling="size"//g' -e 's/symbol-scaling="percent"//g' -e 's/symbol-height="[0-9.]*"//g'  -e 's/stroke-width="\([0-9.]*\)"/stroke-width="\1dp"/' -e 's/font-size="\([0-9.]*\)"/font-size="\1dp"/' $targetdir/$srcthemename/paws_4_S.xml > $targetdir/$themename/$themename.xml
#-e 's/symbol-percent="[0-9.]*"/symbol-width="20dp"/'

echo -n "" > $sedscript
grep 'line .* dy' $targetdir/$themename/$themename.xml | 
while read line
do
	origshift=`echo $line | sed 's/.*dy="\(-*[0-9.]*\)dp".*/\1/'`
	origsign=`echo $line | sed 's/.* dy="\(-*\)[0-9.]*dp".*/\1/'`
	if [ "$origsign" != "-" ]; then
		origsign="+"
	fi
	fixshift=5
	newshift=`echo "$origshift $origsign $fixshift" | bc | sed 's/^\./0./' | sed 's/^0$/0.1/'`
	newline=`echo "$line" | sed "s/ dy=\"-*[0-9.]*/ dy=\"$newshift/"`
	echo "s;$line;$newline;" >> $sedscript
done

sed -i -f $sedscript $targetdir/$themename/$themename.xml

cp -r `find $root/$targetdir/$srcthemename/* -type d` $targetdir/$themename

sed -i -e 's/width="100%"\s*height="100%"\s*viewBox="0 0 \([0-9.]*\) \([0-9.]*\)"/width="\1" height="\2" viewBox="0 0 \1 \2"/' -e 's/viewBox="0 0 \([0-9.]*\) \([0-9.]*\)"\s*width="100%"\s*height="100%"/width="\1" height="\2" viewBox="0 0 \1 \2"/' -e 's/height="100%"\s*width="100%"\s*viewBox="0 0 \([0-9.]*\) \([0-9.]*\)"/width="\1" height="\2" viewBox="0 0 \1 \2"/' -e 's/viewBox="0 0 \([0-9.]*\) \([0-9.]*\)"\s*height="100%"\s*width="100%"/width="\1" height="\2" viewBox="0 0 \1 \2"/' $targetdir/$themename/*/*.svg

cd $targetdir
zip -qr $themename.zip $themename && cd ..


