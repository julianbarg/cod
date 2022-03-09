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