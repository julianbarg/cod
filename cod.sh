#!/bin/bash

function cod {

	# Source function
	PROJECT_HOME="$(dirname ${BASH_SOURCE[0]})"
	source "${PROJECT_HOME}/functions/utility.sh"
	source "${PROJECT_HOME}/functions/filter_folder.sh"
	source "${PROJECT_HOME}/functions/insert_code.sh"
	source "${PROJECT_HOME}/functions/precode.sh"
	source "${PROJECT_HOME}/functions/print_piece.sh"
	source "${PROJECT_HOME}/functions/recode.sh"
	source "${PROJECT_HOME}/functions/remove_code.sh"
	source "${PROJECT_HOME}/functions/take_data.sh"

	## Parsing arguments and calling function.

	local DEFAULT_YAML="/$HOME/.config/cod/cod.yaml"
	local BAR="####################################"
	local CODE
	local HIGHLIGHT
	local RESUME
	local VERBOSE
	local SHORT_CODE
	local FULL
	local OUTPUT
	# We store $PRIOR_ITERATION to allow for use of --resume flag.
	PRIOR_PROJECT=$PROJECT
	PROJECT=""
	PRIOR_ITERATION=$ITERATION
	ITERATION=""

	# Parse arguments

	POSITIONAL_ARGS=()
	while [[ $# -gt 0 ]]; do
		case $1 in 
			#TODO: There needs to be some logic to warn about the first
			# three arguments cooccurring.
			-c|-C|--code)
			  CODE="$2"
			  shift
			  shift
			  ;;
			-f|-F|--full)
			  FULL=true
			  shift
			  ;;
			-h|-H|--highlight)
			  HIGHLIGHT="$2"
			  shift
			  shift
			  ;;
			-i|-I|--iteration)
			  ITERATION="$2"
			  shift
			  shift
			  ;;
			-n|--new)
			  ITERATION=$(date +"%m/%d/%Y_%H:%M")
			  shift
			  ;;
			-o|-O|--output)
			  OUTPUT="$2"
			  shift
			  shift
			  ;;
			-p|-P|--project)
			  PROJECT="$2"
			  shift
			  shift
			  ;;
			-r|-R|--resume)
			  RESUME=true
			  shift
			  ;;
			-s|-S|--short_code)
			  SHORT_CODE="$2"
			  shift
			  shift
			  ;;
			-v|-V|--verbose)
			  VERBOSE=true
			  shift
			  ;;
			-y|-Y|--yaml)
			  YAML="$2"
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
	if [ ! -t 0 ]; then
	    POSITIONAL_ARGS+=($(cat))
	fi
	set -- "${POSITIONAL_ARGS[@]}"

	# Some sensible logic for setting arguments.

	#TODO: needs some validation of YAML. Does yamllint check whether 
	# dictionary in yaml file contains duplicate?

	if [[ -z $YAML ]]; then
		YAML=$DEFAULT_YAML
	fi
	if [ "$RESUME" = true ]; then
		#TODO: what about -n and -i?
		ITERATION=$PRIOR_ITERATION
		PROJECT=$PRIOR_PROJECT
	fi
	if [[ ! -z $SHORT_CODE && ! -z $PROJECT ]]; then
		#TODO: Add some error if project/code does not exist.
		CODE=$( cat $YAML | yq ".${PROJECT}.codes.${SHORT_CODE}" )
	fi
	if [[ ! -z $PROJECT && -z $HIGHLIGHT ]]; then
		PROJECT_YAML="$(cat $YAML | yq ".${PROJECT}")"
		if [[ "${PROJECT_YAML}"=="*highlights*" ]]; then
			HIGHLIGHT=$( cat $YAML | yq ".${PROJECT}.highlights" | \
				yq 'join("|")')
			true
		fi
	fi 

	# For debugging:
	if [ "$VERBOSE" = true ]; then
		echo "Iteration: $ITERATION"
		echo "Code: $CODE"
		echo "Short code: $SHORT_CODE"
		echo "YAML: $YAML"
		echo "Project: $PROJECT"
		echo "Highlight: $HIGHLIGHT"
		#TODO: this may yield negative result.
		more=$(($# - 3))
		echo "Full: $FULL"
		echo "Output: $OUTPUT"
		echo "Positional arguments: $1, $2, $3 and $more more."
	fi

	# Call subfunctions

	case $1 in
		insert_code)
		  shift
		  insert_code "${CODE}" "${ITERATION}" "$@"
		  ;;
		filter_folder)
		  shift
		  filter_folder "${CODE}" "${ITERATION}" "$@"
		  ;;
		recode)
		  shift
		  recode "${ITERATION}" "${CODE}" "$@"
		  ;;
		precode)
		  shift
		  precode "${ITERATION}" "$@"
		  ;;
		print_piece)
		  shift
		  print_piece "$@"
		  ;;
		remove_code)
		  shift
		  remove_code "${CODE}" "$@"
		  ;;
		take_data)
		  shift
		  take_data "${ITERATION}" "$@"
		  ;;
		*)
		  echo "Not a valid command."
		  exit 1
		  ;;
	esac
}