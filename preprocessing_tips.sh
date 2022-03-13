# Preprocessing tips

## Get an abbreviation of the source

source="$(yq -f=extract '.source' $file)"
abbr="$(echo $source | sed -E 's/(.)[^ ]* */\1/g')"
