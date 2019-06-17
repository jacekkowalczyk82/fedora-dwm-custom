# How to setup i3 at fedora 29

* Why ? Fedora with Gnome is not usabl -it is conssuming too much resources. 

## Update system and install packages

```
sudo dnf install i3 i3status i3lock terminator 
sudo dnf install compton nitrogen udiskie 
sudo dnf install pasystray network-manager-applet pavucontrol

#I used to be using clipit with window managers but here it does not work I just disabled it and still have clipboard
sudo dnf install clipit
```

## Update i3 config file `~/.config/i3/config` and add 

```
exec --no-startup-id nitrogen --restore & 

#exec --no-startup-id conky -c ~/.i3wm_conkyrc & # no conky yet

#automount cd/dvd, usb disks and show notifications
exec --no-startup-id udiskie -ant & 

#network manager applet
exec --no-startup-id nm-applet & 

#volume vontrol applet in systray
exec --no-startup-id pasystray & 

exec --no-startup-id compton -b & 

#exec --no-startup-id gnome-power-manager & # I need to check the name of application
#exec --no-startup-id clipit & # I disabled it as it is blocking the clipboard

#I am running also Dropbox 
exec dropbox start -i & 

### additional shortkeys
bindsym $mod+Shift+b exec "i3-nagbar -t warning -m 'You pressed the system restart shortcut. Do you really want to reboot?' -b 'Yes, Reboot now' 'systemctl reboot'"
bindsym $mod+Shift+p exec "i3-nagbar -t warning -m 'You pressed the system poweroff shortcut. Do you really want to shot the system down?' -b 'Yes, PowerOff now' 'systemctl poweroff'"

```

* Find key binding for starting new terminal and update to (inside i3 config file `~/.config/i3/config`)

```
# start a terminal
#bindsym $mod+Return exec i3-sensible-terminal
bindsym $mod+Return exec terminator 

```

## Reboot the system and at the login screen select i3 
