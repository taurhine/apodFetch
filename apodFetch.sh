#!/bin/bash

#https://github.com/taurhine/apodFetch

##################
# static options #
######################################################

#default scale mode
defaultScaleMode="fill"

#effect to be applied to lock-screen  background
# effectOpt=""
effectOpt="-paint 2 -noise 10"

#show description as notification on wallpaper change
descAsNotification="enabled"

#show apodFetch messages as notification
messagesAsNotification="enabled"

#show description in lock-screen
lockscreenDesc="enabled"

######################################################

hashNameExt=".apodcache"
wpPath="/home/""$(whoami)""/Documents/wallpapers/apod"
cachePath="/home/""$(whoami)"
linkPrefix="https://apod.nasa.gov/apod"

ShowMessage()
{
    if test "$messagesAsNotification" = "enabled"; then
        notify-send "$1" "$2"
    else
        echo "$1" "$2"
    fi
}

CheckDependencies()
{
    echo "notify-send
          feh
          wget
          awk
          sed
          convert
          rdjpgcom
          html2text" | while read commandDep
    do
        if test "$(command -v $commandDep)" = ""; then
            case "$commandDep" in
                "notify-send")
                    messagesAsNotification="disabled"
                    ShowMessage "apodFetch: error" "package libnotify is missing"
                    ;;
                "convert")
                    ShowMessage "apodFetch: error" "package imagemagick is missing"
                    ;;
                "rdjpgcom")
                    ShowMessage "apodFetch: error" "package libjpeg-progs is missing"
                    ;;
                *)
                    ShowMessage "apodFetch: error" "package $commandDep is missing"
                    ;;
            esac
        fi
    done
    exit 1
}

EnsurePathExists()
{
    #create the destination path if it doesn't exist
    if [ ! -d $1 ]; then
        mkdir -p $1
    fi

    #abort execution if the path was not made
    if [ ! -d $1 ]; then
        ShowMessage "apodFetch: error" "Could not create ""\"$1\""
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
        "-d")
            CheckDependencies
            ;;
        "-r")
            randomDay="$(( ( RANDOM % 365 )  + 1 ))"
            targetDate=`date --date "-$randomDay day" +"%y%m%d"`
            ;;
        "-c")
            #this option accepts numbers >= 0
            if [[ $2 =~ ^[0-9]+$ ]]; then
                targetDate=`date --date "-$2 day" +"%y%m%d"`
            elif test "$2" = "today"; then
                targetDate=`date +"%y%m%d"`
            else
                ShowMessage "apodFetch: error" "invalid parameter for option -c ""$2"
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
                    ShowMessage "apodFetch: error" "unknown option ""$3"
                    exit 1
                    ;;
            esac
            ;;
            *)
                ShowMessage "apodFetch: error" "unknown option ""$1"
                exit 1
                ;;
    esac
}

GetDescription()
{
    #read the description from the jpg file and escape the '
    description=$(rdjpgcom $fileFullPath | sed "s/'/\\\'/g")
}

ShowDescriptionAsNotification()
{
    if test "$descAsNotification" = "enabled"; then
        notify-send -u critical "NASA Astronomy Picture for $targetDate" "$description"
    fi
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

        title="$(grep "<title>" $cachePath/cached.html | awk -F ' - ' '{print $2}')"

        description="$(sed -n '/Explanation:/,/Tomorrow/p' $cachePath/cached.html | html2text | sed 's/_/ /g' | sed 's/Explanation: //g' | sed '$d')"

        relativePicPath="$(cat $cachePath/cached.html | grep '^<IMG SRC=.*\.[jpegJPEG]*\"' | awk -F '"' '{print $2}')"

        if [ ! $relativePicPath ]; then
            ShowMessage "apodFetch: info" "No picture found for the date $targetDate"
            exit 1
        fi

        #compile the full link string
        fullLink=$linkPrefix/$relativePicPath

        #download the picture and add description
        wget -qO - $fullLink | wrjpgcom -replace -c "$title

$description" > $fileFullPath
    fi
}

ScaleAndSetWallpaper()
{
    #make sure that the file exists
    if [ ! -f $fileFullPath ]; then
        ShowMessage "apodFetch: error" "File not found: $fileFullPath"
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

    GetDescription

    if test "$effectOpt" = ""; then
        #no effect selected, copy the same file
        cp $wpPath"/apod.png" $wpPath"/apod_lock.png"
    else
        convert $effectOpt $wpPath"/apod.png" -quiet $wpPath"/apod_lock.png"
    fi

    #add description to the lock-screen
    if test "$lockscreenDesc" = "enabled"; then
        convert -quiet -pointsize 20 -fill white -undercolor black -draw "text 10,20 '$description' " $wpPath"/apod_lock.png" $wpPath"/apod_lock.png"
    fi

    #set the wallpaper
    feh --no-fehbg --bg-tile $wpPath"/apod.png"
}

EnsurePathExists $cachePath

EnsurePathExists $wpPath

GetParameters "$1" "$2" "$3"

DownloadPicture

ScaleAndSetWallpaper

ShowDescriptionAsNotification
