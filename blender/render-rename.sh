#!/usr/bin/bash

frames=(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z)
sname=
offs=0

while getopts ":s:o:" opt; do
	case $opt in
		o) offs="$OPTARG"
		;;
		s) sname="$OPTARG"
		;;
		\?) echo "Invalid option -$OPTARG" >&2
		exit 1
		;;
	esac

	case $OPTARG in
		-*) echo "Option $opt needs a valid argument"
		exit 1
		;;
	esac
done

if [[ -z "$sname" ]]; then
	echo "A valid sprite name must be given using the '-s' param"
	exit 2
fi

for i in {01..25};
do
	ndx=$((10#$i - 1 + $offs))
	oldpath="./blender/render/00$i.png"
	newpath="./blender/render/$sname${frames[10#${ndx}]}0.png"
	find ./blender/render -type f -name "00$i.png" -exec mv -v $oldpath $newpath \;
done
