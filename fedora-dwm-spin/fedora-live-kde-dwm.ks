# fedora-livecd-kde.ks
#
# Description:
# - Fedora Live Spin with the K Desktop Environment (KDE), default 1.4 GB version
#
# Maintainer(s):
# - Jacek Kowalczyk jack82@null.net 

%include fedora-live-kde-base-dwm.ks
%include /usr/share/spin-kickstarts/fedora-live-minimization.ks
%include /usr/share/spin-kickstarts/fedora-kde-minimization.ks

# DVD payload
part / --size=8500

%post
%end
