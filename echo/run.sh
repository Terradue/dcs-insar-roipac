#!/bin/bash

while read input
do
	echo "INPUT: " $input 
	echo $input | ciop-publish -s
done
