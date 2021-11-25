#!/bin/bash

# This script contains useful bash functions 

## rename2 ----------
## Function to rename the name of one or multiple files
## Go to the directory where you have the files that have to be renamed.
## Call rename2 with two arguments: (1) part of the name you want to change and (2) new name to substitute that part.
## e.g. rename2 hello bye ## this will change the name all the files that have "hello" in their name and will substitute it for "bye".
rename2() {
    for i in *$1*
    do
        mv "$i" "${i/$1/$2}"
    done
}