isolate_quotes () {
	sed -n '/>>/,/<</p' $1 \
		| sed -E -e 's/<<[^>>]*/\n<</g' -e 's/[^<<]*>>/\n>>\n/g'
}

get_margins () {
	sed -E 's/\|/\n\n|/' $1 \
		| sed -E '/^((\||>>|<<).*)/!d'
}

parse_actors () {
	sed 's/$/ /g' $tmp2 \
		| grep -E -o -z "@\w* |<<" \
		| sed 's/<</\n/g'
}

parse_tags () {
	sed 's/$/ /g' $tmp2 \
		| grep -E -o -z "#\w* |<<" \
		| sed 's/<</\n/g'
}

parse_quotes () {
	sed -E -e 's/(\||>>).*$//g' $1 \
		| tr '\n' ' ' \
		| sed 's/<</\n/g' \
		| sed 's/  / /g'
}

table_file () {
	FILE=$1

	# trap 'rm -f $tmp1 $tmp2 $tmp3 $tmp4 $tmp5' EXIT
	# tmp1=$(mktemp)
	# tmp2=$(mktemp)
	# tmp3=$(mktemp)
	# tmp4=$(mktemp)
	# tmp5=$(mktemp)

	isolate_quotes $FILE > $tmp1
	get_margins $tmp1 > $tmp2
	parse_actors $tmp2 > $tmp3
	parse_tags $tmp3 > $tmp4
	parse_quotes $tmp1 > $tmp5

	paste -d "|" $tmp3 $tmp4 $tmp5 \
		# Accidentally introduced a null byte somewhere?
		| tr -d '\0'

}

table_file data/arenas/ss_01.md

# table () {
# 	for i in $@; do
# 		file=$i
# 	done
# }