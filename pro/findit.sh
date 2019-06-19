#!/bin/bash 

something=$1

for i in `ls *.pro`; do  
    grep $something $i 
    echo $i ;
done
