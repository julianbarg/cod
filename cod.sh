#!/bin/bash
DEFAULT_YAML="/$HOME/.config/cod/cod.yaml"

function cod {

	source "$(dirname ${BASH_SOURCE[0]})/utility/utility.sh"

	## Subfunctions to call

	function print_piece {
		#TODO: add optional flag to highlight additional word.
		# Append to $HIGLIGHT separated by ```|```.
		BAR="####################################"
		for i; do
			NAME="$(basename $i)"
			printf "\n${BAR}${BAR}\nStart of ${NAME}\n${BAR}${BAR}\n\n"
			# Use $ in grep to make sure that every line is printed.
			#TODO: If no match, print the whole file with notice thereof.
			grep -E -i -z -s --color=auto "${HIGHLIGHT}|$" ${i}
			printf "\n\n${BAR}${BAR}\nEnd of ${NAME}\n${BAR}${BAR}\n\n"
		done
	}

	function filter_folder {
		# Allows you to code a subset of documents based on a flag.
		# Continue where you left off if coding iteration incomplete.
		# Pipe filter_folder into precode or other function to use.
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

		if [ "$VERBOSE" = true ]; then
			echo "insert_code--code: $CODE"
			echo "insert_code--iteration: $ITERATION"
		fi

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
			# Some checks here are redundant, like checking for timestamp
			# if coding section is just inserted by mk_coding, but whatever.
			# Could eventually figure out how to use mk_coding return 
			# statement.
		 	(insert_code_ $CODE $i $ITERATION & )
		done
	}

	# Remove a specific code from documents.
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

	# Open documents one by one and enter selected code at bottom of
	# document with timestamp ($ITERATION).
	function precode {
		ITERATION=$1
		shift
		if [[ -z PROJECT ]]; then
			echo "No project selected!"
	  		exit 1
	  	fi
	  	
	  	#TODO: Need to figure out a way to accommodate other ways of
	  	# iterating, such as recoding--opening docs and replacing code.
	  	# $ITERATION needs to be optional until then to accommodate.
	  	# if [[ -z ITERATION ]];
	  	# 	echo "No iteration specified!"
	  	# 	exit 1
	  	# fi

		OPTIONS=$( cat $YAML | yq ".${PROJECT}.codes" )

		if [[ ! -z $ITERATION ]]; then
			TO_CODE=$( filter_iteration $ITERATION $@ )
		else
			TO_CODE="$@"
		fi

		for i in $TO_CODE; do

			print_piece $i
			EXIT="`echo $'\nx: exit'`"
			selection=""
			echo "${OPTIONS}${EXIT}"
			while [[ ! $selection == "x" ]]; do
				read -p ">" selection
				code="$( cat $YAML | yq ".${PROJECT}.codes.${selection}" )"
				if [[ "$selection" != "x" && "$code" != "null" ]]; then
					insert_code "${code}" "${ITERATION}" $i
				elif [[ $code=="null" ]]; then
					echo "Invalid code--choose again."
				fi
			done
			selection=""
			# To see verbose output and see that input is registered.
			sleep .1
			# Make sure the iteration is entered even if no code set?
			# insert_iteration_ $ITERATION $i
		done
	}

	# Select all pieces in one iteration that received a specific code
	# then set a new code or codes and remove the old one.
	function recode {
		ITERATION=$1
		CODE=$2
		shift
		shift
		#TODO: find a way to keep track of which documents have been 
		# recoded and which still need to.

		# This does the opposite of the filter_iteration function.
		# Select files only if they were in the iteration.
		to_code=$(grep -l -E "^\* @iteration.*${ITERATION}" "$@")
		to_code=$(filter_coding "$CODE" "$to_code")

		for i in $to_code; do
			# $ITERATION is empty because we are only altering prior
			# iteration
			# There should be a better solution for this, but for now we 
			# remove the old code before setting the new one in case it 
			# may be the same. Eventually, we should check if new codes
			# are set before removing old ones.
			remove_code "${CODE}" "$i"
			( precode "" "$i" )
		done
	}

	## Parsing arguments and calling function.

	# Make sure not to reuse prior CODE variable and keep ITERATION
	# for resume flag.
	CODE=""
	HIGHLIGHT=""
	RESUME=""
	# We store $PRIOR_ITERATION to allow for use of --resume flag.
	PRIOR_PROJECT=$PROJECT
	PROJECT=""
	PRIOR_ITERATION=$ITERATION
	ITERATION=""
	VERBOSE=""
	SHORT_CODE=""

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
	if [[ ! -z $PROJECT && HIGHLIGHT="" ]]; then
		HIGHLIGHT=$( cat $YAML | yq ".${PROJECT}.highlights" | \
			yq 'join("|")')
	fi 

	# For debugging:
	if [ "$VERBOSE" = true ]; then
		echo "Iteration: $ITERATION"
		echo "Code: $CODE"
		echo "Short code: $SHORT_CODE"
		echo "YAML: $YAML"
		echo "Project: $PROJECT"
		echo "Highlight: $HIGHLIGHT"
		more=$(($# - 3))
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
		  recode "$ITERATION" "$CODE" "$@"
		  ;;
		precode)
		  shift
		  precode "$ITERATION" "$@"
		  ;;
		print_piece)
		  shift
		  print_piece "$@"
		  ;;
		remove_code)
		  shift
		  remove_code "${CODE}" "$@"
		  ;;
		*)
		  echo "Not a valid command."
		  exit 1
		  ;;
	esac
}