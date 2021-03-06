#!/bin/bash
#  linear recurrence family duopentanacci a(n)=a(n-4)+a(n-5)
cd "$(dirname ${BASH_SOURCE[0]})"
source ./suitestools.sh

declare -a suite=()
declare -a args=( "$@" )
declare -a modulo=()

for i in `seq 0 $(($#-2))`
do
suite[$i]=`echo ${args[$i]}`
done

maxoffset=`echo ${args[$(($# -1))]}`

for i in `seq $(($# - 1)) $maxoffset`
do 
suite $i ${suite[$(($i-4))]} ${suite[$(($i-5))]}
done 

for i in `seq 0 $(($maxoffset -1 ))` 
do 
modulo[$i]=`mod3 ${suite[$i]}` 
done

tmpfile='/tmp/tempmod.txt'
mathfile='/tmp/math.m'
output='/tmp/outputmodulo'

echo  "${modulo[@]}" | sed 's/ /,/g'> $tmpfile
echo "f = Module[{b, c = 1}," > $mathfile 
echo "   While[Length[b = Union@Partition[#, c, c, {1, 1}, Take[#, c]]] > 1, c++];" >> $mathfile
echo "   {Length@First@b, First@b}] &;" >> $mathfile
echo "Print[ f@{"`cat $tmpfile`"}]" >> $mathfile
echo "Exit[]" >> $mathfile

./math.sh -noprompt -script $mathfile > $output

cat $output | sed 's/}}/}/g' |sed 's/, \([0-9]\)/,\1/g' | cut -d" " -f 2 | sed 's/,/, /g'
