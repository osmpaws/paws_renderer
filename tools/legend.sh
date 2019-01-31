#!/bin/bash

# a legend tool

atlasprefdir=~"/.java/.userPrefs/Talent Atlas"
atlaspref="$atlasprefdir/prefs.xml"
atlasexec=~"/Dokumenty/osm/atlas/atlas.sh"

cp "$atlaspref" "${atlaspref}.bak"
target=`readlink -m result/way.map`
osmosis --rx file=source/way.osm --mw file="result/way.map" bbox=49.70,13.40,49.72,13.41
sed "s/<entry key=\"tileSource\"/<entry key=\"tileSource\" value=\"$target\"\/>/"
$atlasexec
cp "$atlasprefdir/${atlaspref}.bak" "$atlasprefdir/$atlaspref"
