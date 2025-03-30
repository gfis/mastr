#!make

# makefile for https://github.com/gfis/mastr - Marktstammdatenregister
# 2025-03-30, Gfis
#
# Needs the following tools:
#   make, perl, find (Unix versions)
#   unzip    unpacking
#   iconv    UTF conversion
#   xmllint  XML reformatting
#   inst2xsd instance generator from xmlbeans
#----
none: # avoid inadvertently calls


# (1) download most recent version from <https://www.marktstammdatenregister.de/MaStR/Datendownload> (zip, about 2.2 GB)

all: unpack reform schemata
#----
unpack: # (2) unzip, 338 files, 46 GB
	cd data ; unzip Gesamt*
#----
iconvl: # list the supported Unicode encodings
	iconv -l | grep UTF
reform: # convert all files to UTF-8 (only 24.4 GB), and indent them
	mkdir xml || :
	find data -iname "*.xml" | perl -pe "s/data\///" | xargs -innn make reform1 FILE=nnn
reform1:
	# --> $(FILE)
	iconv -f UTF-16 -t UTF-8 data/$(FILE) \
	| perl -pe 's/^([^\-]*\-)(16)/$${1}8/;' \
	| xmllint --format - > xml/$(FILE)
#----
schemata: schema_0 schema_1 # create schemata for all types of mastr files
schema_0:
	mkdir xsd || :
	find xml -iname "*.xml" | grep -v "_" | perl -pe "s/xml\///; s/\.xml//;" | xargs -innn make schema_01 FILE=nnn
schema_01:
	inst2xsd -simple-content-types string -enumerations never -outDir xsd -outPrefix $(FILE) xml/$(FILE).xml ; mv -v xsd/$(FILE)0.xsd xsd/$(FILE).xsd
schema_1:
	find xml -iname "*_1.xml" | perl -pe "s/xml\///; s/_1\.xml//; " | xargs -innn make schema_11 FILE=nnn
schema_11:
	inst2xsd -simple-content-types string -enumerations never -outDir xsd -outPrefix $(FILE) xml/$(FILE)_1.xml ; mv -v xsd/$(FILE)0.xsd xsd/$(FILE).xsd
#----
validate: # validate all xml files against the generated schemata  
	make valid0 2>&1 | tee validate.log
valid0:
	find xsd -iname "*.xsd" | perl -pe "s/xsd\///; s/\.xsd//;" | xargs -innn make valid1 FILE=nnn
valid1:
	find xml -iname "$(FILE)*.xml" | xargs -innn xmllint --noout --schema xsd/$(FILE).xsd nnn 2>&1
