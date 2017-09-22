#!/bin/bash -
cat params.json |sed 's|[{}]||g'|sed 's|\"||g'|sed 's/[][]//g'|sed 's|:\ |=|g'|sed '/^\s*$/d'|tr -d "\012"|sed -e 's/ //g'|sed 's|,|, |g' > stage.csv
params=$(cat stage.csv)
if [ $(cat change.properties |wc -w) = 0 ]; then
        echo -n "${params}" >> change.properties
else
        echo -n ", " >> change.properties
        echo -n "${params}" >> change.properties
fi
sed -i ':a;N;$!ba;s/\n//g' change.properties
rm stage.csv

