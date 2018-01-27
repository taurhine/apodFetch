# apodFetch
For the i3wm minimalists... A bash script to change your wallpaper daily to the NASA's astronomy picture of the day.

# setup
* add the following lines to your ~/.i3/config

exec --no-startup-id /<b>path of your choice</b>/apodFetch.sh"

exec_always feh --no-fehbg --bg-fill ~/Documents/wallpapers/apod/apod.jpg

* add the following line if you want to use the same wallpaper for the i3lock, in my case I've bound l for the lock screen
bindsym l exec --no-startup-id "i3lock -i ~/Documents/wallpapers/apod/apod.png", mode "default"
