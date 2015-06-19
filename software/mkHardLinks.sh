#!/bin/bash

# Where are all of the LCM download bits
DLHOME=~/Downloads/Software/Oracle/IAM/11.1.2.3/LCM


#the function that does the work
link()
{
    # won't happen since I'm the only one using this
    # but better safe than sorry 
    if [ -z "$1" ]; then
	echo "error in usage:"
	echo "link <real file name> [<what to call it>]"
	exit
    fi

    original=$1
    echo "$original:"

    if [ ! -e $original ]; then
	echo File \"$original\" does NOT exist
	echo aborting!
	exit -1
    fi

    if [ -z "$2" ]; then
	#echo assuming same name
	localname=`basename $original`
    else
	localname=$2
    fi

    echo "  local name: $localname";
    #echo "Hard linking $original to $localname..."
    if [ -e $localname ]; then
	echo "  already exists."
    else
        ln "$original" "$localname"
        echo "  linked."
    fi
}

# the for loop that links all of the files
for file in $DLHOME/*.zip; do
    link $file
done

# make the files readable by everyone
chmod a+r *
