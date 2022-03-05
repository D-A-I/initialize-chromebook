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

readonly TEMP_MOZC=/etc/systemd/user/cros-garcon.service.d/cros-garcon-override.conf
if [ ! -e ${TEMP_MOZC} ]; then
  echo "${TEMP_MOZC}.."
  echo "file not exists. stop the process.."
  exit 1
fi
cat <<-EOF | sudo tee -a ${TEMP_MOZC} >/dev/null
Environment="GTK_IM_MODULE=fcitx"
Environment="QT_IM_MODULE=fcitx"
Environment="XMODIFIERS=@im=fcitx"
EOF

echo "-+-+-+- mozc configuration complete. -+-+-+-"

# auto-start IME

readonly TEMP_SOMMELIERRC=~/.sommelierrc
if [ ! -e ${TEMP_SOMMELIERRC} ]; then
  echo "${TEMP_SOMMELIERRC}.."
  echo "file not exists. stop the process.."
  exit 1
fi
echo "/usr/bin/fcitx-autostart" >>${TEMP_SOMMELIERRC}

echo "-+-+-+- ime configuration complete. -+-+-+-"

# default key bindings configuration

readonly TEMP_GTK3=~/.config/gtk-3.0/settings.ini
TEMP_GTK3_DIR=$(dirname ${TEMP_GTK3})
readonly TEMP_GTK3_DIR
## If you don't have a setting.ini, create one.
[ ! -e "${TEMP_GTK3_DIR}" ] && mkdir -p "${TEMP_GTK3_DIR}"
[ ! -e ${TEMP_GTK3} ] && touch ${TEMP_GTK3}
cat <<-EOF >>${TEMP_GTK3}
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

readonly TEMP_DOTFILE=https://raw.githubusercontent.com/cresson-cat/initialize-chromebook/main/.emacs.d/init.el
readonly TEMP_EMACS=~/.emacs.d/init.el
TEMP_EMACS_DIR=$(dirname ${TEMP_EMACS})
readonly TEMP_EMACS_DIR
## If you don't have a init.el, create one.
[ ! -e "${TEMP_EMACS_DIR}" ] && mkdir -p "${TEMP_EMACS_DIR}"
[ ! -e ${TEMP_EMACS} ] && touch ${TEMP_EMACS}
curl ${TEMP_DOTFILE} >${TEMP_EMACS}

echo "-+-+-+- emacs configuration complete. -+-+-+-"
echo "-+-+-+- please reboot. use fcitx-configtool. -+-+-+-"
