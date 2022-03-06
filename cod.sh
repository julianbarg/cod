#!/bin/bash
DEFAULT_YAML="/$HOME/.config/cod/cod.yaml"

function cod {
	
	# Make sure not to reuse prior CODE variable.
	CODE=""
	
	source "$(dirname ${BASH_SOURCE[0]})/utility/utility.sh"

	function filter_folder {
		# Allows you to code a subset of documents based on a flag.
		# Continue where you left off if coding iteration incomplete.
		CODE=$1
		ITERATION=$2
		shift
		shift

		to_code="$@"
		echo 

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

	# Insert a specific code and timestamp into the specified document(s).
	function insert_code {
		CODE=$1
		ITERATION=$2
		shift
		shift

		# Utility function that handles insertion of code.
		function insert_code_ {
			CODE=$1
			FILE=$2
			ITERATION=$3
			mk_coding $FILE
		 	if [ ! -z $ITERATION ]; then
		 		insert_iteration_ $ITERATION $FILE
		 	fi
			if code_absent ${CODE} ${FILE}; then
			 		echo "* #${CODE}" >> $FILE
			fi
		}

		for i ; do
			echo $i
			# Some checks here are redundant, like checking for timestamp
			# if coding section is just inserted by mk_coding, but whatever.
			# Could eventually figure out how to use mk_coding return 
			# statement.
		 	(insert_code_ $CODE $i $ITERATION & )
		done
	}

	function remove_code {
		# This would not work if the code exists more than once for some
		# reason, but I think I can handle that later.
		echo "Removing code '${CODE}'"
		CODE=$1
		shift

		for i ; do
			sed -i -E "/\* #${CODE}$/d" $i
		done
	}

	# function code {
	# }

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

	# # Create the section with codes for doc if it does not exist.
	# function mk_coding {
	# 	FILE=$1
	# 	if [[ $(grep -L -E "^## Codes$" $FILE) ]]; then
	# 		echo -e "\n\n## Codes\n\n* @iteration" >> $FILE
	# 	fi
	# 	return
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

	POSITIONAL_ARGS=()
	while [[ $# -gt 0 ]]; do
		case $1 in 
			-i|-I|--iteration)
			  ITERATION="$2"
			  shift
			  shift
			  ;;
			-c|-C|--code)
			  CODE="$2"
			  shift
			  shift
			  ;;
			-s|-S|--short_code)
			  SHORT_CODE="$2"
			  shift
			  shift
			  ;;
			-y|-Y|--yaml)
			  YAML="$2"
			  shift
			  shift
			  ;;
			-p|-P|--project)
			  PROJECT="$2"
			  shift
			  shift
			  ;;
			-n|--new)
			  ITERATION=$(date +"%m/%d/%Y_%H:%M")
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

	if [[ -z $YAML ]]; then
		YAML=$DEFAULT_YAML
	fi
	if [[ ! -z $SHORT_CODE && ! -z $PROJECT ]]; then
		#TODO: Add some error if project/code does not exist.
		CODE=$( cat $YAML | yq ".codes.${PROJECT}.${SHORT_CODE}" )
	fi

	# For debugging:
	echo "Iteration: $ITERATION"
	echo "Code: $CODE"
	echo "Short code: $SHORT_CODE"
	echo "YAML: $YAML"
	echo "Project: $PROJECT"
	echo "Positional arguments: $@"

	case $1 in
		remove_code)
		  shift
		  remove_code "${CODE}" "$@"
		  ;;
		filter_folder)
		  shift
		  filter_folder "${CODE}" "${ITERATION}" "$@"
		  ;;
		insert_code)
		  shift
		  insert_code "${CODE}" "${ITERATION}" "$@"
		  ;;
		remove_code)
		  shift
		  remove_code "${CODE}" "$@"
		  ;;
	esac
}