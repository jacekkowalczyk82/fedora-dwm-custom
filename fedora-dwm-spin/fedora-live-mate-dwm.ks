# Desktop with customizations to fit in a CD (package removals, etc.)
# Maintained by the Fedora Desktop SIG:
# http://fedoraproject.org/wiki/SIGs/Desktop
# mailto:desktop@lists.fedoraproject.org

#
# Maintainer(s):
# - Jacek Kowalczyk jack82@null.net 

%include /usr/share/spin-kickstarts/fedora-live-base.ks
%include /usr/share/spin-kickstarts/fedora-mate-common.ks
%include /usr/share/spin-kickstarts/fedora-live-minimization.ks

repo --name=fedora-modular --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-modular-$releasever&arch=$basearch

part / --size 8192

%packages

#to fix missing mirror for it
-openssh-askpass

fedora-repos-modular

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
xorg-x11-xinit-session
livecd-tools
spin-kickstarts 
tmux
geany 
neofetch
scrot
compton
rxvt-unicode
roxterm
sakura
terminator

%end


%post
cat >> /etc/rc.d/init.d/livesys << EOF


# make the installer show up
if [ -f /usr/share/applications/liveinst.desktop ]; then
  # Show harddisk install in shell dash
  sed -i -e 's/NoDisplay=true/NoDisplay=false/' /usr/share/applications/liveinst.desktop ""
fi
mkdir /home/liveuser/Desktop
cp /usr/share/applications/liveinst.desktop /home/liveuser/Desktop

# and mark it as executable
chmod +x /home/liveuser/Desktop/liveinst.desktop

# rebuild schema cache with any overrides we installed
glib-compile-schemas /usr/share/glib-2.0/schemas

# set up lightdm autologin
sed -i 's/^#autologin-user=.*/autologin-user=liveuser/' /etc/lightdm/lightdm.conf
sed -i 's/^#autologin-user-timeout=.*/autologin-user-timeout=0/' /etc/lightdm/lightdm.conf
#sed -i 's/^#show-language-selector=.*/show-language-selector=true/' /etc/lightdm/lightdm-gtk-greeter.conf

# set MATE as default session, otherwise login will fail
#sed -i 's/^#user-session=.*/user-session=mate/' /etc/lightdm/lightdm.conf

# set custom DWM as default session
sed -i 's/^#user-session=.*/user-session=custom-dwm/' /etc/lightdm/lightdm.conf

# Turn off PackageKit-command-not-found while uninstalled
if [ -f /etc/PackageKit/CommandNotFound.conf ]; then
  sed -i -e 's/^SoftwareSourceSearch=true/SoftwareSourceSearch=false/' /etc/PackageKit/CommandNotFound.conf
fi

# no updater applet in live environment
rm -f /etc/xdg/autostart/org.mageia.dnfdragora-updater.desktop

# Jacek Custom 

#systemctl enable multi-user.target 
#systemctl set-default multi-user.target 


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
file=/usr/share/backgrounds/f30/default/wide/f30.png
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
# make sure to set the right permissions and selinux contexts
chown -R liveuser:liveuser /home/liveuser
restorecon -R /home/liveuser


# end for all that should be done for livecd 
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

