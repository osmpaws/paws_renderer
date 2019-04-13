#!/bin/bash

root="$PAWS_RENDERER_ROOT"
scalecfg="tools/image_scale.cfg"
osmcscalecfg="tools/osmc-symbol-scale.cfg"
transparencycfg="tools/image_transparency.cfg"
scaler="$root/tools/theme_locus_scaler.sh"
svgdir="svg"
svgpatternsdir="svg_patterns"
targetdir="themes_svg"
xmlsourcedir="themes"
srcthemename="paws_4"
themename="paws_4_LE"
themecfg="tools/themes.cfg"
sedscript="$targetdir/sedscript.txt"
tempfile="$targetdir/temp.txt"
padding=1
winter=0

if [ "$1" = "-w" ]; then
	winter=1
fi

cd $root

rm -r "$root/$targetdir/$themename"
mkdir -pv "$root/$targetdir/$themename"

if [ "$winter" -eq "1" ]; then
	cp images/winter_paw.png $targetdir/$themename/$themename.png
else
	cp images/paw.png $targetdir/$themename/$themename.png
fi


sed -e 's/renderTheme-v4.xsd" version="4" map-background-outside="#EEEEEE"/renderTheme.xsd" version="1" locus-extended="1" fill-sea-areas="0"/' -e 's/src="file:/src="file:\//g' -e 's/<circle radius="/<circle r="/g' -e 's/symbol-width="\([0-9.]*\)"/symbol-width="\1dp"/' -e 's/ dy="\(-*[0-9.]*\)"/ dy="\1dp"/' -e 's/symbol-scaling="size"//g' -e 's/symbol-scaling="percent"//g' -e '/<area /! s/symbol-height="[0-9.]*"//g' -e 's/symbol-height="\([0-9.]*\)"/symbol-height="\1dp"/' -e 's/stroke-width="\([0-9.]*\)"/stroke-width="\1dp"/' -e 's/font-size="\([0-9.]*\)"/font-size="\1dp"/' $targetdir/$srcthemename/paws_4_S.xml > $targetdir/$themename/$themename.xml
#-e 's/symbol-percent="[0-9.]*"/symbol-width="20dp"/'

### replication start ###
startline=`sed -n '/<!--hiking#lines#high#zoom#4-->/,/^\s*$/=' $targetdir/$themename/$themename.xml | head -n1`
endline=`sed -n '/<!--hiking#lines#high#zoom#4-->/,/^\s*$/=' $targetdir/$themename/$themename.xml | tail -n1`

sed -n '/<!--hiking#lines#high#zoom#4-->/,/^\s*$/p' $targetdir/$themename/$themename.xml | sed -e '/zoom-max/! s/zoom-min="\([0-9]\+\)"/zoom-min="\1" zoom-max="\1"/' -e 's/dp"/"/g' > $sedscript
echo "" >> $sedscript

sed -i "$((startline+1)),${endline}d" $targetdir/$themename/$themename.xml

echo -n "" > $tempfile
bash $scaler 1 2.5 $sedscript | sed -e 's/zoom-\(m[ia][nx]\)="[0-9]\+"/zoom-\1="14"/g' -e 's/ dy="\(-*[0-9.]*\)"/ dy="\1dp"/' -e 's/stroke-width="\([0-9.]*\)"/stroke-width="\1dp"/' >> $tempfile
bash $scaler 1 3.5 $sedscript | sed -e 's/zoom-\(m[ia][nx]\)="[0-9]\+"/zoom-\1="15"/g' -e 's/ dy="\(-*[0-9.]*\)"/ dy="\1dp"/' -e 's/stroke-width="\([0-9.]*\)"/stroke-width="\1dp"/' >> $tempfile
bash $scaler 1 4.5 $sedscript | sed -e 's/zoom-\(m[ia][nx]\)="[0-9]\+"/zoom-\1="16"/g' -e 's/ dy="\(-*[0-9.]*\)"/ dy="\1dp"/' -e 's/stroke-width="\([0-9.]*\)"/stroke-width="\1dp"/' >> $tempfile
bash $scaler 1 5.5 $sedscript | sed -e 's/zoom-\(m[ia][nx]\)="[0-9]\+"/zoom-\1="17"/g' -e 's/ dy="\(-*[0-9.]*\)"/ dy="\1dp"/' -e 's/stroke-width="\([0-9.]*\)"/stroke-width="\1dp"/' >> $tempfile
bash $scaler 1 6.5 $sedscript | sed -e 's/zoom-\(m[ia][nx]\)="[0-9]\+"/zoom-\1="18"/g' -e 's/ dy="\(-*[0-9.]*\)"/ dy="\1dp"/' -e 's/stroke-width="\([0-9.]*\)"/stroke-width="\1dp"/' >> $tempfile
bash $scaler 1 7.5 $sedscript | sed -e 's/zoom-\(m[ia][nx]\)="[0-9]\+"/zoom-\1="19"/g' -e 's/ dy="\(-*[0-9.]*\)"/ dy="\1dp"/' -e 's/stroke-width="\([0-9.]*\)"/stroke-width="\1dp"/' >> $tempfile
bash $scaler 1 9.5 $sedscript | sed -e 's/zoom-\(m[ia][nx]\)="[0-9]\+"/zoom-\1="20"/g' -e 's/ dy="\(-*[0-9.]*\)"/ dy="\1dp"/' -e 's/stroke-width="\([0-9.]*\)"/stroke-width="\1dp"/' >> $tempfile
bash $scaler 1 10.5 $sedscript | sed -e 's/zoom-\(m[ia][nx]\)="[0-9]\+"/zoom-\1="21"/g' -e 's/ dy="\(-*[0-9.]*\)"/ dy="\1dp"/' -e 's/stroke-width="\([0-9.]*\)"/stroke-width="\1dp"/' -e 's/zoom-max="[0-9]\+"//' >> $tempfile

sed -i "/<!--hiking#lines#high#zoom#4-->/r $tempfile" $targetdir/$themename/$themename.xml
rm "$tempfile"
### replication end ###

echo -n "" > $sedscript
grep 'line .* dy' $targetdir/$themename/$themename.xml | 
while read line
do
	origshift=`echo $line | sed 's/.*dy="\(-*[0-9.]*\)dp".*/\1/'`
	origsign=`echo $line | sed 's/.* dy="\(-*\)[0-9.]*dp".*/\1/'`
	if [ "$origsign" != "-" ]; then
		origsign="+"
	fi
	fixshift=0
	newshift=`echo "$origshift $origsign $fixshift" | bc | sed 's/^\./0./' | sed 's/^0$/0.1/'`
	newline=`echo "$line" | sed "s/ dy=\"-*[0-9.]*/ dy=\"$newshift/"`
	echo "s;$line;$newline;" >> $sedscript
done

echo "/<!--smooth_line-->/ s/\/>.*/curve=\"cubic\" \/>/" >> $sedscript

sed -i -f $sedscript $targetdir/$themename/$themename.xml

if ! xmllint --noout "$targetdir/$themename/$themename.xml" ; then
	echo "Theme XML is invalid."
fi

cp -r `find $root/$targetdir/$srcthemename/* -type d` $targetdir/$themename

sed -i -e 's/width="100%"\s*height="100%"\s*viewBox="0 0 \([0-9.]*\) \([0-9.]*\)"/width="\1" height="\2" viewBox="0 0 \1 \2"/' -e 's/viewBox="0 0 \([0-9.]*\) \([0-9.]*\)"\s*width="100%"\s*height="100%"/width="\1" height="\2" viewBox="0 0 \1 \2"/' -e 's/height="100%"\s*width="100%"\s*viewBox="0 0 \([0-9.]*\) \([0-9.]*\)"/width="\1" height="\2" viewBox="0 0 \1 \2"/' -e 's/viewBox="0 0 \([0-9.]*\) \([0-9.]*\)"\s*height="100%"\s*width="100%"/width="\1" height="\2" viewBox="0 0 \1 \2"/' $targetdir/$themename/*/*.svg

cd $targetdir
if [ ! -f $themename/.nomedia ]; then
	touch $themename/.nomedia
fi
zip -qr $themename.zip $themename && cd ..


