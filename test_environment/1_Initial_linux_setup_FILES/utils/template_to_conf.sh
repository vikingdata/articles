#!/bin/bash

usage () {
    echo ""
    echo "Usage: $0 <dictionary_file> <template_file>"
    echo "Redirect output to a file. Such as

$0 mysql_dict.txt mysql_template.conf > mysql.conf

or if you download the example test
bash template_to_conf.sh dictionary.txt template.txt

and the output should be
----------------------------------------
# The result should be a sentence.
sentence1 = 'This is a sentence.'

# The result should be a numeric number.
numeric = 12345
----------------------------------------

In the dictionary each line has two words without the equal sign.
The first word is the keyword and the second is the value.
Use got the format @KEYWORD@ where the keyword is surrounded by '@'. 
Such as
@MAX_CONNECTIONS@ 100
"
}

# Exit if we don't have two arguments.
if [ "$#" -ne 2 ]; then
    usage
    echo "Less then 2 files given."
    exit 1
fi

DICT_FILE="$1"
TEMPLATE_FILE="$2"

# Abort if they do not exist.

if [ ! -f "$DICT_FILE" ]; then
    echo "Dictionary file does not exist: '$DICT_FILE'."
    exit 1
fi

if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "Template file does not exist: '$TEMPLATE_FILE'."
    exit 1
fi

# This is inefficient since it replaces read one line at at a time
# and does a replace one at a time. 
# Read each line in template file
while IFS= read -r line || [ -n "$line" ]; do
    if [[ "$line" =~ '#' ]]; then
	echo "$line"	 
	continue
    fi 

    # Read each line in dictionary file
    while IFS= read -r temp_line || [ -n "$temp_line" ]; do

	# Replace all double quotesd with single quote to make xagrs work.
        temp_line="${temp_line//\"/\'}"

	word=$(echo "$temp_line" | awk '{print $1}' | xargs)
	value=$(echo "$temp_line" | cut -d' ' -f2- )

	# Skip empty lines or if it has a #
	[[ -z "$word" || "$word" =~ ^# ]] && continue
	[[ -z "$value" || "$value" =~ ^# ]] && continue

	# strip any whitespace at end and beginning, it shouldn't exist
	word=$(echo "$word" | xargs)
	value=$(echo "$value" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
	
	# Make sure the word is alpnanumeric or -_@
	word=$(echo "$word" | tr -cd '[:alnum:]_ـ@')
	
        # Make sure value is also mostly alphganumeric
	# You may have to add characters to allow stuff
	# Replace double quote with single quote

	value=$(printf '%s' "$value" | sed "s/[^[:alnum:]_@;:!\#\$%^&*(){}\[\]'<> ,?\/-]//g")
	# skip if word or value is nothing
	if [ -z "$word" ] || [ -z "$value" ]; then
          continue
	fi

	# Escape the values for sed
	escaped_value=$(printf '%s' "$value" | sed 's/[\/&\\]/\\&/g')

	# Finally replace This word.
	# This word should have a @ so it is only replaced once
	# assuming the value does not have a'@'.
	old_line="$line"
	line=$(printf '%s\n' "$line" | sed "s/${word}/${escaped_value}/g")
	# If the line was replaced, echo it and break out of loop. 
	if [ "$line" != "$old_line" ]; then
	    break
	fi
	
	done < "$DICT_FILE"

    echo $line
done < "$TEMPLATE_FILE"
