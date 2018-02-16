import csv
import re
import sys
import os

#python snapper_csv_helper.py testdata.txt

filename = sys.argv[1]
nameMinusExt = os.path.splitext(os.path.basename(filename))[0]

regex = re.compile(r' {4},+')

f = open(nameMinusExt + '.csv', 'wb')
writer = csv.writer(f)
with open(filename, 'rb') as file:
	for line in file:
		fixedLine = line.replace('\n', '')
		match = regex.search(fixedLine)
		if match:
			#print fixedLine
			myList = fixedLine.split(",")
			for i, s in enumerate(myList):
				myList[i] = s.strip()
			if myList:
				writer.writerow(myList)
				#print myList
