#!/bin/bash

# a legend tool

atlasprefdir=~/.java/.userPrefs/Talent\ Atlas
atlaspref="prefs.xml"
atlasexec=~/Dokumenty/osm/atlas/atlas.sh

cp "${atlasprefdir}/$atlaspref" "./${atlaspref}.bak"

while read -r key value caption reference tracktype; do
	caption=$(echo $caption | tr '#' ' ')
	tracktype=$(echo $tracktype | tr '#' ' ')
	echo "/k=\"highway\"/ s;k=\"[^\"]*;k=\"${key};
/k=\"highway\"/ s;v=\"[^\"]*;v=\"${value};
/k=\"name\" v=\"popisek\"/ s;v=\"[^\"]*;v=\"${caption};
/k=\"ref\"/ s;v=\"[^\"]*;v=\"${reference};
" > config.sed
	if [ "$tracktype" != "" ] && [ "$tracktype" != " " ]; then
		echo "/k=\"name\" v=\"popisek\"/ s;k=\"[^\"]*;k=\"tracktype;
/k=\"tracktype\" v=\"popisek\"/ s;v=\"[^\"]*;v=\"${tracktype};
" >> config.sed
	fi
	
	sed -f config.sed source/highway.osm > source/temp.osm
	target=`readlink -m result`/temp.map
	osmosis --rx file=source/temp.osm --mw file="$target" bbox=49.70,13.40,49.72,13.42
	wait

	#sed "/key=\"tileSource\"/s/value=\"[^\"]*;value=\"${target};" "${atlasprefdir}/$atlaspref"
	echo "/key=\"tileSource\"/ s;value=\"[^\"]*;value=\"${target};
	/key=\"latitude\"/ s;value=\"[^\"]*;value=\"49.71893716774;
	/key=\"longitude\"/ s;value=\"[^\"]*;value=\"13.40965376089;
	/key=\"zoomLevel\"/ s;value=\"[^\"]*;value=\"18;
	/key=\"boundsWidth\"/ s;value=\"[^\"]*;value=\"950;
	" > sedscript.sed

	sed -i -f sedscript.sed "${atlasprefdir}/$atlaspref"

	$atlasexec &
	counter=0
	while [ 1 -eq 1 ]; do
		windowId=$(xprop -root -f _NET_ACTIVE_WINDOW 0x ' $0\n' _NET_ACTIVE_WINDOW | awk '{print $2}') || continue
		if xprop -id $windowId | grep -q '"Atlas -' ; then
			windowPID=`xprop -id $windowId | grep '_NET_WM_PID(CARDINAL)' | awk '{print $3}'`
			sleep 0.5
			import -window "$windowId" -crop 850x400+0+50 -trim images/${key}_${value}${trackype}.png
			kill $windowPID
			break
		fi
		counter=$((counter+1))
		if [ "$counter" -gt "10000000" ] ; then
			break
		fi
	done
	
	echo $key $value $caption $reference $tracktype >> info.log
done < tool/config_ways.txt

mv "./${atlaspref}.bak" "${atlasprefdir}/$atlaspref"
