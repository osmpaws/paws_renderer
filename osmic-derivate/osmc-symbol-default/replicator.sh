#/bin/bash

defaultname="adefaultsign"
symbolstype="way"
target="../osmc-symbols"
svgrules="osmc-symbol.yaml"
renderrules="osmc-symbol.xml"
osmcwhitebg="osmc-symbol-white.xml"
osmcorangebg="osmc-symbol-orange.xml"
osmcyellowbg="osmc-symbol-yellow.xml"
scalingfactor="osmc-symbol-scale.cfg"
actualsymbols="/home/hts/osm/nbh/osmc_symbols.lst"

declare -A colors
colors["black"]="000000"
colors["blue"]="1579e0"
colors["brown"]="8b4513"
colors["green"]="00cd27"
colors["orange"]="f96f00"
colors["purple"]="b878dd"
colors["red"]="ff0000"
colors["white"]="ffffff"
colors["yellow"]="ffdd00"

rm -r $target
mkdir -p $target
echo "#osmc-symbol" > $svgrules
echo -n "" > $scalingfactor
echo "<!--OSMC symbols-->" > $renderrules
#bgclist=("black" "blue" "brown" "green" "orange" "purple" "red" "white" "yellow")
bgclist="black
black-circle
blue
blue-circle
brown
green
green-circle
green-frame
orange
orange-circle
purple
red
red-circle
red-frame
white
white-circle
yellow
yellow-circle
yellow-frame"

for bgcolor in $bgclist ;
do
	bgcolorxml=`echo $bgcolor | tr '-' '_'`
	echo '<!--OSMC symbols '$bgcolorxml' background-->
	<rule e="'$symbolstype'" k="osmc_background" v="'$bgcolorxml'" zoom-min="15">' > "osmc-symbol-$bgcolor.xml"
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
		elif [[ $bgcolor =~ "-frame" ]]; then
			#bgstyle="_frame"
			bgc=`echo $bgcolor | cut -d- -f1`
			bgchex=${colors[$bgc]}
			shieldpars="stroke_fill: \"#$bgchex\"
    stroke_width: 2
    opacity: 0.0
    rounded: 2
    padding: 2"
		else
			#bgstyle=""
			bgchex=${colors[$bgcolor]}
			shieldpars="fill: \"#$bgchex\"
    stroke_fill: \"#000000\"
    stroke_width: 1
    padding: 1"
		fi
		
		echo "	<rule e=\"$symbolstype\" k=\"osmc_background\" v=\"$bgcolorxml\" zoom-min=\"15\">" >> $renderrules
		
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
			echo $searchstr | grep -f - $actualsymbols -m1 --color=auto
			if [ $? -ne 0 ]; then
				continue
			fi
			
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
			if [ "$symbolstype" = "way" ]; then
				echo "		<rule e=\"way\" k=\"osmc_foreground\" v=\""$tagvalue"\">
			<lineSymbol src=\"file:/osmc-symbols/"$pngfilename".png\" align-center=\"false\" repeat=\"true\" />
		</rule>" >> $renderrules
		
				echo "		<rule e=\"way\" k=\"osmc_foreground\" v=\""$tagvalue"\">
			<lineSymbol src=\"file:/osmc-symbols/"$pngfilename".png\" align-center=\"false\" repeat=\"true\" />
		</rule>" >> "osmc-symbol-$bgcolor.xml"
			else
				echo "		<rule e=\"node\" k=\"osmc_foreground\" v=\""$tagvalue"\">
			<symbol src=\"file:/osmc-symbols/"$pngfilename".png\" />
		</rule>" >> $renderrules
		
				echo "		<rule e=\"node\" k=\"osmc_foreground\" v=\""$tagvalue"\">
			<symbol src=\"file:/osmc-symbols/"$pngfilename".png\" />
		</rule>" >> "osmc-symbol-$bgcolor.xml"
			fi
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
done

echo "Icons replicated to $target. $svgrules contains new rules for export in colors. Copy the content to appropriate yaml for export."

