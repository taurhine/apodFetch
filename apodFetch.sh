#!/bin/bash

#https://github.com/taurhine/apodFetch

#static options
defaultScaleMode="fill"
#effect to be applied to i3lock background
#effectOpt=""
effectOpt="-paint 2 -noise 10"
#effectOpt="-paint 2"

hashNameExt=".apodcache"
wpPath="/home/""$(whoami)""/Documents/wallpapers/apod"
cachePath="/home/""$(whoami)"
linkPrefix="https://apod.nasa.gov/apod"

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

GetParameters()
{
    #initialise the scaleMode with the default setting
    scaleMode=$defaultScaleMode

    #check the parameters to define the target date
    case "$1" in
        "")
            #by default the target date will be set to today
            targetDate=`date +"%y%m%d"`
        ;;
        "-c")
            #this option accepts numbers >= 0
            if [[ $2 =~ ^[0-9]+$ ]]; then
                targetDate=`date --date "-$2 day" +"%y%m%d"`
            elif test "$2" = "today"; then
                targetDate=`date +"%y%m%d"`
            else
                echo "invalid parameter for option -c ""$2"
                exit 1
            fi

            case "$3" in
                "")
                    scaleMode=$defaultScaleMode
                    ;;
                "fill" | "fitall" | "center")
                    scaleMode=$3
                    ;;
                *)
                    echo "unknown option ""$3"
                    exit 1
                    ;;
            esac
            ;;
            *)
                echo "unknown option ""$1"
                exit 1
                ;;
    esac
}

DownloadPicture()
{
    fileName=$targetDate".jpg"

    #check if we already have a picture from that date
    fileFullPath=$wpPath/$fileName

    #if the file does not exist try to download it
    if [ ! -f $fileFullPath ]; then
        #fetch the webpage
        wget $linkPrefix/"ap"$targetDate".html" -q -O $cachePath/cached.html

        relativePicPath="$(cat $cachePath/cached.html | grep '^<IMG SRC=.*\.[jpegJPEG]*\"$' | awk -F '"' '{print $2}')"

        if [ ! $relativePicPath ]; then
            echo "No picture found for $targetDate"
            exit 1
        fi

        #compile the full link string
        fullLink=$linkPrefix/$relativePicPath

        #download the picture
        wget -q $fullLink -O $fileFullPath
    fi
}

ScaleAndSetWallpaper()
{
    #make sure that the file exists
    if [ ! -f $fileFullPath ]; then
        echo "File not found:""$fileFullPath"
        exit 1;
    fi

    #get the current screen resolution
    screenRes="$(xrandr --current | grep 'primary' | awk -F ' ' '{print $4}' | awk -F '+' '{print $1}')"

    case $scaleMode in
        "center")
            resizeOpt=""
            ;;
        "fill")
            screenW="$(echo $screenRes | awk -F 'x' '{print $1}')"
            resizeOpt="-resize $screenW"
            ;;
        *)
            resizeOpt="-resize $screenRes"
            ;;
    esac

    #scale and resize the picture for the current resolution
    convert -background black $resizeOpt -extent $screenRes -gravity center -quiet $fileFullPath $wpPath"/apod.png"

    if test "$effectOpt" = ""; then
        #no effect selected, copy the same file
        cp $wpPath"/apod.png" $wpPath"/apod_lock.png"
    else
        convert $effectOpt $wpPath"/apod.png" -quiet $wpPath"/apod_lock.png"
    fi

    #set the wallpaper
    feh --no-fehbg --bg-tile $wpPath"/apod.png"
}

EnsurePathExists $cachePath

EnsurePathExists $wpPath

GetParameters "$1" "$2" "$3"

DownloadPicture

ScaleAndSetWallpaper
