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
	# echo "Code: $CODE"
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

function print_piece {
	FILE=$1
	NAME="$(basename ${FILE})"
	BAR="####################################"

	printf "\n${BAR}${BAR}\nStart of ${NAME}\n${BAR}${BAR}\n\n"
	# Use $ in grep to make sure that every line is printed.
	grep -E -i -z -s --color=auto "KXL|Keystone(\s)?XL|$" "${FILE}"
	printf "\n\n${BAR}${BAR}\nEnd of ${NAME}\n${BAR}${BAR}\n\n"
}
