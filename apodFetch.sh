#!/bin/bash

#https://github.com/taurhine/apodFetch

#static options
#effect to be applied to i3lock background
#effectOpt=""
effectOpt="-noise 10"
#effectOpt="-paint 2"

hashNameExt=".apodcache"
wpPath="/home/""$(whoami)""/Documents/wallpapers/apod"
cachePath="/home/""$(whoami)"

EnsurePathExists()
{
    #create the destination path if it doesn't exist
    if [ ! -d $1 ]; then
        mkdir -p $1
    fi

    #abort execution if the path was not made
    if [ ! -d $1 ]; then
        echo "Could not create ""\"$1\""
        exit 1
    fi
}

ScaleAndSetWallpaper()
{
    fileName=$wpPath/$1

    #make sure that the file exists
    if [ ! -f $fileName ]; then
        echo "File not found:""$fileName"
        exit 1;
    fi

    #get the current screen resolution
    screenRes="$(xrandr --current | grep 'primary' | awk -F ' ' '{print $4}' | awk -F '+' '{print $1}')"

    if test "$2" = "center"; then
        resizeOpt=""
    elif test "$2" = "fill"; then
        #decide whether to fit height or width
        screenW="$(echo $screenRes | awk -F 'x' '{print $1}')"
        screenH="$(echo $screenRes | awk -F 'x' '{print $2}')"
        picW="$(identify -format '%w' $fileName)"
        picH="$(identify -format '%h' $fileName)"

        if [ $picH -gt $screenH ]; then
            if [ $picW -lt $screenW ]; then
                fitDimension=$screenW
            else
                #both dimensions are bigger than the screen
                if [ $picW -lt $picH ]; then
                    fitDimension=$screenW
                else
                    fitDimension="x"$screenH
                fi
            fi
        else
            if [ $picW -gt $screenW ]; then
                fitDimension="x"$screenH
            else
                #both dimensions are smaller than the screen
                if [ $picW -gt $picH ]; then
                    fitDimension=$screenW
                else
                    fitDimension="x"$screenH
                fi
            fi
        fi
        resizeOpt="-resize "$fitDimension
    else
        resizeOpt="-resize $screenRes"
    fi

    #scale and resize the picture for the current resolution
    convert  -background black $resizeOpt -extent $screenRes -gravity center $fileName $wpPath"/apod.png"

    if test "$effectOpt" = ""; then
        #no effect selected, copy the same file
        cp $wpPath"/apod.png" $wpPath"/apod_lock.png"
    else
        convert $effectOpt $wpPath"/apod.png" $wpPath"/apod_lock.png"
    fi

    #update the wallpaper
    feh --no-fehbg --bg-tile $wpPath"/apod.png"
}

#ensure cace path exists, try to create if it doesn't
EnsurePathExists $cachePath

#ensure that the destination path exists, try to create if it doesn't
EnsurePathExists $wpPath

if test "$1" = ""; then
    echo "normal mode"
elif test "$1" = "-f"; then
    echo "forced update"
    rm $cachePath/*$hashNameExt
elif test "$1" = "-c"; then
    #this option accepts numbers >= 0
    if [[ $2 =~ ^[0-9]+$ ]]; then
        fileName=`date --date "-$2 day" +"%Y%m%d"`".jpg"
    elif test "$2" = "today"; then
        fileName=`date +"%Y%m%d"`".jpg"
    else
        echo "invalid parameter for option -c ""$2"
        exit 1
    fi

    if test "$3" = "fill"; then
        #set the wallpaper without resizing
        ScaleAndSetWallpaper $fileName $3
    elif test "$3" = "center"; then
        ScaleAndSetWallpaper $fileName $3
    elif test "$3" = ""; then
        #set the wallpaper
        ScaleAndSetWallpaper $fileName
    else
        echo "unknown option ""$3"
        exit 1
    fi

else
    echo "unknown option ""$1"
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
        linkPrefix="https://apod.nasa.gov/apod"

        #remove the old cache files
        find $cachePath/*$hashNameExt -mtime +1 -exec rm {} \;

        #rename the file to the hash
        mv $cachePath/cached.html $cachePath/$hashName

        relativePicPath="$(cat $cachePath/$hashName | grep '^<a href.*\.[jpegJPEG]*\">$' | awk -F '"' '{print $2}')"

        if [ ! $relativePicPath ]; then
            echo "No picture found!"
            exit 1
        fi

        #compile the full link string
        fullLink=$linkPrefix/$relativePicPath

        #prepare the filename string
        fileName=`date +"%Y%m%d"`".jpg"

        #download the picture
        wget -q $fullLink -O $wpPath/$fileName

        #set the wallpaper
        ScaleAndSetWallpaper $fileName
    fi
fi
