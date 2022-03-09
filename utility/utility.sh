# Create the section with codes for doc if it does not exist.
function mk_coding {
	FILE=$1
	if [[ $(grep -L -E "^## Codes$" $FILE) ]]; then
		echo -e "\n\n## Codes\n\n* @iteration" >> $FILE
	fi
	return
}

function filter_iteration {
	ITERATION=$1
	shift
	echo $(grep -L -E "^\* @iteration.*${ITERATION}" $@)
}

function filter_coding {
	CODE=$1
	shift
	echo $(grep -l -E "^\* #${CODE}$" $@)
}

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

# Utility to handle insertion of iteration timestamp.
function insert_iteration_ {
	ITERATION=$1
	FILE=$2
	if iteration_absent ${ITERATION} ${FILE}; then
	 	sed -i -E "s/^\* @iteration.*/& $ITERATION/" $FILE
	fi
}

function print_full {
	PIECE=$1
	NAME="$(basename ${PIECE})"
	printf "\n${BAR}${BAR}\nStart of ${NAME}\n${BAR}${BAR}\n\n"
	# Use $ in grep to make sure that every line is printed.
	#TODO: If no match, print the whole file with notice thereof.
	# This would support longer phrases for search.
	grep -E -i -z -s --color=auto "${HIGHLIGHT}|$" ${PIECE}
	printf "\n\n${BAR}${BAR}\nEnd of ${NAME}\n${BAR}${BAR}\n\n"
}

function choice_preview {
	PIECE=$1
	NAME="$(basename ${PIECE})"
	local choice
	
	if [ "${VERBOSE}" = true ]; then
		echo "Piece: $PIECE"
		echo "Highlight: $HIGHLIGHT"
		echo "Show full: $FULL"
		echo "Match: \S*.{500}(${HIGHLIGHT}).{500}\S*"
	fi

	printf "\n${BAR}${BAR}\nPreview of ${NAME}${NEWLINE}\n\n"
	# This means that "(\s)?" for space no longer works since there could
	# be a line break. For now, use singe-word phrases only.
	#TODO: here is how to make it work--remove newlines and print phrase and
	# limited number of words. I.e.: "\s\S*\s\S[\s]?*${PHRASE}[\s]?\S*\s etc.
	grep -E -i -z -o --color=never "\S*.{500}(${HIGHLIGHT}).{500}\S*" "${PIECE}" \
		| grep -E -i -z --color=always "${HIGHLIGHT}"
	# grep -E -i -s -C 5 -m 2 --color=auto "${HIGHLIGHT}" ${PIECE}
	printf "${BAR}${BAR}\n"

	read -p "Show full? (y/n) `echo $'\n> '`" choice
	if [[ "$choice" == "y" ]]; then
		sleep .2
		print_full $PIECE
	fi
}