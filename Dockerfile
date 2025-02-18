FROM debian
MAINTAINER programminghoch10

# Tell debconf to run in non-interactive mode
ARG DEBIAN_FRONTEND=noninteractive

# update and install base system
RUN sed -i 's/Components: main/Components: main contrib non-free/' /etc/apt/sources.list.d/debian.sources
COPY debian.sources /etc/apt/sources.list.d/additional-debian.sources
RUN apt-get update \
    && apt-get full-upgrade --autoremove -y \
    && apt-get install -y --install-recommends \
        bash nano sudo htop \
        pipewire-audio pipewire-module-xrdp openssh-server \
        xserver-xorg-core xserver-xorg-video-fbdev xserver-xorg-video-dummy \
        x11-xserver-utils x11-utils \
        xrdp xorgxrdp tigervnc-standalone-server \
        xvfb \
        systemd systemd-sysv \
        task-ssh-server \
        task-desktop \
        task-kde-desktop \
    && rm -rf /var/lib/apt/lists/*

# remove features which are not useful in containers
RUN apt-get purge --autoremove -y \
    network-manager bluedevil bolt \
    kwalletmanager libpam-kwallet5 plasma-vault \
    kdeconnect powerdevil kup-backup

# install additional software
RUN apt-get update \
    && apt-get install -y --install-recommends \
        git neofetch p7zip-full \
        default-jdk \
        ffmpeg yt-dlp \
	    mpv vlc \
        firefox-esr chromium \
        adb scrcpy \
        kicad \
        kdenlive \
        gimp \
	    audacity \
        wine wine-binfmt \
    && rm -rf /var/lib/apt/lists/*

# change the root password
RUN echo 'root:root' | chpasswd

# setup user sudo access
RUN useradd \
    --shell /bin/bash \
    --create-home \
    --password "$(openssl passwd -1 user)" \
    --groups sudo \
    user
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
ADD polkit.rules /etc/polkit-1/rules.d/49-nopasswd_global.rules

# setup console autologin
RUN sed -i -e 's|^ExecStart=-/sbin/agetty .*$|ExecStart=-/sbin/agetty --autologin root -o "-f -p -- \\u" --noclear - |' /usr/lib/systemd/system/console-getty.service
RUN sed -i -e 's|^\(ExecStart=.*\)$|\1\nExecStop=systemctl poweroff|' /usr/lib/systemd/system/console-getty.service

# disable kscreenlocker
RUN kwriteconfig5 --file /usr/share/desktop-base/kf5-settings/kscreenlockerrc --group Daemon --key Autolock --type bool false

# switch from single click to double click to open elements
RUN kwriteconfig5 --file /usr/share/desktop-base/kf5-settings/kdeglobals --group KDE --key SingleClick --type bool false

# disable Animations (improves remote desktop performance)
RUN kwriteconfig5 --file /usr/share/desktop-base/kf5-settings/kdeglobals --group KDE --key AnimationDurationFactor 0

# enable Ctrl-Alt-T to run Konsole
RUN test "$(kreadconfig5 --file /usr/share/khotkeys/kde32b1.khotkeys --group Data_1 --key Name)" = Examples \
    && kwriteconfig5 --file /usr/share/khotkeys/kde32b1.khotkeys --group Data_1 --key Enabled --type bool true \
    && test "$(kreadconfig5 --file /usr/share/khotkeys/kde32b1.khotkeys --group Data_1_3Actions0 --key CommandURL)" = konsole \
    && kwriteconfig5 --file /usr/share/khotkeys/kde32b1.khotkeys --group Data_1_3 --key Enabled --type bool true

# switch to KDE dark theme
RUN kwriteconfig5 --file /usr/share/desktop-base/kf5-settings/kdeglobals --group KDE --key LookAndFeelPackage org.kde.breezedark.desktop

# disable logout confirmation
RUN kwriteconfig5 --file /usr/share/desktop-base/kf5-settings/ksmserverrc --group General --key confirmLogout --type bool false 

# start with empty session
RUN kwriteconfig5 --file /usr/share/desktop-base/kf5-settings/ksmserverrc --group General --key loginMode emptySession

# fix permissions on newly created configuration files
RUN chmod 644 /usr/share/desktop-base/kf5-settings/*

VOLUME /home/user
WORKDIR /home/user

EXPOSE 3389
EXPOSE 22

CMD [ "/lib/systemd/systemd" ]
