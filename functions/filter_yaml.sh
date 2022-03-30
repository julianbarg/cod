filter_yaml () {
	trap 'rm -f $tmp1 $tmp2 $tmp3' EXIT
	tmp1=$(mktemp)
	tmp2=$(mktemp)

	ls $@ | cat > $tmp1

	sed -s '/---/,/\.\.\./!d' $@ \
		| yq '.iterations | contains(["2022-03-13"])' --no-doc \
		> $tmp2

	paste $tmp1 $tmp2 -d "|" \
		| sed 's/|/: /' \
		| yq '. | with_entries(select(.value == true)) | keys | .[]'

	rm -f $tmp1 $tmp2
}