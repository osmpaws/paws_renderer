#/bin/bash

defaultname="adefaultsign"
target="../osmc-symbols"
svgrules="osmc-symbol.yaml"
renderrules="osmc-symbol.xml"
osmcwhitebg="osmc-symbol-white.xml"
osmcorangebg="osmc-symbol-orange.xml"
osmcyellowbg="osmc-symbol-yellow.xml"
scalingfactor="osmc-symbol-scale.cfg"

rm -r $target
mkdir -p $target
echo "#osmc-symbol" > $svgrules
echo -n "" > $scalingfactor
echo "<!--OSMC symbols-->" > $renderrules
echo '<!--OSMC symbols white background-->
	<rule e="way" k="osmc_background" v="white" zoom-min="15">' > $osmcwhitebg
echo '<!--OSMC symbols orange background-->
	<rule e="way" k="osmc_background" v="orange" zoom-min="15">' > $osmcorangebg
echo '<!--OSMC symbols yellow background-->
	<rule e="way" k="osmc_background" v="yellow" zoom-min="15">' > $osmcyellowbg

for file in $defaultname-*.svg;
do
	sign=`echo $file | cut -d- -f2- | rev | cut -d- -f2- | rev`
	for bgcolor in "white" "yellow" "orange";
	do
		if [ "$bgcolor" = "white" ]; then
			bgchex="ffffff"
		elif [ "$bgcolor" = "yellow" ]; then
			bgchex="ffdd00"
		elif [ "$bgcolor" = "orange" ]; then
			bgchex="f96f00"
		else
			echo "Bgcolor error!"
			exit 1
		fi
		echo "	<rule e=\"way\" k=\"osmc_background\" v=\"$bgcolor\" zoom-min=\"15\">" >> $renderrules
		
		for fgcolor in "red" "yellow" "blue" "green" "white" "black";
		do			
			if [ "$fgcolor" = "red" ]; then
				fgchex="ff0000"
			elif [ "$fgcolor" = "yellow" ]; then
				fgchex="ffdd00"
			elif [ "$fgcolor" = "blue" ]; then
				fgchex="1579e0"
			elif [ "$fgcolor" = "green" ]; then
				fgchex="00cd27"
			elif [ "$fgcolor" = "white" ]; then
				fgchex="ffffff"
			elif [ "$fgcolor" = "black" ]; then
				fgchex="000000"
			else
				echo "Fgcolor error!"
				exit 1
			fi
			
			if [ "$fgcolor" = "$bgcolor" ]; then
				continue
			fi
			if [ "$sign" = "wheelchair" ] && [ "$bgcolor" != "white" ] && ([ "$fgcolor" != "black" ] || [ "$fgcolor" != "blue" ] || [ "$fgcolor" != "red" ]); then
				continue
			fi
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

echo '	</rule>' >> $osmcwhitebg
echo '	</rule>' >> $osmcorangebg
echo '	</rule>' >> $osmcyellowbg
echo "Icons replicated to $target. $svgrules contains new rules for export in colors. Copy the content to appropriate yaml for export."

