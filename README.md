Ruby scripts for generaing openbox pipemenus


#ob_rmenu.rb /path/to/textfile

Generates openbox pipemenu from a textfile formatted like this

```
terminal=terminator
run...=gmrun

home=xdg-open .
menu:applications
	firefox=firefox -P default
	
	hexchat=hexchat
	hangouts=/usr/bin/chromium --app-id=knipolnnllmklapflnccelgolnpehhpl
	
	rhythmbox=rhythmbox
	asunder=asunder
	brasero=brasero
	
	geany=geany
	
	exec:all=$menu_folder/ob_rmenu_apps.rb

menu:video/sound	
	nvidia settings=nvidia-settings
	exec:monitor setup=$menu_folder/ob_rmenu_monitors.rb
	
	mixer=terminator -e alsamixer
	
	switch hdmi sound=sh -c "FILE=~/.asoundrc; if [ -f $FILE ]; then rm $FILE; else printf 'pcm.!default {\n  type hw\n  card 1\n  device 7\n}' > $FILE; fi"

menu:configs
	~/.config=xdg-open .config
	~/.config/openbox=xdg-open .config/openbox
	~/.mpv=xdg-open .mpv
menu:desktop
	menu:screenshot
		screenshot (1s)=scrot -d 1
		screenshot (3s)=scrot -d 3
		screenshot (5s)=scrot -d 5
		screenshot (area)=scrot -s
	appearance=lxappearance
	wallpaper=nitrogen style/wallpaper --sort=time

menu:openbox
	action:reconfigure
	action:restart
	action:exit

lock=slock
reboot=reboot
shutdown=poweroff
```

##~/.config/openbox/menu.xml

```
<?xml version="1.0" encoding="UTF-8"?>
<openbox_menu xmlns="http://openbox.org/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://openbox.org/ file:///usr/share/openbox/menu.xsd">
	<menu id="root-menu" label="Openbox 3" execute="path/to/ob_rmenu.rb path/to/root_menu"/>
</openbox_menu>
```

#ob_rmenu_monitors.rb

Generates openbox pipemenu for configuring monitor positions using output from xrandr

##example output for 3 monitors

```
<openbox_pipe_menu>
<separator label="[x]"/>
<item label="[HDMI-0]"><action name="Execute"><execute> sh -c 'xrandr --output HDMI-0 --auto --pos 0x0 ;xrandr --output DP-0 --off ;xrandr --output DP-1 --off '</execute></action></item>
<item label="[DP-0]"><action name="Execute"><execute> sh -c 'xrandr --output DP-0 --auto --pos 0x0 ;xrandr --output HDMI-0 --off ;xrandr --output DP-1 --off '</execute></action></item>
<item label="[DP-1]"><action name="Execute"><execute> sh -c 'xrandr --output DP-1 --auto --pos 0x0 ;xrandr --output HDMI-0 --off ;xrandr --output DP-0 --off '</execute></action></item>
<separator label="[x+y]"/>
<item label="[HDMI-0+DP-0]"><action name="Execute"><execute> sh -c 'xrandr --output HDMI-0 --auto --pos 0x0 ;xrandr --output DP-1 --off ; xrandr --output DP-0 --auto --pos 0x0'</execute></action></item>
<item label="[HDMI-0+DP-1]"><action name="Execute"><execute> sh -c 'xrandr --output HDMI-0 --auto --pos 0x0 ;xrandr --output DP-0 --off ; xrandr --output DP-1 --auto --pos 0x0'</execute></action></item>
<item label="[DP-0+DP-1]"><action name="Execute"><execute> sh -c 'xrandr --output DP-0 --auto --pos 0x0 ;xrandr --output HDMI-0 --off ; xrandr --output DP-1 --auto --pos 0x0'</execute></action></item>
<separator label="[x][y]"/>
<item label="[HDMI-0][DP-0]"><action name="Execute"><execute> sh -c 'xrandr --output HDMI-0 --auto --pos 0x0 ;xrandr --output DP-1 --off ; xrandr --output DP-0 --auto --right-of HDMI-0'</execute></action></item>
<item label="[HDMI-0][DP-1]"><action name="Execute"><execute> sh -c 'xrandr --output HDMI-0 --auto --pos 0x0 ;xrandr --output DP-0 --off ; xrandr --output DP-1 --auto --right-of HDMI-0'</execute></action></item>
<item label="[DP-0][HDMI-0]"><action name="Execute"><execute> sh -c 'xrandr --output DP-0 --auto --pos 0x0 ;xrandr --output DP-1 --off ; xrandr --output HDMI-0 --auto --right-of DP-0'</execute></action></item>
<item label="[DP-0][DP-1]"><action name="Execute"><execute> sh -c 'xrandr --output DP-0 --auto --pos 0x0 ;xrandr --output HDMI-0 --off ; xrandr --output DP-1 --auto --right-of DP-0'</execute></action></item>
<item label="[DP-1][HDMI-0]"><action name="Execute"><execute> sh -c 'xrandr --output DP-1 --auto --pos 0x0 ;xrandr --output DP-0 --off ; xrandr --output HDMI-0 --auto --right-of DP-1'</execute></action></item>
<item label="[DP-1][DP-0]"><action name="Execute"><execute> sh -c 'xrandr --output DP-1 --auto --pos 0x0 ;xrandr --output HDMI-0 --off ; xrandr --output DP-0 --auto --right-of DP-1'</execute></action></item>
</openbox_pipe_menu>
```

#ob_rmenu_steam.rb /path/to/SteamApps

Generates openbox pipemenu for starting Steam games

#ob_rmenu_apps.rb

Generates openbox pipemenu with all applications in /usr/share/applications sorted in categories

#ob_rmenu_processes.rb

Generates openbox pipemenu for viewing and terminating processes

#ob_rmenu_folder.rb /path/to/folder

Generates openbox pipemenu for browsing and opening folders