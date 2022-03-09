# Open documents one by one and take some data to be written to an
# output file.
function take_data {
	ITERATION=$1
	shift
	if [[ -z PROJECT ]]; then
		echo "No project selected!"
  		exit 1
  	fi
}