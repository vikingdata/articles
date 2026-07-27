#!bash

for f in no_index.log where_first.log join_first.log; do

    total=1
    eq=""
    for n in `grep -i rows: $f | cut -d ":" -f 2`; do
	let total=$total*$n
	if [ "$eq" = "" ] ; then
	    eq=$n
	else
	    eq="$eq*$n"
	fi	
    done
    echo "For $f, the no of rows is calcualted from the explain"
    echo "    $eq = $total"
done
