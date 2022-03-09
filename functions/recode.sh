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