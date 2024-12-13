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

	if [ ${help} -eq 1 ]  ; then		# Print the help option (if there is -h)
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
		
		return 0
	fi
	

	if [ ! -z ${file_chm} ] && [ -e ${file_chm} ] ; then		# Check if the file is here and indeed a file
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
	
	cp -l ${file_chm} input/${file_chm##*/}
	file_chm=input/${file_chm##*/}


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
	
	
	
	if [ ! -z ${conso_type} ] ; then		# Check the type of consummers and if they match with the type of station
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
	
	
	if [ ! -e "codeC/c-wire_exec" ] || [ ! -f "codeC/c-wire_exec" ] ; then	# Check if the execution file exists
		if [ ! -e "codeC/c-wire.c" ] && [ ! -f "codeC/c-wire.c" ] ; then
			echo "Temps de traitement : ${sec_trait}s"
			return 4
		fi
		make=`gcc -o codeC/c-wire_exec codeC/c-wire.c`
		make_test=$?
		
		if [ ${make_test} -ne 0 ] ; then			# Compile the C program and see any errors
			echo "Temps de traitement : ${sec_trait}s"
			return ${make_test}
		fi
	fi
	
	
	
	if [ -e "tmp" ] && [ -d "tmp" ]; then		# Check for tmp and graph directory and empty tmp (erase it and recreate it)
		rm -r tmp
	fi
	mkdir tmp
	if [ ! -e graph ] || [ ! -d graph ] ; then
		mkdir graph
	fi
	
	# Sorting with grep
	if [ ${id} -eq 1 ] ; then		# It checks the id of the central too
		case ${station_type} in
			'hvb') grep -E "${id_central};[0-9]+;-;-;-;-;[0-9]+;-" ${file_chm} | tr "-" "0" | cat >> "tmp/c-wire_data_tmp.csv"
				if [ ${conso_type} == 'comp' ] ; then
					grep -E "${id_central};[0-9]+;-;-;[0-9]+;-;-;[0-9]+" ${file_chm} | tr "-" "0" | cat >> "tmp/c-wire_data_tmp.csv"
				else
					echo "Temps de traitement : ${sec_trait}s"
					return 3
				fi;;
			'hva') grep -E "${id_central};;-;[0-9]+;-;-;-;[0-9]+;-" ${file_chm} | tr "-" "0" | cat >> "tmp/c-wire_data_tmp.csv"
				if [ ${conso_type} == 'comp' ] ; then
					grep -E "${id_central};;-;[0-9]+;-;[0-9]+;-;-;[0-9]+" ${file_chm} | tr "-" "0" | cat >> "tmp/c-wire_data_tmp.csv"
				else
					echo "Temps de traitement : ${sec_trait}s"
					return 3
				fi;;
			'lv') grep -E "${id_central};;-;-;[0-9]+;-;-;[0-9]+;-" ${file_chm} | tr "-" "0" | cat >> "tmp/c-wire_data_tmp.csv"
				if [ ${conso_type} == 'comp' ] || [ ${conso_type} == 'all' ] ; then
					grep -E "${id_central};;-;-;[0-9]+;[0-9]+;-;-;[0-9]+" ${file_chm} | tr "-" "0" | cat >> "tmp/c-wire_data_tmp.csv"
				elif [ ${conso_type} == 'indiv' ] ; then
					grep -E "${id_central};;-;-;[0-9]+;-;[0-9]+;-;[0-9]+" ${file_chm} | tr "-" "0" | cat >> "tmp/c-wire_data_tmp.csv"
				else
					echo "Temps de traitement : ${sec_trait}s"
					return 3
				fi;;
			*) 
				echo "Temps de traitement : ${sec_trait}s"
				return 2 ;;
		esac
		case ${station_type} in		# Only put the number of station, the capacity and the consommation
			'hvb') cut -d';' -f2,7,8 tmp/c-wire_data_tmp.csv | cat >> "tmp/c-wire_data.csv" ;;
			'hva') cut -d';' -f3,7,8 tmp/c-wire_data_tmp.csv | cat >> "tmp/c-wire_data.csv" ;;
			'lv') cut -d';' -f4,7,8 tmp/c-wire_data_tmp.csv | cat >> "tmp/c-wire_data.csv" ;;
			*) 
				echo "Temps de traitement : ${sec_trait}s"
				return 2 ;;
		esac
	else	# No id of station needed
		case ${station_type} in
			'hvb') grep -E "[0-9]+;[0-9]+;-;-;-;-;[0-9]+;-" ${file_chm} | tr "-" "0" | cat >> "tmp/c-wire_data_tmp.csv" 
				if [ ${conso_type} == 'comp' ] ; then
					grep -E "[0-9]+;[0-9]+;-;-;[0-9]+;-;-;[0-9]+" ${file_chm} | tr "-" "0" | cat >> "tmp/c-wire_data_tmp.csv" 
				else
					echo "Temps de traitement : ${sec_trait}s"
					return 3
				fi;;
			'hva') grep -E "[0-9]+;-;[0-9]+;-;-;-;[0-9]+;-" ${file_chm} |tr "-" "0" |  cat >> "tmp/c-wire_data_tmp.csv" 
				if [ ${conso_type} == 'comp' ] ; then
					grep -E "[0-9]+;-;[0-9]+;-;[0-9]+;-;-;[0-9]+" ${file_chm} | tr "-" "0" | cat >> "tmp/c-wire_data_tmp.csv" 
				else
					echo "Temps de traitement : ${sec_trait}s"
					return 3
				fi;;
			'lv') grep -E "[0-9]+;-;-;[0-9]+;-;-;[0-9]+;-" ${file_chm} | tr "-" "0" | cat >> "tmp/c-wire_data_tmp.csv" 
				if [ ${conso_type} == 'comp' ] || [ ${conso_type} == 'all' ] ; then
					grep -E "[0-9]+;-;-;[0-9]+;[0-9]+;-;-;[0-9]+" ${file_chm} | tr "-" "0" | cat >> "tmp/c-wire_data_tmp.csv"
				elif [ ${conso_type} == 'indiv' ] ; then
					grep -E "[0-9]+;-;-;[0-9]+;-;[0-9]+;-;[0-9]+" ${file_chm} | tr "-" "0" | cat >> "tmp/c-wire_data_tmp.csv"
				else
					echo "Temps de traitement : ${sec_trait}s"
					return 3
				fi;;
			*) 
				echo "Temps de traitement : ${sec_trait}s"
				return 2 ;;
		esac
		case ${station_type} in		# Only put the number of station, the capacity and the consommation
			'hvb') cut -d';' -f2,7,8 tmp/c-wire_data_tmp.csv | cat >> "tmp/c-wire_data.csv" ;;
			'hva') cut -d';' -f3,7,8 tmp/c-wire_data_tmp.csv | cat >> "tmp/c-wire_data.csv" ;;
			'lv') cut -d';' -f4,7,8 tmp/c-wire_data_tmp.csv | cat >> "tmp/c-wire_data.csv" ;;
			*) 
				echo "Temps de traitement : ${sec_trait}s"
				return 2 ;;
		esac
	fi
		
		
	time_end=`date +%s`		# Prints out the number of seconds the program took
	echo "Temps de traitement : `expr ${time_end} - ${time_start}` s"
	
	exec=`./codeC/c-wire_exec`
	exec_error=$?		# Execute the C program
	
	echo ${exec}		# ERASE IT BEFORE THE ENDFIONDGAOFNDQKF
	
	if [ ${exec_error} -ne 0 ] ; then
		echo ${exec_error}
		return ${exec_error}
	fi

	
	#echo "${station_type} Station;Capacity;Load (${conso_type})" | cat > "test/${station_type}_${conso_type}.csv"
	#cat "tmp/c-wire_data.csv" >> "test/${station_type}_${conso_type}.csv"


	if [ ${station_type} == 'lv' ] && [ ${conso_type} == 'all' ] ; then		# Execute an other program to take all the min and max
		exec=`./lv_all_min_max`
		exec_error=$?
	
		if [ ${exec_error} -ne 0 ] ; then
			return ${exec_error}
		fi
	fi
	
	# Creation of graphics
	#gnuplot <<-EOFmarker
	#set title "${station_type} ${conso_type}"
	#set ylabel "Energy (kWh)"
	#set xlabel "Station ${station_type}"
	
	#set datafile separator ";"
	#set terminal pngcairo enhanced
	#set output "graph/${station_type}_${conso_type}_graph.png"
	#plot "tmp/${station_type}_${conso_type}.csv" using 1:2 with impulses
	#EOFmarker
	
	return 0
}

	

c_wire=`c_wire`
error=$?

echo -e "${c_wire}"

if [ ${error} -ne 0 ] ; then		# Different error types
	case ${error} in 
		1) echo 'agrument missing';;
		2) echo 'argument not valid';;
		3) echo 'arguments do no match';;
		4) echo 'C program not found';;
		5) echo 'C program didnt compile well';;
		*) echo 'Problem unknown';; 
	esac
fi