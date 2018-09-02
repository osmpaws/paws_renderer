#/bin/bash

defaultname="adefaultsign"
symbolstype="way"
secsymbolstype="node"
target="../osmc-symbols"
svgrules="osmc-symbol.yaml"
renderrules="osmc-symbol.xml"
tagrules="tag-mapping.tpl"
osmcwhitebg="osmc-symbol-white.xml"
osmcorangebg="osmc-symbol-orange.xml"
osmcyellowbg="osmc-symbol-yellow.xml"
scalingfactor="osmc-symbol-scale.cfg"
actualsymbols="/home/hts/osm/nbh/osmc_symbols.lst"
possiblesymbols="osmc_symbols_possible.lst"
diffsymbols="osmc_symbols_diff.lst"

declare -A colors
colors["black"]="000000"
colors["blue"]="1579e0"
colors["brown"]="8b4513"
colors["gray"]="aaaaaa"
colors["green"]="00cd27"
colors["orange"]="f96f00"
colors["pink"]="ffc0cb"
colors["purple"]="b878dd"
colors["red"]="ff0000"
colors["white"]="ffffff"
colors["yellow"]="ffdd00"
colors["none"]="ffffff"

rm -r $target $possiblesymbols
echo -n "" > $tagrules
mkdir -p $target
echo "#osmc-symbol" > $svgrules
echo -n "" > $scalingfactor
echo "<!--OSMC symbols-->" > $renderrules
#bgclist=("black" "blue" "brown" "green" "orange" "purple" "red" "white" "yellow")
bgclist="black
black-circle
black-frame
black-round
blue
blue-circle
blue-frame
blue-round
brown
brown-circle
brown-frame
brown-round
gray
gray-circle
gray-frame
gray-round
green
green-circle
green-frame
green-round
orange
orange-circle
orange-frame
orange-round
purple
purple-circle
purple-frame
purple-round
red
red-circle
red-frame
red-round
white
white-circle
white-frame
white-round
yellow
yellow-circle
yellow-frame
yellow-round
none"

for bgcolor in $bgclist ;
do
	bgcolorxml=`echo $bgcolor | tr '-' '_'`
	bgfilename="osmcbg-"$bgcolor
	bgfilenamexml=`echo $bgfilename | tr '-' '_'`
	emptyfile="emptysign-rectangle"
	newname=`echo $emptyfile-*.svg | sed "s/$emptyfile/$bgfilename/"`
	
	sed "s/id=\"$emptyfile/id=\"$bgfilename/" $emptyfile-*.svg > $target/$newname
	
	echo '<!--OSMC symbols '$bgcolorxml' background-->
	<rule e="'$symbolstype'" k="osmc_background" v="'$bgcolorxml'" zoom-min="15">
		<rule e="'$symbolstype'" k="osmc_foreground" v="~">
			<lineSymbol src="file:/osmc-symbols/'$bgfilenamexml'.png" align-center="false" repeat="true" />
		</rule>' > "osmc-symbol-$bgcolor.xml"
	
	echo '<!--OSMC symbols '$bgcolorxml' '$secsymbolstype' background-->
	<rule e="'$secsymbolstype'" k="osmc_background" v="'$bgcolorxml'" zoom-min="15">
		<rule e="'$secsymbolstype'" k="osmc_foreground" v="~">
			<symbol src="file:/osmc-symbols/'$bgfilenamexml'.png" />
		</rule>' > "osmc-symbol-$bgcolor-$secsymbolstype.xml"
		
	
		if [[ $bgcolor =~ "-circle" ]]; then
			#bgstyle="_circle"
			#bgcolor=`echo $bgcolor | cut -d_ -f2`
			bgc=`echo $bgcolor | cut -d- -f1`
			bgchex=${colors[$bgc]}
			shieldpars="stroke_fill: \"#$bgchex\"
    stroke_width: 2
    opacity: 0.0
    rounded: 10
    padding: 2"
		elif [[ $bgcolor =~ "-round" ]]; then
			bgc=`echo $bgcolor | cut -d- -f1`
			bgchex=${colors[$bgc]}
			shieldpars="fill: \"#$bgchex\"
    stroke_fill: \"#000000\"
    stroke_width: 1
    padding: 2
    rounded: 10"
		elif [[ $bgcolor =~ "-frame" ]]; then
			#bgstyle="_frame"
			bgc=`echo $bgcolor | cut -d- -f1`
			bgchex=${colors[$bgc]}
			shieldpars="stroke_fill: \"#$bgchex\"
    stroke_width: 2
    opacity: 0.0
    rounded: 2
    padding: 2"
		elif [[ $bgcolor =~ "none" ]] || [ $bgcolor = "" ]; then
			bgc=`echo $bgcolor | cut -d- -f1`
			bgchex=${colors[$bgc]}
			shieldpars="fill: \"#$bgchex\"
    opacity: 0.0
    padding: 1"
		else
			#bgstyle=""
			bgchex=${colors[$bgcolor]}
			shieldpars="fill: \"#$bgchex\"
    stroke_fill: \"#000000\"
    stroke_width: 1
    padding: 1"
		fi
		
		echo "$bgfilename:
  fill: \"#$bgchex\"
  shield:
    $shieldpars" >> $svgrules
    echo "$bgfilenamexml s 0.7" | tr '-' '_' >> $scalingfactor
done

for file in $defaultname-*.svg;
do
	sign=`echo $file | cut -d- -f2- | rev | cut -d- -f2- | rev`
	signxml=`echo $sign | sed 's/^l$/L/' | sed 's/turned-t/turned_T/' | tr '-' '_'`
	
	for bgcolor in $bgclist ;
	do
		
		bgcolorxml=`echo $bgcolor | tr '-' '_'`
		if [[ $bgcolor =~ "-circle" ]]; then
			#bgstyle="_circle"
			#bgcolor=`echo $bgcolor | cut -d_ -f2`
			bgc=`echo $bgcolor | cut -d- -f1`
			bgchex=${colors[$bgc]}
			shieldpars="stroke_fill: \"#$bgchex\"
    stroke_width: 2
    opacity: 0.0
    rounded: 10
    padding: 2"
		elif [[ $bgcolor =~ "-round" ]]; then
			bgc=`echo $bgcolor | cut -d- -f1`
			bgchex=${colors[$bgc]}
			shieldpars="fill: \"#$bgchex\"
    stroke_fill: \"#000000\"
    stroke_width: 1
    padding: 2
    rounded: 10"
		elif [[ $bgcolor =~ "-frame" ]]; then
			#bgstyle="_frame"
			bgc=`echo $bgcolor | cut -d- -f1`
			bgchex=${colors[$bgc]}
			shieldpars="stroke_fill: \"#$bgchex\"
    stroke_width: 2
    opacity: 0.0
    rounded: 2
    padding: 2"
		elif [[ $bgcolor =~ "none" ]] || [ $bgcolor = "" ]; then
			bgc=`echo $bgcolor | cut -d- -f1`
			bgchex=${colors[$bgc]}
			shieldpars="fill: \"#$bgchex\"
    opacity: 0.0
    padding: 1"
		else
			#bgstyle=""
			bgchex=${colors[$bgcolor]}
			shieldpars="fill: \"#$bgchex\"
    stroke_fill: \"#000000\"
    stroke_width: 1
    padding: 1"
		fi
		
		echo "	<rule e=\"$symbolstype\" k=\"osmc_background\" v=\"$bgcolorxml\" zoom-min=\"15\">" >> $renderrules
		echo "		<osm-tag key=\"osmc_background\" value=\"$bgcolorxml\" renderable=\"false\" />" >> $tagrules
		
		for fgcolor in "red" "yellow" "blue" "green" "white" "black" "brown" "purple" "orange" "" ;
		do			
			if [ "$fgcolor" = "" ]; then
				if [ "$sign" = "shell-modern" ]; then
					fgchex=${colors["yellow"]}
				elif [ "$bgcolor" = "white" ]; then
					fgchex=${colors["black"]}
				else
					fgchex=${colors["white"]}
				fi
				colormix="$bgcolor"
				searchstr="^"$bgcolorxml":"$signxml"$"
				tagvalue="$signxml"
				pngfilename="$bgcolorxml"_"`echo $sign | tr '-' '_'`"
			else
				fgchex=${colors[$fgcolor]}
				fgcolorxml=`echo $fgcolor | tr '-' '_'`
				colormix="$bgcolor-$fgcolor"
				searchstr="^"$bgcolorxml":"$fgcolorxml"_"$signxml"$"
				tagvalue="$fgcolorxml"_"$signxml"
				pngfilename="$bgcolorxml"_"$fgcolorxml"_"`echo $sign | tr '-' '_'`"
			fi
			
			#this will filter out most of the combinations because we take only real ones (directly from PBFs)
			#comment this out if you want all the icons
			#echo " "$bgcolorxml":"$fgcolorxml"_"$signxml
			echo "$searchstr" | tr -d '^$' >> $possiblesymbols
			if ! echo $searchstr | grep -f - $actualsymbols -m1 --color=auto ; then
				continue
			fi
			
			echo "		<osm-tag key=\"osmc_foreground\" value=\"$tagvalue\" renderable=\"false\" />" >> $tagrules
			
			if [ "$fgcolor" = "$bgcolor" ]; then
				continue
			fi
			#if [ "$sign" = "wheelchair" ] && [ "$bgcolor" != "white" ] && ([ "$fgcolor" != "black" ] || [ "$fgcolor" != "blue" ] || [ "$fgcolor" != "red" ]); then
			#	continue
			#fi
			newname=`echo $file | sed "s/$defaultname/$colormix/"`
			sed "s/id=\"$defaultname/id=\"$colormix/" $file > $target/$newname
			
			symbol=`grep "$colormix" $target/$newname | tr '"' ' ' | awk '{print $2}'`
			if [ "$sign" = "bar" ] && [ "$bgcolor" = "white" ]; then
				echo "$symbol s 0.4" | tr '-' '_' >> $scalingfactor
			else
				echo "$symbol s 0.7" | tr '-' '_' >> $scalingfactor
			fi
			#if [ "$sign" != "bar" ] || [ "$bgcolor" != "white" ]; then
			#if [ "$symbolstype" = "way" ]; then
				echo "		<rule e=\"way\" k=\"osmc_foreground\" v=\""$tagvalue"\">
			<lineSymbol src=\"file:/osmc-symbols/"$pngfilename".png\" align-center=\"false\" repeat=\"true\" />
		</rule>" >> $renderrules
		
				echo "		<rule e=\"way\" k=\"osmc_foreground\" v=\""$tagvalue"\">
			<lineSymbol src=\"file:/osmc-symbols/"$pngfilename".png\" align-center=\"false\" repeat=\"true\" />
		</rule>" >> "osmc-symbol-$bgcolor.xml"
			#else
				echo "		<rule e=\"node\" k=\"osmc_foreground\" v=\""$tagvalue"\">
			<symbol src=\"file:/osmc-symbols/"$pngfilename".png\" />
		</rule>" >> $renderrules
		
				echo "		<rule e=\"node\" k=\"osmc_foreground\" v=\""$tagvalue"\">
			<symbol src=\"file:/osmc-symbols/"$pngfilename".png\" />
		</rule>" >> "osmc-symbol-$bgcolor-$secsymbolstype.xml"
			#fi
			
			#fi
			echo "$symbol:
  fill: \"#$fgchex\"
  shield:
    $shieldpars" >> $svgrules
		done
		echo "	</rule>" >> $renderrules
	done
done

for bgcolor in $bgclist ;
do
	echo '	</rule>' >> "osmc-symbol-$bgcolor.xml"
	echo '	</rule>' >> "osmc-symbol-$bgcolor-$secsymbolstype.xml"
	if ! grep '<lineSymbol ' "osmc-symbol-$bgcolor.xml" -m1 ; then
		echo '' > "osmc-symbol-$bgcolor.xml"
	fi
	if ! grep '<symbol ' "osmc-symbol-$bgcolor-$secsymbolstype.xml" -m1 ; then
		echo '' > "osmc-symbol-$bgcolor-$secsymbolstype.xml"
	fi
done

sort -t'"' -k2,4 -u -o $tagrules $tagrules

sort $possiblesymbols -o $possiblesymbols
comm -23 $actualsymbols $possiblesymbols > $diffsymbols

echo "Icons replicated to $target. $svgrules contains new rules for export in colors. Copy the content to appropriate yaml for export."

