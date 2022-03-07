#!/bin/bash
DEFAULT_YAML="/$HOME/.config/cod/cod.yaml"

function cod {

	# Make sure not to reuse prior CODE variable and keep ITERATION
	# for resume flag.
	CODE=""
	HIGHLIGHT=""
	PROJECT=""
	RESUME=""
	PRIOR_ITERATION=$ITERATION
	ITERATION=""
	VERBOSE=""

	source "$(dirname ${BASH_SOURCE[0]})/utility/utility.sh"

	function print_piece {
		HIGHLIGHT=$1
		NAME="$(basename ${FILE})"
		BAR="####################################"
		for i; do
			printf "\n${BAR}${BAR}\nStart of ${NAME}\n${BAR}${BAR}\n\n"
			# Use $ in grep to make sure that every line is printed.
			#TODO: If no match, print the whole file with notice thereof.
			grep -E -i -z -s --color=auto ${HIGHLIGHT} ${FILE}
			printf "\n\n${BAR}${BAR}\nEnd of ${NAME}\n${BAR}${BAR}\n\n"
		done
	}

	function filter_folder {
		# Allows you to code a subset of documents based on a flag.
		# Continue where you left off if coding iteration incomplete.
		CODE=$1
		ITERATION=$2
		shift
		shift

		to_code="$@"

		if [[ -z $ITERATION && -z $CODE ]]; then
			echo "No filter provided."
			exit 1
		fi 

		if [ ! -z $ITERATION ]; then
			to_code="$( filter_iteration $ITERATION $to_code)"
		fi

		if [ ! -z $CODE ]; then
			to_code="$( filter_coding $CODE $to_code)"
		fi

		echo "${to_code}"
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
		# echo "Removing code '${CODE}'"
		CODE=$1
		shift

		for i ; do
			sed -i -E "/\* #${CODE}$/d" $i
		done
	}

	function precode {
		YAML=$1
		PROJECT=$2
		HIGHLIGHT=$3
		ITERATION=$4
		shift
		shift
		shift
		shift
		OPTIONS=$( cat $YAML | yq ".codes.${PROJECT}" )
		TO_CODE=$( filter_iteration $ITERATION $@ )

		# For debugging
		echo "Highlight: $HIGHLIGHT"	

		for i in $TO_CODE; do
			# This needs to be a function precode_piece
			# echo $i
			print_piece $HIGHLIGHT $i 
			NEWLINE="`echo $'\n> '`"
			read -p "$OPTIONS$NEWLINE" short_code
			code=$( cat $YAML | yq ".codes.${PROJECT}.${short_code}" )
			insert_code $code $i $ITERATION
		done
	}

	# function stash_codes {
	# 	YAML=$1
	# 	PROJECT=$2
	# 	# codes is $@ and use first letter
	# 	# yq sth
	# }

	# function recode {

	# 	filter_folder $CODE
	# 	precode_piece
	# 	remove_code $CODE
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

	# Parse arguments

	POSITIONAL_ARGS=()
	while [[ $# -gt 0 ]]; do
		case $1 in 
			#TODO: There needs to be some logic to warn about the first
			# three arguments cooccurring.
			-r|-R|--resume)
			  RESUME=true
			  shift
			  ;;
			-n|--new)
			  ITERATION=$(date +"%m/%d/%Y_%H:%M")
			  shift
			  ;;
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
			-h|-H|--highlight)
			  HIGHLIGHT="$2"
			  shift
			  shift
			  ;;
			-v|-V|--verbose)
			  VERBOSE=true
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
	if [ ! -t 0 ]; then
	    piped=$(cat)
	fi
	set -- "${POSITIONAL_ARGS[@]} $piped"

	# Some sensible logic for setting arguments.

	if [[ -z $YAML ]]; then
		YAML=$DEFAULT_YAML
	fi
	if [ "$RESUME" = true ]; then
		#TODO: what about -n and -i?
		ITERATION=$PRIOR_ITERATION
	fi
	if [[ ! -z $SHORT_CODE && ! -z $PROJECT ]]; then
		#TODO: Add some error if project/code does not exist.
		CODE=$( cat $YAML | yq ".codes.${PROJECT}.${SHORT_CODE}" )
	fi

	# For debugging:
	if [ "$VERBOSE" = true ]; then
		echo "Iteration: $ITERATION"
		echo "Code: $CODE"
		echo "Short code: $SHORT_CODE"
		echo "YAML: $YAML"
		echo "Project: $PROJECT"
		echo "Highlight: $HIGHLIGHT"
		echo "Positional arguments: $@"
	fi

	case $1 in
		precode)
		  shift
		  precode "${YAML}" "${PROJECT}" "${HIGHLIGHT}" "$ITERATION" "$@"
		  ;;
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