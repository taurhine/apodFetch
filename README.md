# apodFetch
For the i3wm minimalists... A bash script to change your wallpaper daily to the NASA's astronomy picture of the day.

# setup
* add the following lines to your ~/.i3/config
  
  exec --no-startup-id /<b>path of your choice</b>/apodFetch.sh"
  
  exec_always feh --no-fehbg --bg-fill ~/Documents/wallpapers/apod/apod.png

* add the following line if you want to use the same wallpaper for the i3lock, in my case I've bound l for the lock screen
  
  bindsym l exec --no-startup-id "i3lock -c 000000 -i ~/Documents/wallpapers/apod/apod_lock.png", mode "default"

# forcing apodFetch to update the wallpaper
  
  apodFetch.sh -f

# changing the wallpaper
* you can switch to an older wallpaper by using the option -c with a positive integer indicating the number of days to go backwards Switching to yesterdays picture:

  apodFetch.sh -c 1

* to switch back to todays picture use one of the following commands

  apodFetch.sh -c 0

  apodFetch.sh -c today

# changing the scaling mode
* by default apodFetch fits the whole picture into the screen, which doesn't always look nice, to override the scaling mode use the following options

* fill option preserves aspect ratio by zooming the picture until it fits. Either a horizontal or a vertical part of the picture will be cut off.

  Example to switch to todays picture with fill mode

  apodFetch.sh -c 0 fill

* center option will center the picture on the screen without resizing it. Pictures which are bigger than the screen resolution will be zoomed in.

  Example to switch to todays picture with center mode

  apodFetch.sh -c 0 center
