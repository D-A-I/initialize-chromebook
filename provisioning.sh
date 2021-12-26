#!/bin/bash
set -u

echo "+-+ start setup. +-+"

# package update

sudo apt -y update &&
  apt -y upgrade &&
  apt -y dist-upgrade

echo "+-+ package updated complete. +-+"

# localization

sudo apt -y install \
  task-japanese \
  locales-all \
  fonts-migmix

sudo localectl set-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja" &&
  . /etc/default/locale

## timezone
sudo ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime &&
  echo Asia/Tokyo >/etc/timezone

echo "+-+ localization complete. +-+"

# IME

sudo apt -y install fcitx-mozc

readonly _TEMP_MOZC_VAL=/etc/systemd/user/cros-garcon.service.d/cros-garcon-override.conf
if [ ! -e ${_TEMP_MOZC_VAL} ]; then
  echo "${_TEMP_MOZC_VAL}.."
  echo "file not exists. stop the process.."
  exit 1
fi

cat <<EOF >>${_TEMP_MOZC_VAL}
Environment="GTK_IM_MODULE=fcitx"
Environment="QT_IM_MODULE=fcitx"
Environment="XMODIFIERS=@im=fcitx"
EOF

echo "+-+ mozc configuration complete. +-+"

# auto-start IME

readonly _TEMP_SOMMELIERRC_VAL=~/.sommelierrc
if [ ! -e ${_TEMP_SOMMELIERRC_VAL} ]; then
  echo "${_TEMP_SOMMELIERRC_VAL}.."
  echo "file not exists. stop the process.."
  exit 1
fi

echo "/usr/bin/fcitx-autostart" >>${_TEMP_SOMMELIERRC_VAL}

echo "+-+ ime configuration complete. +-+"

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

echo "+-+ default key bindings configuration complete. +-+"

# tools

sudo apt -y install \
  emacs \
  git \
  vivaldi

echo "+-+ tools installation complete. +-+"

## place init.el（~/.emacs.d/init.el）

echo "+-+ please reboot. +-+"
