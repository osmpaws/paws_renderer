#/bin/bash

defaultname="adefaultsign"
target="../osmc-symbols"
svgrules="osmc-symbol.yaml"
renderrules="osmc-symbol.xml"
osmcwhitebg="osmc-symbol-white.xml"
osmcorangebg="osmc-symbol-orange.xml"
osmcyellowbg="osmc-symbol-yellow.xml"
scalingfactor="osmc-symbol-scale.cfg"

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
blue
brown
green
orange
purple
red
white
yellow"

for bgcolor in $bgclist ;
do
	echo '<!--OSMC symbols '$bgcolor' background-->
	<rule e="way" k="osmc_background" v="'$bgcolor'" zoom-min="15">' > "osmc-symbol-$bgcolor.xml"
done

for file in $defaultname-*.svg;
do
	sign=`echo $file | cut -d- -f2- | rev | cut -d- -f2- | rev`
	for bgcolor in $bgclist ;
	do
		bgchex=${colors[$bgcolor]}
		echo "	<rule e=\"way\" k=\"osmc_background\" v=\"$bgcolor\" zoom-min=\"15\">" >> $renderrules
		
		for fgcolor in "red" "yellow" "blue" "green" "white" "black";
		do			
			fgchex=${colors[$fgcolor]}
						
			if [ "$fgcolor" = "$bgcolor" ]; then
				continue
			fi
			#if [ "$sign" = "wheelchair" ] && [ "$bgcolor" != "white" ] && ([ "$fgcolor" != "black" ] || [ "$fgcolor" != "blue" ] || [ "$fgcolor" != "red" ]); then
			#	continue
			#fi
			newname=`echo $file | sed "s/$defaultname/$bgcolor-$fgcolor/"`
			sed "s/id=\"$defaultname/id=\"$bgcolor-$fgcolor/" $file > $target/$newname
			
			symbol=`grep "$bgcolor-$fgcolor" $target/$newname | tr '"' ' ' | awk '{print $2}'`
			echo "$symbol s 0.5" | tr '-' '_' >> $scalingfactor
			if [ "$sign" != "bar" ] || [ "$bgcolor" != "white" ]; then
			echo "		<rule e=\"way\" k=\"osmc_foreground\" v=\""$fgcolor"_"`echo $sign | sed 's/^l$/L/' | sed 's/turned-t/turned_T/'`"\">
			<lineSymbol src=\"file:/osmc-symbols/"$bgcolor"_"$fgcolor"_"`echo $sign | tr '-' '_'`".png\" align-center=\"false\" repeat=\"true\" />
		</rule>" >> $renderrules
		
		        
			echo "		<rule e=\"way\" k=\"osmc_foreground\" v=\""$fgcolor"_"`echo $sign | sed 's/^l$/L/' | sed 's/turned-t/turned_T/'`"\">
			<lineSymbol src=\"file:/osmc-symbols/"$bgcolor"_"$fgcolor"_"`echo $sign | tr '-' '_'`".png\" align-center=\"false\" repeat=\"true\" />
		</rule>" >> "osmc-symbol-$bgcolor.xml"
		
			fi
			
			echo "$symbol:
  fill: \"#$fgchex\"
  shield:
    fill: \"#$bgchex\"
    stroke_fill: \"#000000\"
    stroke_width: 1    
    padding: 1" >> $svgrules
		done
		echo "	</rule>" >> $renderrules
	done
done

for bgcolor in $bgclist ;
do
	echo '	</rule>' >> "osmc-symbol-$bgcolor.xml"
done

echo "Icons replicated to $target. $svgrules contains new rules for export in colors. Copy the content to appropriate yaml for export."

