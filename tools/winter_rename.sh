#!/bin/bash

workdir=`readlink -m $(pwd)`
reverse=0
uploadpath="$1"

if [ "$2" = "-r" ]; then
	reverse=1
	sed -i 's/winter_paws/paws/g' $uploadpath
else
	sed -i 's/paws/winter_paws/g' $uploadpath
fi

find themes* -type f -name '*paws*' |
while read -r filename ; do
	if echo "$filename" | rev | cut -d'.' -f1 | rev | grep 'zip' ; then
		rm "$filename"
	fi
	dname=`dirname "$filename"`
	bname=`basename "$filename"`
	if [ "$reverse" -eq "0" ]; then
		mv "$filename" "$dname/winter_$bname"
	else
		bname=`echo "$bname" | sed 's/winter_//'`
		mv "$filename" "$dname/$bname"
	fi
done

find themes* -type d -name '*paws*' |
while read -r filename ; do
	if [ "$reverse" -eq "0" ]; then
		winterfilename=`echo "$filename" | sed 's/paws/winter_paws/g'`
	else
		winterfilename=`echo "$filename" | sed 's/winter_paws/paws/g'`
	fi
	mv "$filename" "$winterfilename"
	
	cd "$winterfilename"
	dname=`dirname $(pwd)`
	bname=`basename $(pwd)`
	cd ..
	zip -qr $bname.zip $bname
	cd "$workdir"
done
