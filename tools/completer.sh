#!/bin/bash

root="$PAWS_RENDERER_ROOT"
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

imgfiles=`grep 'src=' "$root/$1/$1.xml" | sed 's/.*src=file:"\(.*\)".*/\1/g' | sort | tr ':' ' ' | awk '{print $3}' | tr -d '"' | sort -u`

for filepath in $imgfiles;
do
	pattern=`echo "$filepath" | rev | cut -d. -f2- | rev | LC_ALL=C sed -e 's/[^a-z/]/./g'`
	if ! grep -q -m1 "$pattern" $refreshlist ; then
		continue
	else
		echo -n ":"
	fi
	#mkdir -p $root/$1/`echo $filepath | rev | cut -d/ -f2- | rev`
	mkdir -p $root/$1/`dirname "$filepath"`
	suffix=`echo $filepath | rev | cut -d. -f1 | rev`
	cp "$root/$suffix/$filepath" "$root/$1/$filepath" || ( echo "$? file not found: $filepath ($root/$suffix/$filepath) ($root/$1/$filepath) ($pattern)" >> "$errfile" ; exit 1 )
done

dirfiles=`find "$root/$1" -name '*.png' | grep '\(.\+/\)\{3,\}.*' | rev | cut -d'/' -f1-2 | rev | sort | sed 's/^/\//'`
if diff <( echo "$imgfiles" | sed 's/^\([^/]\)/\/\1/' ) <( echo "$dirfiles" ) ; then
	diff <( echo "$imgfiles" | sed 's/^\([^/]\)/\/\1/' ) <( echo "$dirfiles" ) >> "$errfile"
fi
#cp -r "$root/xml/$basexml"  $root/$1/$1.xml
