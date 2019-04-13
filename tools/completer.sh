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

imgfiles=`grep 'src=' "$root/$1/$1.xml" | sed 's/.*src=file:"\(.*\)".*/\1/g' | sort | tr ':' ' ' | awk '{print $3}' | tr -d '"'`

for filepath in $imgfiles;
do
	pattern=`echo "$filepath" | rev | cut -d. -f2- | rev | sed -e 's/[^a-z/]/./g'`
	if ! grep -q -m1 "$pattern" $refreshlist ; then
		continue
	else
		echo -n ":"
	fi
	#mkdir -p $root/$1/`echo $filepath | rev | cut -d/ -f2- | rev`
	mkdir -p $root/$1/`basename "$filepath"`
	suffix=`echo $filepath | rev | cut -d. -f1 | rev`
	cp "$root/$suffix/$filepath" "$root/$1/$filepath" || echo "$? file not found: $filepath ($root/$suffix/$filepath) ($root/$1/$filepath) ($pattern)" >> "$errfile"
done

#cp -r "$root/xml/$basexml"  $root/$1/$1.xml
