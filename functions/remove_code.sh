# Remove a specific code from documents.
function remove_code {
	# This would not work if the code exists more than once for some
	# reason, but I think I can handle that later.
	# echo "Removing code '${CODE}'"
	CODE=$1
	shift

	for i ; do
		sed -i -E "/\* #${CODE}$/d" $i
	done
}
