#!make

# makefile for https://github.com/gfis/mastr - Marktstammdatenregister
# 2025-03-30, Gfis
#
# Needs the following tools:
#   make, perl, find (Unix versions)
#   unzip    unpacking
#   iconv    UTF conversion
#   xmllint  XML reformatting
#----
all:

# (1) download most recent version from <https://www.marktstammdatenregister.de/MaStR/Datendownload> (zip, about 2.2 GB)

#----
unz: # (2) unzip, 338 files, 46 GB
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
