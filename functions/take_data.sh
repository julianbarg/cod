# Utility function for individual role. I do not anticipate to call this
# elsewhere, so for now it can stay in this file.

function take_row {
	ITERATION=$1
	FILE=$2
	# Could validate $PROJECT & OUTPUT here, but I do not anticipate to
	# call this function directly.

  	COLS=$( cat $YAML | yq ".${PROJECT}.cols" | yq 'join(" ")' )
  	local input
  	local row
  	# Lazy way of wrapping entry in double quotes.
  	row+='"'
  	row+="${FILE}"
  	row+='",'
  	NAME="$(basename ${FILE})"
  	ID="${NAME%.*}"
  	row+='"'
  	row+="${ID}"
  	row+='",'

	print_piece $FILE
  	for col in $COLS; do
  		echo "Input for ${col}:"
  		read -p "> " input
  		row+='"'
  		row+="${input}"
  		row+='",'
  	done 
  	# Remove trailing comma
  	row=${row%?}
  	echo "${row}" >> "${OUTPUT}"
  	insert_iteration_ "${ITERATION}" "${FILE}"
  	return 0
}

# Open documents one by one and take some data to be written to an
# output file.

function take_data {
	# TODO: Need to implement a function to validate csv--if there are cols
	# added to the yaml we want to collect additional data only.
	ITERATION=$1
	shift
	# filter_folder to allow for continuing an iteration.
	to_code=($(filter_folder "" $ITERATION $@ ))
	set -- "${to_code[@]}"


	if [[ -z $PROJECT ]]; then
		echo "No project selected!"
  		exit 1
  	fi
  	if [[ -z $OUTPUT ]]; then
		echo "No output file selected!"
  		exit 1
  	fi

  	# For debugging:
	if [ "$VERBOSE" = true ]; then
		echo "Iteration: $ITERATION"
		echo "YAML: $YAML"
		echo "Project: $PROJECT"
		echo "Output: $OUTPUT"
		#TODO: this may yield negative result.
		more=$(($# - 3))
		echo "Files to code: $1, $2, $3 and $more more."
	fi

	# Writing header row.
  	if [[ ! -f "${OUTPUT}" ]]; then
  		touch "${OUTPUT}"
  		COLS="file,id,"
  		COLS+="$( cat $YAML | yq ".${PROJECT}.cols" | yq 'join(",")' )"
  		echo "${COLS}" >> "${OUTPUT}"
  	fi

  	for i; do
		take_row "${ITERATION}" $i
  	done

}