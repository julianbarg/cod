function print_piece {
	#TODO: add optional flag to highlight additional word.
	# Append to $HIGLIGHT separated by ```|```.
	for i; do
		if [ "$FULL" = true ]; then
			print_full $i
		else
			choice_preview $i
		fi
	done
}