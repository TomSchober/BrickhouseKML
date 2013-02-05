#!/bin/bash
usage()
{
cat << EOF
usage: $0 options

Converting Brickhouse Tracking Data

OPTIONS:
   -h      Show this message (required)
   -c      CSV File (required)

EOF
}

CSVFILE=
while getopts “hc:” OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         c)
             CSVFILE=$OPTARG
             ;;
         ?)
             usage
             exit
             ;;
     esac
done

if [[ -z $CSVFILE ]]
then
     usage
     exit 1
fi

echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > newKml.kml
echo "<kml xmlns=\"http://earth.google.com/kml/2.0\">" >> newKml.kml
echo "<Document>" >> newKml.kml
echo "<Style id=\"pointStyle\"><LabelStyle><scale>0.5</scale></LabelStyle><IconStyle><scale>0.5</scale><Icon> <href>http://maps.google.com/mapfiles/kml/pal4/icon57.png</href> </Icon></IconStyle></Style>" >> newKml.kml


OLDIFS=$IFS
IFS=$'\n'
trackLines=( $(grep "" $CSVFILE) )
i=1
for trackLine in "${trackLines[@]}"
do
	lat=$(expr "$trackLine" : "[^,]*,[^,]*,\".*\",[^,]*,[^,]*,[^,]*,\([^,]*\)/[^,]*")
	lon=$(expr "$trackLine" : "[^,]*,[^,]*,\".*\",[^,]*,[^,]*,[^,]*,[^,]*/\([^,]*\)")
	timestamp=$(expr "$trackLine" : "\([^,]*\),[^,]*,\".*\",[^,]*,[^,]*,[^,]*,[^,]*/[^,]*")
	speed=$(expr "$trackLine" : "[^,]*,[^,]*,\".*\",\([^,]*\),[^,]*,[^,]*,[^,]*/[^,]*")
	knotsFromMph=0.86880973066898
	speed=$(printf "%.1f" $(echo "scale=2;$speed*$knotsFromMph" | bc))
	echo "<Placemark><styleUrl>#pointStyle</styleUrl><name>$i</name><description>$timestamp<br/>Speed:$speed knots</description><Point><coordinates>$lon,$lat</coordinates></Point></Placemark>" >> newKml.kml
	let i+=1
done
IFS=$OLDIFS

echo "</Document>" >> newKml.kml
echo "</kml>" >> newKml.kml