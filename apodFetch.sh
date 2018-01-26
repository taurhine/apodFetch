#!/bin/bash

#check if there is already a cache file from today
hashNameExt=".apodcache"
wpPath="/home/""$(whoami)""/Documents/wallpapers/apod"
cachePath="/home/""$(whoami)"
todaysCache="$(find $cachePath/*$hashNameExt -mtime 0 | grep $hashNameExt)"

#if there is no cache from today then fetch the page
if [ ! "$todaysCache" ]; then

    #fetch the webpage
    wget https://apod.nasa.gov/apod/astropix.html -q -O $cachePath/cached.html

    #get the sha1 hash of the file
    hashName="$(sha1sum $cachePath/cached.html | awk '{print $1}')""$hashNameExt"

    #check if a file with the same name exists
    if [ ! -f ./$hashName ]; then
        linkPrefix="https://apod.nasa.gov/apod/"

        # create the destination path if it doesn't exist
        if [ ! -d $wpPath ]; then
            mkdir -p $wpPath
        fi

        #remove the old cache files
        find *.cache -mtime +1 -exec rm {} \;

        #rename the file to the hash
        mv $cachePath/cached.html $cachePath/$hashName

        #compile the full link string
        fullLink=$linkPrefix$(cat $cachePath/$hashName | grep '^<a href.*\.[jpegJPEG]*\">$' | awk -F '"' '{print $2}')

        #download the picture
        fileName=`date +"%Y%m%d"`".jpg"
        wget -q $fullLink -O $cachePath/$fileName

        #copy the file to its destination
        cp $cachePath/$fileName $wpPath/
        mv $cachePath/$fileName $wpPath"/apod.jpg"

        #convert the jpg to png to use it as i3lock background
        convert $wpPath"/apod.jpg" $wpPath"/apod.png"

        #update the background picture
        feh --no-fehbg --bg-fill $wpPath"/apod.jpg"
    fi
fi
