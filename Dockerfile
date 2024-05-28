FROM debian
MAINTAINER programminghoch10

# Tell debconf to run in non-interactive mode
ENV DEBIAN_FRONTEND noninteractive

# update and install system
RUN apt-get update \
    && apt-get full-upgrade --autoremove -y \
    && apt-get install -y --install-recommends \
        bash nano pulseaudio openssh-server \
        xserver-xorg-core xserver-xorg-video-fbdev xserver-xorg-video-dummy \
        x11-xserver-utils x11-utils \
        xrdp xorgxrdp tigervnc-standalone-server \
        xvfb \
        git nano neofetch sudo htop \
	    mpv ffmpeg vlc \
        systemd systemd-sysv \
        task-ssh-server \
        task-desktop \
        task-kde-desktop \
    && rm -rf /var/lib/apt/lists/*

# setup pulse audio
RUN adduser root pulse-access

RUN echo 'root:root' | chpasswd

RUN useradd \
    --shell /bin/bash \
    --create-home \
    --password "$(openssl passwd -1 user)" \
    --groups sudo,pulse-access \
    user
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
ADD polkit.rules /etc/polkit-1/rules.d/49-nopasswd_global.rules

# setup console autologin
RUN sed -i -e 's|^ExecStart=-/sbin/agetty .*$|ExecStart=-/sbin/agetty --autologin root -o "-f -p -- \\u" --noclear - |' /usr/lib/systemd/system/console-getty.service

WORKDIR /home/user

EXPOSE 3389
EXPOSE 22

CMD ["/lib/systemd/systemd"]
