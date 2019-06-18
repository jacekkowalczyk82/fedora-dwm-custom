# fedora-live-dwm-ultra-light.ks
#
# Description:
# - Fedora Live Spin with the light-weight XFCE Desktop Environment
#
# Maintainer(s):
# - Jacek Kowalczyk jack82@null.net 


%include /usr/share/spin-kickstarts/fedora-live-base.ks
%include /usr/share/spin-kickstarts/fedora-live-minimization.ks
#%include /usr/share/spin-kickstarts/fedora-xfce-common.ks

repo --name=fedora-modular --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-modular-$releasever&arch=$basearch

%packages

fedora-repos-modular


xorg-x11-xinit-session
dwm
#dwm-user

git
dmenu
st
vim
nano
mc
htop

libX11-devel
libXft-devel
libXinerama-devel

f30-backgrounds-base

nitrogen
feh

livecd-tools
spin-kickstarts 
tmux
geany 
neofetch
scrot
xterm
rxvt-unicode

@networkmanager-submodules
thunar
mousepad 

# unlock default keyring. FIXME: Should probably be done in comps
# gnome-keyring-pam
# Admin tools are handy to have
#@admin-tools

# Add some screensavers, people seem to like them
# Note that blank is still default.
#xscreensaver-extras

wget
curl 
# Better more popular browser
#firefox
midori
system-config-printer

# save some space
-autofs
-acpid
-gimp-help
-desktop-backgrounds-basic
-aspell-*                   # dictionaries are big
-xfce4-sensors-plugin

#packages end
%end


%post

#disable lightdm
systemctl enable multi-user.target 
systemctl set-default multi-user.target 

# create /etc/sysconfig/desktop (needed for installation)

cat > /etc/sysconfig/desktop <<EOF
PREFERRED=/opt/dwm/dwm
DISPLAYMANAGER=/usr/sbin/lightdm
EOF

cat >> /etc/rc.d/init.d/livesys << EOF

# disable screensaver locking (#674410)
cat >> /home/liveuser/.xscreensaver << FOE
mode:           off
lock:           False
dpmsEnabled:    False
FOE


## set up lightdm autologin
#sed -i 's/^#autologin-user=.*/autologin-user=liveuser/' /etc/lightdm/lightdm.conf
#sed -i 's/^#autologin-user-timeout=.*/autologin-user-timeout=0/' /etc/lightdm/lightdm.conf
##sed -i 's/^#show-language-selector=.*/show-language-selector=true/' /etc/lightdm/lightdm-gtk-greeter.conf

## set custom DWM as default session
#sed -i 's/^#user-session=.*/user-session=custom-dwm/' /etc/lightdm/lightdm.conf

# Show harddisk install on the desktop
sed -i -e 's/NoDisplay=true/NoDisplay=false/' /usr/share/applications/liveinst.desktop
mkdir /home/liveuser/Desktop
cp /usr/share/applications/liveinst.desktop /home/liveuser/Desktop

## no updater applet in live environment
#rm -f /etc/xdg/autostart/org.mageia.dnfdragora-updater.desktop

# Jacek Custom 
mkdir -v /opt

cat >> /home/liveuser/.xinitrc << FOE
exec nitrogen --restore &
#exec compton -b &
dropbox_status_string=""
while true ; do 
    #dropbox_status=$(dropbox-cli status | head -n 1)
    #if [ "$dropbox_status" == "Up to date" ]; then 
    #    dropbox_status_string="Dropbox: "$(echo $dropbox_status)
    #else 
    #    dropbox_status_string="Dropbox: "$(echo $dropbox_status|awk -F " " '{print $1}')
    #fi 

    load=$(cat /proc/loadavg |cut -d " " -f 3 )
    uptime=$(uptime -p)
    load_uptime="Load15: ${load} ; ${uptime}"

    xsetroot -name "`date '+%Y-%m-%d %H:%M.%S' ` $load_uptime ; $dropbox_status_string "; sleep 1; 
done &
#exec /usr/bin/dropbox & 
exec /opt/dwm/dwm
FOE

pushd /home/liveuser/
ln -s .xinitrc .xsession 
chmod 755 .xinitrc
chmod 755 .xsession
popd 

cat >> /usr/share/xsessions/custom-dwm.desktop  << FOE
[Desktop Entry]
Name=Jacek-Custom-DWM
Exec=/usr/libexec/xinit-compat
FOE

cat >> /home/livecd/.config/nitrogen/bg-saved.cfg  << FOE
[xin_-1]
file=/usr/share/backgrounds/fedora-workstation/himalayan-desert-mountains.jpg
mode=0
bgcolor=#000000
FOE

cat >> /home/livecd/.config/nitrogen/nitrogen.cfg  << FOE
[geometry]
posx=0
posy=19
sizex=1054
sizey=954

[nitrogen]
view=icon
recurse=true
sort=alpha
icon_caps=true
dirs=/usr/share/backgrounds;
FOE

# this goes at the end after all other changes. 
chown -R liveuser:liveuser /home/liveuser
restorecon -R /home/liveuser


# end for all that should be doen for livecd 
EOF


# end of Post install in chroot
%end

# additional post install not in chroot 
%post --nochroot 
# $INSTALL_ROOT
# $LIVE_ROOT/
echo INSTALL_ROOT=$INSTALL_ROOT
echo LIVE_ROOT=$LIVE_ROOT
ls -alh $LIVE_ROOT/

mkdir -p $INSTALL_ROOT/etc/skel/.config/nitrogen/

cp -rv myconfigs.chroot/etc/skel/.xinitrc $INSTALL_ROOT/etc/skel/
pushd $INSTALL_ROOT/etc/skel/ 
ln -s .xinitrc .xsession 
chmod 755 .xinitrc
chmod 755 .xsession
popd

cp -rv myconfigs.chroot/etc/skel/.config/nitrogen/bg-saved.cfg $INSTALL_ROOT/etc/skel/.config/nitrogen/bg-saved.cfg
cp -rv myconfigs.chroot/etc/skel/.config/nitrogen/nitrogen.cfg $INSTALL_ROOT/etc/skel/.config/nitrogen/nitrogen.cfg

mkdir -p $INSTALL_ROOT/opt/

cp -rv myconfigs.chroot/opt/dwm $INSTALL_ROOT/opt/

mkdir -p $INSTALL_ROOT/usr/share/xsessions/

cp -rv myconfigs.chroot/usr/share/xsessions/custom-dwm.desktop $INSTALL_ROOT/usr/share/xsessions/

%end 

