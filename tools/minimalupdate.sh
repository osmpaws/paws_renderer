#!/bin/bash

curworkdir=`pwd`
root="/home/jans/Dokumenty/osm/renderer"
scalecfg="tools/image_scale.cfg"
sttscalecfg="tools/image_scale.stt"
osmcscalecfg="tools/osmc-symbol-scale.cfg"
sttosmcscalecfg="tools/osmc-symbol-scale.stt"
transparencycfg="tools/image_transparency.cfg"
statusfile="imagestatus.txt"
refreshlist="imagerefresh.lst"
workstatusfile="imagestatus.wrk"
osmcsymlst=~hts/osm/nbh/osmc_symbols.lst
osmcsymlstold="osmc_symbol.lst"

cd $root

if ! diff -q $osmcsymlst $osmcsymlstold &> /dev/null; then
	#meld $osmcsymlst $osmcsymlstold
	echo "spustit replicator"
fi

find osmic-derivate/symbols osmic-derivate/patterns -type f -printf '%p %T@\n' > "$workstatusfile"
find osmic-derivate/osmc-symbols -type f -printf '%p\n' >> "$workstatusfile"

sort -o "$workstatusfile" "$workstatusfile"

if [ -f "$statusfile" ]; then
	comm -13 "$statusfile" "$workstatusfile" | sort | awk '{print $1}' | sed 's/osmic-derivate//' | rev | cut -d'-' -f2- | rev > "$refreshlist"
fi
cp "$workstatusfile" "$statusfile"




