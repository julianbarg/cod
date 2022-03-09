#!/bin/bash

LOCATION="$(dirname ${BASH_SOURCE[0]})"

echo "Location: $LOCATION"

source "$LOCATION/cod.sh"

cod precode -y "$LOCATION/example_files/codes.yaml" -p precode \
	-i 2022-03-03 "$LOCATION/example_files/data/*"