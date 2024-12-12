#!/bin/bash
error=0
file_chm=$1
station_type=$2
conso_type=$3
id_central=$4
help=$5

all_args=$*
nb_arg=$#

help=0
id=0
sec_trait=0
time_start=`date +%s`


function c_wire {
	for arg in ${all_args} ; do
		if [ ! -z ${arg} ] && [ ${arg} == '-h' ] ; then	# Check if -h	
			help=1
		fi
	done

	if [ ${help} -eq 1 ]  ; then		# print the help
		echo
		echo "Use : ./c-wire.sh [FILE] [STATION TYPE] [CONSUMMER TYPE].. [OPTION]\n"
		echo "FILE :		The directory of the file you want to analyse. It has to be a file and can be a relative path or an absolute one."
		echo "STATION TYPE :	The type of station you want to analyse. Possible values :
		* hvb
		* hva
		* lv"
		echo "CONSUMMER TYPE :The type of consumer you want to analyse. Possible values :
		* comp ; compagnies type of consumers
		* indiv ; individual consumers 
		* all ; all types of consummers"
		echo "			Warning hva and hvb cannot be with indiv or all."
		echo "OPTION :"
		echo "  -h --help 	To show the help screen. Helps on how to use the function. This option has priority"
		echo "   N 		with N the number of the central/powerplant we want to analyse. The number is between 1 and 5 and has to exist within the file given."
	else
		if [ ! -z ${file_chm} ] && [ -e ${file_chm} ] ; then		# Check the file
			if [ ! -f ${file_chm} ] ; then
				echo "not file"
				echo "Temps de traitement : ${sec_trait}s"
				return 2
			elif [ ${file_chm##*.} != 'dat' ] && [ ${file_chm##*.} != 'csv' ] ; then
				echo "file format not accepted"
				return 2
			fi
		else
			echo ${file_chm}
			echo "missing file"
			echo "Temps de traitement : ${sec_trait}s"
			return 1
		fi


		if [ ! -z ${station_type} ] ; then		# Check the type of station
			if [ ${station_type} != 'hvb' ] && [ ${station_type} != 'hva' ] && [ ${station_type} != 'lv' ] ; then
				echo 'station type incorrect'
				echo "Temps de traitement : ${sec_trait}s"
				return 2
			fi
		else
			echo 'No arguments for station type'
			echo "Temps de traitement : ${sec_trait}s"
			return 1
		fi
		
		
		if [ ! -z ${conso_type} ] ; then		# Check the type of consummers
			case ${conso_type} in
				'indiv') if [ ${station_type} == 'hva' ] || [ ${station_type} == 'hvb' ] ; then
					echo "${station_type} cannot be with ${conso_type}"
					echo "Temps de traitement : ${sec_trait}s"
					return 3
				fi;;
				'all') if [ ${station_type} == 'hva' ] || [ ${station_type} == 'hvb' ] ; then
					echo "${station_type} cannot be with ${conso_type}"
					echo "Temps de traitement : ${sec_trait}s"
					return 3
				fi;;
				'comp') ;;
				*) echo 'consummers type not valid'
				echo "Temps de traitement : ${sec_trait}s"
				return 2 ;;
			esac
		else
			echo 'No arguments for consummers type'
			echo "Temps de traitement : ${sec_trait}s"
			return 1
		fi
		
		
		if [ ! -z ${id_central} ] && [ ${id_central} -le 5 ] && [ ${id_central} -gt 0 ] ; then		# Check the id central
			id=1
		fi
		
		if [ ! -e "c-wire_exec" ] || [ ! -f "c-wire_exec" ] ; then	# Check the execution file
			if [ ! -e "c-wire.c" ] && [ ! -f "c-wire.c" ] ; then
				echo "Temps de traitement : ${sec_trait}s"
				return 4
			fi
			make=`make`
			make_test=$?
			
			if [ ${make_test} -ne 0 ] ; then
				echo "Temps de traitement : ${sec_trait}s"
				return 5
			fi
		fi
		
		
		if [ -e "tmp" ] && [ -d "tmp" ]; then		# Check for tmp and graph
			rm -r tmp
		fi
		mkdir tmp
		if [ ! -e graph ] || [ ! -d graph ] ; then
			mkdir graph
		fi
		
		if [ ${id} -eq 1 ] ; then
			echo "Power plant;HV-B Station;HV-A Station;LV Station;Company;Individual;Capacity;Load" | cat > "tmp/central_${id_central}_${station_type}_${conso_type}_tmp.csv"
			case ${station_type} in
				'hvb') grep -E "${id_central};[0-9]+;-;-;-;-;[0-9]+;-" $file_chm | cat >> "tmp/central_${id_central}_${station_type}_${conso_type}_tmp.csv"
					if [ ${conso_type} == 'comp' ] ; then
						grep -E "${id_central};[0-9]+;-;-;[0-9]+;-;-;[0-9]+" $file_chm | cat >> "tmp/central_${id_central}_${station_type}_${conso_type}_tmp.csv"
					else
						echo "Temps de traitement : ${sec_trait}s"
						return 3
					fi;;
				'hva') grep -E "${id_central};;-;[0-9]+;-;-;-;[0-9]+;-" $file_chm | cat >> "tmp/central_${id_central}_${station_type}_${conso_type}_tmp.csv"
					if [ ${conso_type} == 'comp' ] ; then
						grep -E "${id_central};;-;[0-9]+;-;[0-9]+;-;-;[0-9]+" $file_chm | cat >> "tmp/central_${id_central}_${station_type}_${conso_type}_tmp.csv"
					else
						echo "Temps de traitement : ${sec_trait}s"
						return 3
					fi;;
				'lv') grep -E "${id_central};;-;-;[0-9]+;-;-;[0-9]+;-" $file_chm | cat >> "tmp/central_${id_central}_${station_type}_${conso_type}_tmp.csv"
					if [ ${conso_type} == 'comp' ] || [ ${conso_type} == 'all' ] ; then
						grep -E "${id_central};;-;-;[0-9]+;[0-9]+;-;-;[0-9]+" $file_chm | cat >> "tmp/central_${id_central}_${station_type}_${conso_type}_tmp.csv"
					elif [ ${conso_type} == 'indiv' ] ; then
						grep -E "${id_central};;-;-;[0-9]+;-;[0-9]+;-;[0-9]+" $file_chm | cat >> "tmp/central_${id_central}_${station_type}_${conso_type}_tmp.csv"
					else
						echo "Temps de traitement : ${sec_trait}s"
						return 3
					fi;;
				*) 
					echo "Temps de traitement : ${sec_trait}s"
					return 2 ;;
			esac
			case ${station_type} in
				'hvb') cut -d';' -f2,7,8 tmp/central_${id_central}_${station_type}_${conso_type}_tmp.csv | cat >> "tmp/central_${id_central}_${station_type}_${conso_type}.csv" ;;
				'hva') cut -d';' -f3,7,8 tmp/central_${id_central}_${station_type}_${conso_type}_tmp.csv | cat >> "tmp/central_${id_central}_${station_type}_${conso_type}.csv" ;;
				'lv') cut -d';' -f4,7,8 tmp/central_${id_central}_${station_type}_${conso_type}_tmp.csv | cat >> "tmp/central_${id_central}_${station_type}_${conso_type}.csv" ;;
				*) 
					echo "Temps de traitement : ${sec_trait}s"
					return 2 ;;
			esac
		else
			echo "Power plant;HV-B Station;HV-A Station;LV Station;Company;Individual;Capacity;Load" | cat > "tmp/${station_type}_${conso_type}_tmp.csv"
			case ${station_type} in
				'hvb') grep -E "[0-9]+;[0-9]+;-;-;-;-;[0-9]+;-" $file_chm | cat >> "tmp/${station_type}_${conso_type}_tmp.csv" 
					if [ ${conso_type} == 'comp' ] ; then
						grep -E "[0-9]+;[0-9]+;-;-;[0-9]+;-;-;[0-9]+" $file_chm | cat >> "tmp/${station_type}_${conso_type}_tmp.csv" 
					else
						echo "Temps de traitement : ${sec_trait}s"
						return 3
					fi;;
				'hva') grep -E "[0-9]+;-;[0-9]+;-;-;-;[0-9]+;-" $file_chm | cat >> "tmp/${station_type}_${conso_type}_tmp.csv" 
					if [ ${conso_type} == 'comp' ] ; then
						grep -E "[0-9]+;-;[0-9]+;-;[0-9]+;-;-;[0-9]+" $file_chm | cat >> "tmp/${station_type}_${conso_type}_tmp.csv" 
					else
						echo "Temps de traitement : ${sec_trait}s"
						return 3
					fi;;
				'lv') grep -E "[0-9]+;-;-;[0-9]+;-;-;[0-9]+;-" $file_chm | cat >> "tmp/${station_type}_${conso_type}_tmp.csv" 
					if [ ${conso_type} == 'comp' ] || [ ${conso_type} == 'all' ] ; then
						grep -E "[0-9]+;-;-;[0-9]+;[0-9]+;-;-;[0-9]+" $file_chm | cat >> "tmp/${station_type}_${conso_type}_tmp.csv"
					elif [ ${conso_type} == 'indiv' ] ; then
						grep -E "[0-9]+;-;-;[0-9]+;-;[0-9]+;-;[0-9]+" $file_chm | cat >> "tmp/${station_type}_${conso_type}_tmp.csv"
					else
						echo "Temps de traitement : ${sec_trait}s"
						return 3
					fi;;
				*) 
					echo "Temps de traitement : ${sec_trait}s"
					return 2 ;;
			esac
			case ${station_type} in
				'hvb') cut -d';' -f2,7,8 tmp/${station_type}_${conso_type}_tmp.csv | cat >> "tmp/${station_type}_${conso_type}.csv" ;;
				'hva') cut -d';' -f3,7,8 tmp/${station_type}_${conso_type}_tmp.csv | cat >> "tmp/${station_type}_${conso_type}.csv" ;;
				'lv') cut -d';' -f4,7,8 tmp/${station_type}_${conso_type}_tmp.csv | cat >> "tmp/${station_type}_${conso_type}.csv" ;;
				*) 
					echo "Temps de traitement : ${sec_trait}s"
					return 2 ;;
			esac
		fi
			
			
			time_end=`date +%s`
			echo "Temps de traitement : `expr ${time_end} - ${time_start}` s"
			
			./c-wire_exec		# The C program
			
			if [ $station_type == 'lv' ] && [ $conso_type == 'all' ] ; then
				./autreprogramme
			fi
					
	fi
	return 0
} 

c_wire=`c_wire`
error=$?

echo -e "${c_wire}"

if [ ${error} -ne 0 ] ; then		# Error 
	case ${error} in 
		1) echo 'agrument missing';;
		2) echo 'argument not valid';;
		3) echo 'arguments do no match';;
		4) echo 'C program not found';;
		5) echo 'C program didnt compile well';;
		*) echo 'Problem unknown';; 
	esac
fi
















