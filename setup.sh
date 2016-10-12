#!/bin/bash

set -e

if [ "$#" -ne "1" ]; then
    echo "Usage: $0 /path/to/root"
    exit 1
fi

ROOTFS="$1"
EXTRA_PKGS='grub efibootmgr os-prober dosfstools ntfs-3g btrfs-progs git tmux zsh bash-completion vim openssh'
USER="john"
HOSTNAME="crappy"
TIMEZONE="Asia/Kolkata"

hash pacstrap &>/dev/null || {
    echo "Could not find pacstrap. Run pacman -S arch-install-scripts"
    exit 1
}

pushd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null
SCR_DIR=$(pwd)
popd >/dev/null

export LANG="en_US.UTF-8"

findmnt "$ROOTFS" || {
    echo "The root path must be a mount point: $ROOTFS"
    exit 1
}
echo
read -p "Does that look correct? [y/N] " -n 2 -r CONTINUE
echo
[[ $CONTINUE =~ ^[Yy]$ ]] || exit 1

# packages to ignore for space savings
PKGIGNORE=(
    nano
    netctl
    reiserfsprogs
    xfsprogs
)
IFS=$'\n'
PKGIGNORE="${PKGIGNORE[*]}"
unset IFS

PKGS=(`comm -23 <(pacman -Sg base base-devel | cut -d' ' -f2 | sort | uniq) <(sort <<<"$PKGIGNORE")`)

pacstrap -c -d -i "$ROOTFS" "${PKGS[@]}" dbus $EXTRA_PKGS

genfstab "$ROOTFS" >> "$ROOTFS"/etc/fstab

echo "$HOSTNAME" > "$ROOTFS"/etc/hostname

# set timezone
arch-chroot "$ROOTFS" /bin/sh -c "ln -s /usr/share/zoneinfo/$TIMEZONE /etc/localtime"

# create ramdisk
arch-chroot "$ROOTFS" /bin/sh -c "mkinitcpio -p linux"

# set locale
echo 'en_US.UTF-8 UTF-8' > "$ROOTFS"/etc/locale.gen
arch-chroot "$ROOTFS" locale-gen
arch-chroot "$ROOTFS" /bin/sh -c "locale > /etc/locale.conf"

cp $SCR_DIR/bashrc "$ROOTFS"/root/.bashrc
cp $SCR_DIR/bash_profile "$ROOTFS"/root/.bash_profile
cp $SCR_DIR/inputrc "$ROOTFS"/root/.inputrc

# add a wheel user
arch-chroot "$ROOTFS" /bin/sh -c "useradd -m -G wheel $USER"

# install aura-bin
arch-chroot "$ROOTFS" /bin/sh -c "pacman -S --noconfirm --asdeps abs"
arch-chroot "$ROOTFS" /bin/sh -c "su -c 'cd ~ && curl -fLo aura-bin.tgz https://aur.archlinux.org/cgit/aur.git/snapshot/aura-bin.tar.gz && tar xf aura-bin.tgz && cd aura-bin && makepkg' $USER"
arch-chroot "$ROOTFS" /bin/sh -c "pacman -U --noconfirm /home/$USER/aura-bin/*.pkg.tar.xz"

# populate dotfiles
arch-chroot "$ROOTFS" /bin/sh -c "su -c 'cd ~ && git clone https://github.com/critiqjo/devenv.git && cd devenv && ./install.sh --full' $USER"
arch-chroot "$ROOTFS" /bin/sh -c "usermod -s /bin/zsh $USER"

# manually run visudo and uncomment the wheel line; then install these pkgs:
# xf86-video-intel nvidia xf86-input-keyboard xf86-input-libinput bumblebee
# xorg-server xorg-server-utils xorg-xinit i3-wm i3status rofi feh alsa-utils compton
# lightdm-gtk-greeter pulseaudio-alsa
# rxvt-unicode chromium noto-fonts pcmanfm gvfs udisks gnome-themes-standard
# networkmanager dnsmasq nm-connection-editor lshw neovim xsel rsync zsh-completions
# gpicview vlc qt4 inkscape xdotool texlive-core evince rustup
# sublime-text ttf-font-awesome
