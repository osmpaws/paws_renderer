#!/usr/bin/python

import xml.etree.ElementTree as ET
import sys

def main():
	print('tag-mapping xml file: ', sys.argv[1])
	print('render xml file: ', sys.argv[2])
	
	mapXmlTree = ET.parse(sys.argv[1])
	mapXmlRoot = mapXmlTree.getroot()
	
	renderXmlTree = ET.parse(sys.argv[2])
	renderXmlRoot = renderXmlTree.getroot()
	
	for item in mapXmlRoot:
		print(item.tag)
		for tagItem in item:
			print(tagItem.attrib['key'],tagItem.attrib['value'])

main()
