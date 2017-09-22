#!/bin/bash -
cat params.json |sed 's|[{}]||g'|sed 's|\"||g'|sed 's/[][]//g'|sed 's|:\ |=|g'|sed '/^\s*$/d'|tr -d "\012"|sed -e 's/ //g' > stage.csv
params=$(cat stage.csv)
echo -n "${params}" >> change.properties 
rm stage.csv

