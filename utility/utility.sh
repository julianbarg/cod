# Create the section with codes for doc if it does not exist.
function mk_coding {
	FILE=$1
	if [[ $(grep -L -E "^## Codes$" $FILE) ]]; then
		echo -e "\n\n## Codes\n\n* @iteration" >> $FILE
	fi
	return
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


