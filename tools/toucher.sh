#!/bin/bash

root="/home/jans/Dokumenty/osm/renderer"

cd $root/osmic-derivate
files=`find symbols patterns -type f`

cat | while read line ; do
	if [ "$line" = "" ] ; then
		continue
	fi
	searchstr=`echo "$line" | sed 's/[^a-z]/./g'`
	if echo "$files" | grep -q -m1 "$searchstr" ; then
		echo "touching:"
		echo "$files" | grep "$searchstr" | sed 's/^/ /'
		touch -c `echo "$files" | grep "$searchstr" | tr '\n' ' '`
	fi
done
