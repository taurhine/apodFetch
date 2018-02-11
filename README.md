# apodFetch
For the i3wm minimalists... A bash script to change your wallpaper daily to the NASA's astronomy picture of the day.

# dependencies
* before using the script for the first time use check dependency mode to make sure you have all required packages installed

/<b>path to the script</b>/apodFetch.sh -d

# setup
* to run the script via i3 config add the following lines to your ~/.i3/config
  
  exec --no-startup-id "/<b>path to the script</b>/apodFetch.sh"
  
  exec_always feh --no-fehbg --bg-fill ~/Documents/wallpapers/apod/apod.png
  
* if you want to use cron instead either use crontab or if you are using cron.* call the script with su - USERNAME -c "/<b>path to the script</b>/apodFetch.sh" or similar so that the script will not be executed as root.

* add the following line if you want to use the same wallpaper for the i3lock, in my case I have bound l for the lock screen
  
  bindsym l exec --no-startup-id "i3lock -c 000000 -i ~/Documents/wallpapers/apod/apod_lock.png", mode "default"

# changing the wallpaper
* you can switch to an older wallpaper by using the option -c with a positive integer indicating the number of days to go backwards Switching to yesterdays picture:

  apodFetch.sh -c 1

* to switch back to todays picture use one of the following commands

  apodFetch.sh -c 0

  apodFetch.sh -c today

* to switch to a random day within the last year use the -r option

  apodFetch.sh -r

# changing the scaling mode

* by default apodFetch is in "fill" mode

* fill option fits the picture to the screen width

  apodFetch.sh -c 0 fill

* center option will center the picture on the screen without resizing it. Pictures which are bigger than the screen resolution will be zoomed in.

  apodFetch.sh -c 0 center

* fitall option will resize the picture so that it completely fits in the screen.

  apodFetch.sh -c 0 fitall
  
