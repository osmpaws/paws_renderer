#!/bin/bash

root="/home/jans/Dokumenty/osm/renderer"

cd $root/osmic-derivate
files=`find symbols patterns -type f`

cat | while read line ; do
	searchstr=`echo "$line" | sed 's/[^a-z]/./g'`
	touch -c `echo "$files" | grep "$searchstr"`
done
