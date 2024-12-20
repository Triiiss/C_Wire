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

	
	
	if [ -e "tmp" ] && [ -d "tmp" ]; then		# Check and create differents directories
		rm -r tmp
	fi
	mkdir tmp
	if [ ! -e graph ] || [ ! -d graph ] ; then
		mkdir graph
	fi
	if [ ! -e input ] || [ ! -d input ] ; then
		mkdir input
	fi
	if [ ! -e test ] || [ ! -d test ] ; then
		mkdir test
	fi
	if [ ! -e "codeC" ] || [ ! -d "codeC" ] ; then
		echo "No directory codeC"
		return 4
	fi



	if [ ! -e "codeC/c-wire_exec" ] || [ ! -f "codeC/c-wire_exec" ] ; then	# Check if the execution file exists
		if [ ! -e "codeC/c-wire.c" ] && [ ! -f "codeC/c-wire.c" ] ; then
			return 4
		fi
		make=`make -C codeC/`
		make_test=$?
		
		if [ ${make_test} -ne 0 ] ; then			# Compile the C program and see any errors
			return ${make_test}
		fi
	fi



	time_start=`date +%s`	# Start the timer

	if [ ! -z ${file_chm} ] && [ -e ${file_chm} ] ; then		# Check if the file is here and indeed a file
		if [ ! -f ${file_chm} ] ; then
			echo "not file"
			return 2
		elif [ ${file_chm##*.} != 'dat' ] && [ ${file_chm##*.} != 'csv' ] ; then
			echo "file format not accepted"
			return 2
		fi
	else
		echo ${file_chm}
		echo "missing file"
		return 1
	fi
	


	if [ ! -z ${station_type} ] ; then		# Check the type of station
		if [ ${station_type} != 'hvb' ] && [ ${station_type} != 'hva' ] && [ ${station_type} != 'lv' ] ; then
			echo 'station type incorrect'
			return 2
		fi
	else
		echo 'No arguments for station type'
		return 1
	fi
	
	
	
	if [ ! -z ${conso_type} ] ; then		# Check the type of consummers and if they match with the type of station
		case ${conso_type} in
			'indiv') if [ ${station_type} == 'hva' ] || [ ${station_type} == 'hvb' ] ; then
				echo "${station_type} cannot be with ${conso_type}"
				return 3
			fi;;
			'all') if [ ${station_type} == 'hva' ] || [ ${station_type} == 'hvb' ] ; then
				echo "${station_type} cannot be with ${conso_type}"
				return 3
			fi;;
			'comp') ;;
			*) echo 'consummers type not valid'
			return 2 ;;
		esac
	else
		echo 'No arguments for consummers type'
		return 1
	fi
	
	if [ ! -z ${id_central} ] && [ ${id_central} -le 5 ] && [ ${id_central} -gt 0 ] ; then		# Check the id central
		id=1
	fi

	
	cp -l ${file_chm} input/${file_chm##*/}		# Copy the file
	file_chm=input/${file_chm##*/}
	

	
	
	# Sorting with grep
	if [ ${id} -eq 1 ] ; then		# It checks the id of the central too
		case ${station_type} in
			'hvb') grep -E "${id_central};[0-9]+;-;-;-;-;[0-9]+;-" ${file_chm} | cut -d';' -f2,7,8 | tr "-" "0" | cat > "tmp/c-wire_data.csv"
				if [ ${conso_type} == 'comp' ] ; then
					grep -E "${id_central};[0-9]+;-;-;[0-9]+;-;-;[0-9]+" ${file_chm} | cut -d';' -f2,7,8 | tr "-" "0" | cat >> "tmp/c-wire_data.csv"
				else
					echo "Temps de traitement : ${sec_trait}s"
					return 3
				fi;;
			'hva') grep -E "${id_central};[0-9]+;[0-9]+;-;-;-;[0-9]+;-" ${file_chm} | cut -d';' -f3,7,8 | tr "-" "0" | cat > "tmp/c-wire_data.csv"
				if [ ${conso_type} == 'comp' ] ; then
					grep -E "${id_central};-;[0-9]+;-;[0-9]+;-;-;[0-9]+" ${file_chm} | cut -d';' -f3,7,8 | tr "-" "0" | cat >> "tmp/c-wire_data.csv"
				else
					echo "Temps de traitement : ${sec_trait}s"
					return 3
				fi;;
			'lv') grep -E "${id_central};-;[0-9]+;[0-9]+;-;-;[0-9]+;-" ${file_chm} | cut -d';' -f4,7,8 | tr "-" "0" | cat > "tmp/c-wire_data.csv" 
				if [ ${conso_type} == 'comp' ] || [ ${conso_type} == 'all' ] ; then
					grep -E "${id_central};-;-;[0-9]+;[0-9]+;-;-;[0-9]+" ${file_chm} | cut -d';' -f4,7,8 | tr "-" "0" | cat >> "tmp/c-wire_data.csv"
				fi
				if [ ${conso_type} == 'indiv' ] || [ ${conso_type} == 'all' ] ; then
					grep -E "${id_central};-;-;[0-9]+;-;[0-9]+;-;[0-9]+" ${file_chm} | cut -d';' -f4,7,8 | tr "-" "0" | cat >> "tmp/c-wire_data.csv"
				fi
				if [ ${conso_type} != 'indiv' ] && [ ${conso_type} != 'all' ] && [ ${conso_type} != 'comp' ] ; then
					return 3
				fi
				;;
			*) 
				echo "Temps de traitement : ${sec_trait}s"
				return 2 ;;
		esac
	else	# No id of station needed
		case ${station_type} in
			'hvb') grep -E "[0-9]+;[0-9]+;-;-;-;-;[0-9]+;-" ${file_chm} | cut -d';' -f2,7,8 | tr "-" "0" | cat > "tmp/c-wire_data.csv"
				if [ ${conso_type} == 'comp' ] ; then
					grep -E "[0-9]+;[0-9]+;-;-;[0-9]+;-;-;[0-9]+" ${file_chm} | cut -d';' -f2,7,8 | tr "-" "0" | cat >> "tmp/c-wire_data.csv"
				else
					echo "Temps de traitement : ${sec_trait}s"
					return 3
				fi;;
			'hva') grep -E "[0-9]+;[0-9]+;[0-9]+;-;-;-;[0-9]+;-" ${file_chm} | cut -d';' -f3,7,8 | tr "-" "0" | cat > "tmp/c-wire_data.csv"
				if [ ${conso_type} == 'comp' ] ; then
					grep -E "[0-9]+;-;[0-9]+;-;[0-9]+;-;-;[0-9]+" ${file_chm} | cut -d';' -f3,7,8 | tr "-" "0" | cat >> "tmp/c-wire_data.csv"
				else
					echo "Temps de traitement : ${sec_trait}s"
					return 3
				fi;;
			'lv') grep -E "[0-9]+;-;[0-9]+;[0-9]+;-;-;[0-9]+;-" ${file_chm} | cut -d';' -f4,7,8 | tr "-" "0" | cat > "tmp/c-wire_data.csv" 
				if [ ${conso_type} == 'comp' ] || [ ${conso_type} == 'all' ] ; then
					grep -E "[0-9]+;-;-;[0-9]+;[0-9]+;-;-;[0-9]+" ${file_chm} | cut -d';' -f4,7,8 | tr "-" "0" | cat >> "tmp/c-wire_data.csv"
				fi
				if [ ${conso_type} == 'indiv' ] || [ ${conso_type} == 'all' ] ; then
					grep -E "[0-9]+;-;-;[0-9]+;-;[0-9]+;-;[0-9]+" ${file_chm} | cut -d';' -f4,7,8 | tr "-" "0" | cat >> "tmp/c-wire_data.csv"
				fi
				if [ ${conso_type} != 'indiv' ] && [ ${conso_type} != 'all' ] && [ ${conso_type} != 'comp' ] ; then
					return 3
				fi
				;;
			*) 
				echo "Temps de traitement : ${sec_trait}s"
				return 2 ;;
		esac
	fi
	

	

	exec=`./codeC/c-wire_exec`
	exec_error=$?
	make=`make clean -C codeC/`
	
	if [ ${exec_error} -ne 0 ] ; then
		echo ${exec_error}
		return ${exec_error}
	fi



	if [ ${id} -eq 1 ] ; then
		echo "${station_type} Station;Capacity;Load (${conso_type}) central ${id_central}" | cat > "test/central_${id_central}_${station_type}_${conso_type}.csv"
		cat "tmp/output.csv" >> "test/central_${id_central}_${station_type}_${conso_type}.csv"
	else
		echo "${station_type} Station;Capacity;Load (${conso_type})" | cat > "test/${station_type}_${conso_type}.csv"
		cat "tmp/output.csv" >> "test/${station_type}_${conso_type}.csv"
	fi

	if [ ${station_type} == 'lv' ] && [ ${conso_type} == 'all' ] ; then		# Execute an other program to take all the min and max
		echo "Min and Max 'capacity-load' extreme nodes" | cat > "test/lv_all_min_max.csv"
		echo "LV station:Capacity:Load (all)" | cat >> "test/lv_all_min_max.csv"

		if [ `wc -l tmp/output.csv | cut -d" " -f1` -lt 20 ] ; then
			if [ `wc -l tmp/output.csv | cut -d" " -f1` -lt 10 ] ; then
				sort -r -t':' -k3 tmp/output.csv | head -n2 >> "test/lv_all_min_max.csv"
				sort -t':' -k3 tmp/output.csv | head -n2 >> "test/lv_all_min_max.csv"
			else
				sort -r -t':' -k3 tmp/output.csv | head -n5 >> "test/lv_all_min_max.csv"
				sort -t':' -k3 tmp/output.csv | head -n5 >> "test/lv_all_min_max.csv"
			fi
		else
			sort -r -t':' -k3 tmp/output.csv | head -n10 >> "test/lv_all_min_max.csv"
			sort -t':' -k3 tmp/output.csv | head -n10 >> "test/lv_all_min_max.csv"
		fi
	fi

	         
        
	#Creation of graphics
	if [ ${id} -eq 1 ] ; then
		file_result="central_${id_central}_${station_type}_${conso_type}"
	else
		file_result="${station_type}_${conso_type}"
	fi

	max_id=`wc -l test/${file_result}.csv | cut -d" " -f1`
	gnuplot <<-EOFmarker 
	set title "${station_type} ${conso_type}"
	set ylabel "Energy (kWh)"
	set xlabel "Station ${station_type}"

	set xrange [0:${max_id}]
	
	set datafile separator ":"
	set terminal pngcairo enhanced
	set output "graph/${file_result}_graph.png"
	plot "test/${file_result}.csv" using 1:2 with impulses title "capacity", "test/${file_result}.csv" using 1:3 with impulses title "consommation"
	EOFmarker

	if [ ${station_type} == 'lv' ] && [ ${conso_type} == 'all' ] ; then
		max_id=`wc -l test/lv_all_min_max.csv | cut -d" " -f1`
		tail +3 test/lv_all_min_max.csv >> tmp/min_max.csv
		gnuplot <<-EOFmarker 
		set title "lv all min max"
		set ylabel "Energy (kWh)"
		set xlabel "Station lv"

		set xrange [0:${max_id}]
		
		set datafile separator ":"
		set terminal pngcairo enhanced
		set output "graph/lv_all_min_max_graph.png"
		plot "tmp/min_max.csv" using 0:2 with impulses title "capacity", "tmp/min_max.csv" using 0:3 with impulses title "consommation"
		EOFmarker
	fi


	time_end=`date +%s`	# Stop the timer 

	echo "Processing time : `expr ${time_end} - ${time_start}` s"
	
	if [ ${station_type} == 'lv' ] && [ ${conso_type} == 'all' ] ; then
		echo "(checking arguments, copy the file, sorting with grep, the C program, making the result file, the min max and the graphs)"
	else 
		echo "(checking arguments, copy the file, sorting with grep, the C program, making the result file and the graph)"
	fi

	
	return 0
}
	

c_wire=`c_wire`
error=$?

echo -e "${c_wire}"
if [ ${error} -eq 1 ] || [ ${error} -eq 2 ] || [ ${error} -eq 3 ] ; then
	echo "Arguments verification : processing time : 0 s"
fi

if [ ${error} -ne 0 ] ; then		# Different error types
	case ${error} in 
		1) echo 'agrument missing';;
		2) echo 'argument not valid';;
		3) echo 'arguments do no match';;
		4) echo 'C program not found';;
		50) echo 'C program didnt execute well : min/max failed';;
		51) echo 'C program didnt execute well : malloc failed';;
		52) echo 'C program didnt execute well : fopen failed/opening file failed';;
		53) echo 'C program didnt execute well : fscanf failed';;
		*) echo 'Problem unknown';; 
	esac
	echo "code error ${error}"
fi