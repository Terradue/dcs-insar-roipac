#!/bin/bash


# for all input ASAR products, retrieve the auxiliary products
# ASA_CON_AX
# ASA_INS_AX

while read input
do
	echo "INPUT: " $input 
	echo $input | ciop-publish -s
done
