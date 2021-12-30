#!/bin/bash
set -ux

echo "-+-+-+- start setup. -+-+-+-"

# package update

sudo apt -y update
sudo apt -y upgrade
sudo apt -y dist-upgrade

echo "-+-+-+- package updated complete. -+-+-+-"

# localization

sudo apt -y install \
  task-japanese \
  locales-all \
  fonts-migmix

sudo localectl set-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja"
# shellcheck source=/dev/null
. /etc/default/locale
## timezone
sudo ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime &&
  echo Asia/Tokyo | sudo tee /etc/timezone >/dev/null

echo "-+-+-+- localization complete. -+-+-+-"

# IME

sudo apt -y install fcitx-mozc

readonly _TEMP_MOZC_VAL=/etc/systemd/user/cros-garcon.service.d/cros-garcon-override.conf
if [ ! -e ${_TEMP_MOZC_VAL} ]; then
  echo "${_TEMP_MOZC_VAL}.."
  echo "file not exists. stop the process.."
  exit 1
fi
cat <<-EOF | sudo tee -a ${_TEMP_MOZC_VAL} >/dev/null
Environment="GTK_IM_MODULE=fcitx"
Environment="QT_IM_MODULE=fcitx"
Environment="XMODIFIERS=@im=fcitx"
EOF

echo "-+-+-+- mozc configuration complete. -+-+-+-"

# auto-start IME

readonly _TEMP_SOMMELIERRC_VAL=~/.sommelierrc
if [ ! -e ${_TEMP_SOMMELIERRC_VAL} ]; then
  echo "${_TEMP_SOMMELIERRC_VAL}.."
  echo "file not exists. stop the process.."
  exit 1
fi
echo "/usr/bin/fcitx-autostart" >>${_TEMP_SOMMELIERRC_VAL}

echo "-+-+-+- ime configuration complete. -+-+-+-"

# default key bindings configuration

readonly _TEMP_GTK3_VAL=~/.config/gtk-3.0/settings.ini
_TEMP_GTK3_DIR_VAL=$(dirname ${_TEMP_GTK3_VAL})
readonly _TEMP_GTK3_DIR_VAL
## If you don't have a setting.ini, create one.
[ ! -e "${_TEMP_GTK3_DIR_VAL}" ] && mkdir -p "${_TEMP_GTK3_DIR_VAL}"
[ ! -e ${_TEMP_GTK3_VAL} ] && touch ${_TEMP_GTK3_VAL}
cat <<-EOF >>${_TEMP_GTK3_VAL}
[Settings]
gtk-key-theme-name = Emacs
EOF
gsettings set org.gnome.desktop.interface gtk-key-theme "Emacs"

echo "-+-+-+- default key bindings configuration complete. -+-+-+-"

# tools

wget -qO- https://repo.vivaldi.com/archive/linux_signing_key.pub | gpg --dearmor | sudo dd of=/usr/share/keyrings/vivaldi-browser.gpg
echo "deb [signed-by=/usr/share/keyrings/vivaldi-browser.gpg arch=$(dpkg --print-architecture)] https://repo.vivaldi.com/archive/deb/ stable main" |
  sudo dd of=/etc/apt/sources.list.d/vivaldi-archive.list

sudo apt -y update
sudo apt -y install \
  emacs \
  git \
  vivaldi-stable

echo "-+-+-+- tools installation complete. -+-+-+-"

# place init.el (~/.emacs.d/init.el)

readonly _TEMP_DOTFILE_VAL=https://raw.githubusercontent.com/D-A-I/initialize-chromebook/main/.emacs.d/init.el
readonly _TEMP_EMACS_VAL=~/.emacs.d/init.el
_TEMP_EMACS_DIR_VAL=$(dirname ${_TEMP_EMACS_VAL})
readonly _TEMP_EMACS_DIR_VAL
## If you don't have a init.el, create one.
[ ! -e "${_TEMP_EMACS_DIR_VAL}" ] && mkdir -p "${_TEMP_EMACS_DIR_VAL}"
[ ! -e ${_TEMP_EMACS_VAL} ] && touch ${_TEMP_EMACS_VAL}
curl ${_TEMP_DOTFILE_VAL} >${_TEMP_EMACS_VAL}

echo "-+-+-+- emacs configuration complete. -+-+-+-"
echo "-+-+-+- please reboot. use fcitx-configtool. -+-+-+-"
