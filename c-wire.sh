#!/bin/bash

file_chm=$1
station_type=$2
conso_type=$3
id_central=$4
help=$5

all_args=$*
nb_arg=$#

error=0
id=0

if ([ ! -z $file_chm ] && [ $file_chm == '-h' ]) || ([ ! -z $station_type ] && [ $station_type == '-h' ]) || ([ ! -z $conso_type ] && [ $conso_type == '-h' ]) || ([ ! -z $id_central ] && [ $id_central == '-h' ]) || ([ ! -z $help ] && [ $help == '-h' ])  ; then	# Check if -h	
	echo "A L'AIDE"
else
	if [ ! -z $file_chm ] && [ -e $file_chm ] ; then		# Check the file
		if [ ! -f $file_chm ] ; then
			echo "not file"
			error=2
		fi
	else
		echo "missing file"
		error=1
	fi


	if [ ! -z $station_type ] ; then		# Check the type of station
		if [ $station_type != 'hvb' ] && [ $station_type != 'hva' ] && [ $station_type != 'lv' ] ; then
			echo 'station type incorrect'
			error=2
		fi
	else
		echo 'No arguments for station type'
		error=1
	fi
	
	
	if [ ! -z $conso_type ] ; then		# Check the type of consummers
		case $conso_type in
			'indiv') if [ $station_type == 'hva' ] || [ $station_type == 'hvb' ] ; then
				echo "$station_type cannot be with $conso_type"
				error=3
			fi;;
			'all') if [ $station_type == 'hva' ] || [ $station_type == 'hvb' ] ; then
				echo "$station_type cannot be with $conso_type"
				error=3
			fi;;
			'comp') ;;
			*) echo 'consummers type not valid'
			error=2 ;;
		esac
	else
		echo 'No arguments for consummers type'
		error=1
	fi
	
	if [ $id_central -le 5 ] && [ $id_central -gt 0 ] ; then		# Check the id central
		id=1
	fi

	if [ $error -ne 0 ] ; then
		case $error in

			1) echo 'agrument missing';;
			2) echo 'argument not valid';;
			3) echo 'argument do no match';;
			*) echo 'Problem unknown';; 
		esac
		return
	fi
	echo "quoi
fi
