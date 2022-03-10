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
	PADDING="$(printf ' %.0s' {1..450})"
	local choice
	
	if [ "${VERBOSE}" = true ]; then
		echo "Piece: $PIECE"
		echo "Highlight: $HIGHLIGHT"
		echo "Show full: $FULL"
	fi

	# PREVIEW="\S*.{500}(${HIGHLIGHT}).{500}\S*"
	# Much better performance!
	PREVIEW=".{450}(${HIGHLIGHT}).{450}"

	printf "\n${BAR}${BAR}\n## Preview of ${NAME}:\n"
	head "${PIECE}" -n 1
	printf "${BAR}${BAR}\n\n"

	# Add padding
	sed -i "1s/^/${PADDING}\n/" "${PIECE}"
	echo "${PADDING}" >> "${PIECE}"
	
	grep -E -i -m 1 -z -o --color=never "${PREVIEW}" "${PIECE}" \
		| grep -E -m 1 -i -z --color=always "${HIGHLIGHT}" \
		| sed -e 's/^[ \t]*//' -e 's/[ \t]*$//'

	# Remove padding
	sed -i '1d;$d' "${PIECE}"
	printf "\n\nEnd of ${NAME} preview\n${BAR}${BAR}\n"

	read -p "Show full? (y/n) Or open in sublime. (s) `echo $'\n> '`" choice
	if [[ "$choice" == "y" ]]; then
		sleep .2
		print_full $PIECE
	elif [[ "${choice}" == "s" ]]; then
		#TODO: Need to create this sublime project file if it does not exist.
		subl $PIECE --project ~/.config/cod/cod.sublime-project
	fi
}