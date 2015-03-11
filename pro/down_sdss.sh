#!/bin/bash

if [ $1 ]
then

    if [ $2 ] 
    then 
        size=$2
    else
        size=1024
    fi 

    if [ $3 ] 
    then 
        suffix=$3 
    else 
        suffix="sdss"
    fi 

    round=0

    for i in `cat $1`; do

        round=`echo " $round + 1" | bc`

        #Read the Inputs
        name=`echo $i  |awk -F "," '{print $1}'`
        ra=`echo $i  |awk -F "," '{print $2}'`
        dec=`echo $i  |awk -F "," '{print $3}'`

        #jpeg cutout file name:
        jpeg=$name'_'$suffix'.jpeg'

        #download the jpeg cutout
        wget 'http://skyservice.pha.jhu.edu/DR10/ImgCutout/getjpeg.aspx?ra='$ra'&dec='$dec'&scale=0.4&width='$size'&height='$size'&opt=GLS&query=&Grid=on&Label=on&SpecObjs=on' -O $jpeg

    done 

else
    echo "./down_sdss.sh input_list [size(pixel)  suffix]"
fi
