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

# #TODO: code document--show document and insert codes.
# function code_document {
# 	FILE=$1
# 	CODES=$2
# 	ITERATION=$3
# 	# Optional
# 	CODE=$4
# }

# #TODO: replace code $CODE in document(s) with code $NEW_CODE.
# # Or if $NEW_CODE is not provided, show documents and provide new
# # codes for each and replace the old one with new one.
# function recode {
#
# }

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