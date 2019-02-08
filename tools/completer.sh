#!/bin/bash

root="/home/jans/Dokumenty/osm/renderer"
basexml="base2.xml"
refreshlist="imagerefresh.lst"
errfile="$root/errfile.txt"

if [ $# -lt 1 ]; then
	echo "No theme name specified."
	exit 1
fi
name=$1

#rm -r "$root/$1/"
#mkdir "$root/$1"

imgfiles=`grep 'src=' "$root/$1/$1.xml" | sed 's/.*src=file:"\(.*\)".*/\1/g' | sort | tr ':' ' ' | awk '{print $3}' | tr -d '"'`

for filepath in $imgfiles;
do
	pattern=`echo "$filepath" | rev | cut -d. -f2- | rev | sed 's/[a-z/]/./g'`
	if ! grep -q "$pattern" $refreshlist ; then
		continue
	else
		echo -n ":"
	fi
	mkdir -p $root/$1/`echo $filepath | rev | cut -d/ -f2- | rev`
	suffix=`echo $filepath | rev | cut -d. -f1 | rev`
	cp "$root/$suffix/$filepath" "$root/$1/$filepath" || echo "file not found: $filepath" >> "$errfile"
done

#cp -r "$root/xml/$basexml"  $root/$1/$1.xml
