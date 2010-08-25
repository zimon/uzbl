#!/bin/sh

if [ $# = "3" ]
then
	fifo="$1"
	url="$2"
	SCRIPT="$3"
else
	fifo="$4"
	url="$6"
	SCRIPT="$8"
fi

# Extract metadata chunk
META="`sed -ne '/^\s*\/\/\s*==UserScript==\s*$/,/^\s*\/\/\s*==\/UserScript==\s*$/p' "$SCRIPT"`"
SHOULD_RUN=false # Assume this script will not be included
# Loop over all include rules
for INCLUDE in `echo "$META" | grep "^\s*\/\/\s*@include"`; do
	# Munge into grep pattern
	INCLUDE="`echo "$INCLUDE" | sed -e 's/^\s*\/\/\s*@include\s*//' -e 's/\./\\\\./g' -e 's/\*/.*/g' -e 's/[\r\n]//g'`"
	if echo "$url" | grep -x "$INCLUDE"; then
		SHOULD_RUN=true
		break
	fi
done

# Loop over all exclude rules
for EXCLUDE in `echo "$META" | grep "^\s*\/\/\s*@exclude"`; do
	# Munge into grep pattern
	EXCLUDE="`echo "$EXCLUDE" | sed -e 's/^\s*\/\/\s*@exclude\s*//' -e 's/\./\\\\./g' -e 's/\*/.*/g' -e 's/[\r\n]//g'`"
	if echo "$url" | grep -x "$EXCLUDE"; then
		SHOULD_RUN=false
		break
	fi
done

# Run the script
if [ $SHOULD_RUN = true ]; then
	echo "script '$SCRIPT'" > "$fifo"
fi
