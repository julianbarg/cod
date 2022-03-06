#!/bin/bash

function filter_folder {
	# Allows you to code a subset of documents based on a flag.
	# Continue where you left off if coding iteration incomplete.
	POSITIONAL_ARGS=()
	while [[ $# -gt 0 ]]; do
		case $1 in 
			-i|-I|--iteration)
			  ITERATION="$2"
			  shift
			  shift
			  ;;
			-c|-C|--code)
			  #TODO: Should eventually be updated to grab code from yaml
			  # based on project and one-letter code, while still
			  # allowing for the use of the full keyword. That might 
			  # require using two different flags?
			  CODE="$2"
			  shift
			  shift
			  ;;
			#TODO: This belongs in another function.
			# -n|--new)
			#   ITERATION=$(date +"%m/%d/%Y_%H:%M")
			#   shift
			#   ;;
			-*|--*)
			  echo "Unknown option $1."
			  return 1
			  ;;
			*)
			  POSITIONAL_ARGS+=("$1")
			  shift
			  ;;
		esac
	done

	set -- "${POSITIONAL_ARGS[@]}"
	to_code="${POSITIONAL_ARGS[@]}"

	if [[ -z $ITERATION && -z $CODE ]]; then
		echo "No filter provided."
		exit 1
	fi 

	if [ ! -z $ITERATION ]; then
		to_code="$( filter_timestamp $ITERATION $to_code )"
	fi

	#TODO: to_code is not implemented yet.
	# if [ ! -z $CODE ]; then
	# 	to_code=$( filter_coding $CODE $to_code )
	# fi

	echo $to_code
}

function filter_timestamp {
	ITERATION=$1
	shift

	declare -a to_code=()
	for i; do
		if [[ -d $i ]]; then
			to_code+=$( filter_timestamp $ITERATION ${i}/* )
		elif [[ $(grep -L -E "^\* @iteration.*${ITERATION}" $i) ]]; then
			to_code+=($i)
		fi
	done

	echo "${to_code[*]}"
}

# #TODO: filter by coding.
# function filter_coding {
#
# }

# #TODO: code document--show document(s) and insert codes.
# function code {
# 	FILE=$1
# 	CODES=$2
# 	ITERATION=$3
# 	# Optional
# 	CODE=$4
# }

# #TODO: replace code $CODE in document(s) with code $NEW_CODE.
# # Or if $NEW_CODE is not provided, show documents and provide new
# # codes for each and replace the old one with new one.
# # Just needs to remove string and call insert_code.
# function recode {
#
# }

# Create the section with codes for doc if it does not exist.
function mk_coding {
	FILE=$1
	if [[ $(grep -L -E "^## Codes$" $FILE) ]]; then
		echo -e "\n\n## Codes\n\n* @iteration" >> $FILE
	fi
	return
}

# Test if document already contains code and exit if exists twice.
function code_absent {
	CODE=$1
	FILE=$2

	case `grep "^\* #${CODE}$" ${FILE} >/dev/null; echo $?` in
		0)
		  return 1
		  ;;
		1)
		  return 0
		  ;;
		*)
		  echo "Error: erroneous code search."
		  ;;
	esac
}

function iteration_absent {
	ITERATION=$1
	FILE=$2
	case `grep "^\* @iteration.*${ITERATION}" ${FILE} >/dev/null; echo $?` in
		0)
		  return 1
		  ;;
		1)
		  return 0
		  ;;
		*)
		  echo "Error: erroneous iteration search."
		  ;;
	esac
}

# Utility function that handles insertion of code.
function insert_code_ {
	CODE=$1
	FILE=$2
	if code_absent ${CODE} ${FILE}; then
	 		echo "* #${CODE}" >> $FILE
	fi
}

# Utility to handle insertion of iteration timestamp.
function insert_iteration_ {
	ITERATION=$1
	FILE=$2
	if iteration_absent ${ITERATION} ${FILE}; then
	 	sed -i -E "s/^\* @iteration.*/& $ITERATION/" $FILE
	fi
}

# Insert a specific code and timestamp into the specified document(s).
function insert_code {
	POSITIONAL_ARGS=()
	while [[ $# -gt 0 ]]; do
		case $1 in 
			-i|-I|--iteration)
			  ITERATION="$2"
			  shift
			  shift
			  ;;
			-*|--*)
			  echo "Unknown option $1."
			  return 1
			  ;;
			*)
			  POSITIONAL_ARGS+=("$1")
			  shift
			  ;;
		esac
	done
	set -- "${POSITIONAL_ARGS[@]}"
	CODE=$1
	shift

	for i ; do
		# Some checks here are redundant, like checking for timestamp
		# if coding section is just inserted by mk_coding, but whatever.
		# Could eventually figure out how to use mk_coding return 
		# statement.
	 	mk_coding $i
	 	if [ ! -z $ITERATION ]; then
	 		insert_iteration_ $ITERATION $i
	 	fi
	 	insert_code_ $CODE $i
	done
	return
}

# #TODO: Open documents one by one, show, and insert code based on
# #YAML-provided list of codes. May also allow non-YAML provided codes?
# function code_folder {
# 	FOLDER=$1
# 	CODES=$2
# 	ITERATION=$3
# 	# ITERATION should eventually be cashed.
#
# 	code_document $file $CODES
# }