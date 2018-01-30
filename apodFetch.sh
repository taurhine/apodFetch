#!/bin/bash

#https://github.com/taurhine/apodFetch

#check if there is already a cache file from today
hashNameExt=".apodcache"
wpPath="/home/""$(whoami)""/Documents/wallpapers/apod"
cachePath="/home/""$(whoami)"

#check if the cache path exist
if [ ! -d $cachePath ]; then
    echo "Cache path ""\"$cachePath\""" doesn't exist!"
    exit 1
fi

#get the name of the cache file from today
todaysCache="$(find $cachePath/*$hashNameExt -mtime 0 | grep $hashNameExt)"

#if there is no cache file from today then fetch the page
if [ ! "$todaysCache" ]; then

    #fetch the webpage
    wget https://apod.nasa.gov/apod/astropix.html -q -O $cachePath/cached.html

    #get the sha1 hash of the file
    hashName="$(sha1sum $cachePath/cached.html | awk '{print $1}')""$hashNameExt"

    #check if a file with the same name exists
    if [ ! -f ./$hashName ]; then
        linkPrefix="https://apod.nasa.gov/apod/"

        #create the destination path if it doesn't exist
        if [ ! -d $wpPath ]; then
            mkdir -p $wpPath
        fi

        #abort execution if the walpaper path was not made
        if [ ! -d $wpPath ]; then
            echo "Could not create ""\"$wpPath\""
            exit 1
        fi

        #remove the old cache files
        find *$hashNameExt -mtime +1 -exec rm {} \;

        #rename the file to the hash
        mv $cachePath/cached.html $cachePath/$hashName

        relativePicPath="$(cat $cachePath/$hashName | grep '^<a href.*\.[jpegJPEG]*\">$' | awk -F '"' '{print $2}')"

        if [ ! $relativePicPath ]; then
            echo "No picture found!"
            exit 1
        fi

        #compile the full link string
        fullLink=$linkPrefix$relativePicPath

        #prepare the filename string
        fileName=`date +"%Y%m%d"`".jpg"

        #download the picture
        wget -q $fullLink -O $wpPath/$fileName

        #save the file as the current wallpaper
        cp $wpPath/$fileName $wpPath"/apod.jpg"

        #get the current screen resolution
        screenRes="$(xrandr --current | grep 'primary' | awk -F ' ' '{print $4}' | awk -F '+' '{print $1}')"

        #convert and scale the jpg to png in current resolution to use it as i3lock background
        convert -scale $screenRes $wpPath"/apod.jpg" $wpPath"/apod.png"

        #update the background picture
        feh --no-fehbg --bg-fill $wpPath"/apod.jpg"
    fi
fi
