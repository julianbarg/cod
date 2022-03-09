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