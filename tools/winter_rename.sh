#!/bin/bash

workdir=`readlink -m $(pwd)`
uploadpath="$1"

sed -i 's/paws/winter_paws/g' $uploadpath

find themes* -type f -name 'paws*' |
while read -r filename ; do
	if echo "$filename" | rev | cut -d'.' -f'1' | rev | grep 'zip' ; then
		rm "$filename"
	fi
	dname=`dirname "$filename"`
	bname=`basename "$filename"`
	mv -v "$filename" "$dname/winter_$bname"
done

find themes* -type d -name 'paws*' |
while read -r filename ; do
	winterfilename=`echo "$filename" | sed 's/paws/winter_paws/g'`
	mv -v "$filename" "$winterfilename"
	cd "$winterfilename"
	dname=`dirname $(pwd)`
	bname=`basename $(pwd)`
	cd ..
	zip -qr $bname.zip $bname
	cd "$workdir"
done
