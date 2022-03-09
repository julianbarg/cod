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
			read -p "> " selection
			code="$( cat $YAML | yq ".${PROJECT}.codes.${selection}" )"
			if [[ "$selection" != "x" && "$code" != "null" ]]; then
				insert_code "${code}" "${ITERATION}" $i
			elif [[ "$selection" != "x" && "$code"=="null" ]]; then
				echo "Invalid code--choose again."
			fi
		done
		selection=""
		# To see verbose output and see that input is registered.
		sleep .2
		# Make sure the iteration is entered even if no code set?
		# insert_iteration_ $ITERATION $i
	done
}