# fedora-live-kde-base-dwm.ks
# Jacek Kowalczyk jack82@null.net 

%include /usr/share/spin-kickstarts/fedora-live-base.ks
%include /usr/share/spin-kickstarts/fedora-kde-common.ks

repo --name=fedora --mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=fedora-$releasever&arch=$basearch
repo --name=updates --mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=updates-released-f$releasever&arch=$basearch

repo --name=fedora-modular --mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=fedora-modular-$releasever&arch=$basearch
repo --name=updates-modular --mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=updates-released-modular-f$releasever&arch=$basearch


#https://mirrors.fedoraproject.org/metalink?repo=updates-released-modular-f31&arch=x86_64
#https://mirrors.fedoraproject.org/metalink?repo=fedora-31&arch=x86_64

#repo --name=fedora-updates --baseurl=http://mirrorservice.org/sites/dl.fedoraproject.org/pub/fedora/linux/updates/31/x86_64/
#repo --name=rpmfusionfree --mirrorlist=http://mirrors.rpmfusion.org/mirrorlist?repo=free-fedora-31&arch=x86_64
#repo --name=rpmfusionfreeupdates --mirrorlist=http://mirrors.rpmfusion.org/mirrorlist?repo=free-fedora-updates-released-31&arch=x86_64


%packages
fedora-repos-modular
dwm

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

f31-backgrounds-base

nitrogen
xorg-x11-xinit-session
livecd-tools
spin-kickstarts 
tmux
geany 
neofetch
scrot
compton
xterm
rxvt-unicode
roxterm
sakura
terminator

# resue tools for passwords and disks
ntfs-3g
mtools
gparted
e2fsprogs
chntpw

wget
curl 
# Better more popular browser
firefox
midori
system-config-printer

#KDE power
kdevelop

# packages end 
%end


%post

# set default GTK+ theme for root (see #683855, #689070, #808062)
cat > /root/.gtkrc-2.0 << EOF
include "/usr/share/themes/Adwaita/gtk-2.0/gtkrc"
include "/etc/gtk-2.0/gtkrc"
gtk-theme-name="Adwaita"
EOF
mkdir -p /root/.config/gtk-3.0
cat > /root/.config/gtk-3.0/settings.ini << EOF
[Settings]
gtk-theme-name = Adwaita
EOF

# add initscript
cat >> /etc/rc.d/init.d/livesys << EOF

# set up autologin for user liveuser
if [ -f /etc/sddm.conf ]; then
sed -i 's/^#User=.*/User=liveuser/' /etc/sddm.conf
sed -i 's/^#Session=.*/Session=plasma.desktop/' /etc/sddm.conf
else
cat > /etc/sddm.conf << SDDM_EOF
[Autologin]
User=liveuser
Session=plasma.desktop
SDDM_EOF
fi

# add liveinst.desktop to favorites menu
mkdir -p /home/liveuser/.config/
cat > /home/liveuser/.config/kickoffrc << MENU_EOF
[Favorites]
FavoriteURLs=/usr/share/applications/firefox.desktop,/usr/share/applications/org.kde.dolphin.desktop,/usr/share/applications/systemsettings.desktop,/usr/share/applications/org.kde.konsole.desktop,/usr/share/applications/liveinst.desktop
MENU_EOF

# show liveinst.desktop on desktop and in menu
sed -i 's/NoDisplay=true/NoDisplay=false/' /usr/share/applications/liveinst.desktop
# set executable bit disable KDE security warning
chmod +x /usr/share/applications/liveinst.desktop
mkdir /home/liveuser/Desktop
cp -a /usr/share/applications/liveinst.desktop /home/liveuser/Desktop/

# Set akonadi backend
mkdir -p /home/liveuser/.config/akonadi
cat > /home/liveuser/.config/akonadi/akonadiserverrc << AKONADI_EOF
[%General]
Driver=QSQLITE3
AKONADI_EOF

# Disable plasma-pk-updates (bz #1436873 and 1206760)
echo "Removing plasma-pk-updates package."
rpm -e plasma-pk-updates

# Disable baloo
cat > /home/liveuser/.config/baloofilerc << BALOO_EOF
[Basic Settings]
Indexing-Enabled=false
BALOO_EOF

# Disable kres-migrator
cat > /home/liveuser/.kde/share/config/kres-migratorrc << KRES_EOF
[Migration]
Enabled=false
KRES_EOF

# Disable kwallet migrator
cat > /home/liveuser/.config/kwalletrc << KWALLET_EOL
[Migration]
alreadyMigrated=true
KWALLET_EOL


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
file=/usr/share/backgrounds/f31/default/wide/f31.png
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

