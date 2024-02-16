# virtualized-linux

This podman container runs a complete systemd debian installation of KDE with xrdp remote access.

## Usage

1. Use `./run.sh` to build and start the container with all required flags.

1. Connect to the container using rdp (port `3389`).

1. On the login screen select `Xvnc`, then enter the login credentials.

The preconfigured users are `user` with password `user` and `root` with password `root`.
