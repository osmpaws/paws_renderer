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
	# for actor in root.findall('{http://people.example.com}actor'):
	'''ns = {'real_person': 'http://people.example.com',
      'role': 'http://characters.example.com'}

for actor in root.findall('real_person:actor', ns):
'''
	
	for item in mapXmlRoot:
		print(item.tag)
		for tagItem in item:
			print(tagItem.attrib['key'],tagItem.attrib['value'])
			
	print(renderXmlRoot.keys())
	
	trial='  <way id=\'81947372\' timestamp=\'2016-05-31T05:17:49Z\' uid=\'2169558\' user=\'JandaM\' visible=\'true\' version=\'2\' changeset=\'39680185\'> \
    <nd ref=\'954841675\' /> \
    <nd ref=\'954862968\' /> \
    <nd ref=\'954872855\' /> \
    <nd ref=\'954854939\' /> \
    <nd ref=\'954841675\' /> \
    <tag k=\'building\' v=\'garage\' /> \
    <tag k=\'building:ruian:type\' v=\'18\' /> \
    <tag k=\'ref:ruian:building\' v=\'48553000\' /> \
    <tag k=\'source\' v=\'cuzk:ruian\' /> \
  </way>'
  
	pokus = ET.fromstring(trial)
	for item in pokus:
		print(item.tag, item.attrib)

main()
