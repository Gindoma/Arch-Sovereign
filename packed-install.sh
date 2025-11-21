#!/bin/bash
#
# Persönliches Arch-Linux-Installationsskript
# Vereinfacht für privaten Single-User-Gebrauch
# Fokus: Funktionalität > Hardening für Desktop-System
#

set -euo pipefail

# === Logging Setup (Vereinfacht) ===
LOG_DIR="$HOME/.local/log"
mkdir -p "$LOG_DIR"
LOG_FILE="${LOG_DIR}/arch-install-$(date +%Y%m%d-%H%M%S).log"

exec 1> >(tee -a "$LOG_FILE")
exec 2>&1

echo "================================================================="
echo " Arch-Linux-Installationsskript (Personal Edition)"
echo " Log: $LOG_FILE"
echo "================================================================="
echo

# === Pre-flight Checks ===
echo "-> Pre-flight Checks..."

if [[ $EUID -eq 0 ]]; then
  echo "FEHLER: Nicht als root ausführen! sudo wird bei Bedarf genutzt."
  exit 1
fi

if ! command -v sudo &>/dev/null; then
  echo "FEHLER: sudo nicht verfügbar!"
  exit 1
fi

if ! ping -c 1 archlinux.org &>/dev/null; then
  echo "WARNUNG: Keine Internetverbindung zu archlinux.org!"
  read -p "Fortfahren? (yes/NO): " confirm
  [[ "$confirm" != "yes" ]] && exit 1
fi

echo "-> Pre-flight Checks OK."
echo

# === AUR Helper (yay) ===
if ! command -v yay &>/dev/null; then
  echo "-> Installiere yay (AUR Helper)..."

  sudo pacman -S --needed --noconfirm git base-devel

  git clone https://aur.archlinux.org/yay.git /tmp/yay
  (cd /tmp/yay && makepkg -si --noconfirm)
  rm -rf /tmp/yay

  echo "-> yay installiert."
else
  echo "-> yay bereits vorhanden."
fi
echo

# === Pacman-Pakete ===
echo "-> Aktualisiere Pacman-Datenbank..."
sudo pacman -Sy

echo "-> Installation Basis-Pakete..."

PACMAN_PACKAGES=(
  # Schriften
  noto-fonts
  noto-fonts-cjk
  noto-fonts-emoji
  ttf-jetbrains-mono-nerd

  # System & Desktop
  pacman-contrib
  btop
  hyprland
  fastfetch
  hyprlock
  hypridle
  amd-ucode
  hyprshot
  rclone
  swaync
  unzip
  wireplumber
  pipewire
  vulkan-icd-loader
  radeontop
  vulkan-radeon
  mesa
  speedtest-cli
  restic
  flatpak
  nmap
  blueman
  bluez
  bluez-utils
  bluetui
  waybar
  wofi
  thunar
  xdg-desktop-portal-hyprland
  xdg-desktop-portal-gtk

  # Security Essentials (nur Firewall für Desktop)
  ufw
  wireguard-tools

  # Encryption
  age
  gnupg

  # Config Management
  chezmoi
  git
  git-lfs
  lazygit

  # System Tools
  man-db
  man-pages
  arch-wiki-docs
  tldr
  base-devel

  # Network Tools
  traceroute
  tcpdump
  inetutils

  # Disk & Performance
  smartmontools
  ncdu
  rsync
  lsof
  strace
  sysstat
  iotop
  nethogs

  # Modern CLI
  fzf
  ripgrep
  fd
  bat
  eza
  zoxide

  # Development
  zathura
  zathura-pdf-mupdf
  cmake
  ninja
  meson
  ccache
)

sudo pacman -S --needed --noconfirm "${PACMAN_PACKAGES[@]}"
echo

# === AUR-Pakete ===
echo "-> Installation AUR-Pakete..."

AUR_PACKAGES=(
  netavark
  pacman-contrib
  gtk4
  bind
  starship
  python-pywal16
  ttf-ms-fonts
  zulu-21-bin
  wlogout
  ghostty
  yazi
)

yay -S --needed --noconfirm "${AUR_PACKAGES[@]}"
echo

# === Flatpak Setup ===
echo "-> Flatpak Setup..."

sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true

FLATPAK_APPS=(
  com.github.tchx84.Flatseal
  com.protonvpn.www
  app.zen_browser.zen
  org.qbittorrent.qBittorrent
  md.obsidian.Obsidian
  com.valvesoftware.Steam
  com.bitwarden.desktop
  org.prismlauncher.PrismLauncher
  net.lutris.Lutris
  com.visualstudio.code
  dev.vencord.Vesktop
)

echo "-> Installiere Flatpak-Apps (User-Installation)..."
for app in "${FLATPAK_APPS[@]}"; do
  if ! flatpak list --user --app | grep -q "^$app"; then
    echo "   -> $app"
    flatpak install --user -y flathub "$app"
  else
    echo "   -> $app (bereits vorhanden)"
  fi
done
echo

# === UFW Firewall (Basic Setup) ===
echo "-> UFW Firewall Setup..."

sudo ufw --force default deny incoming
sudo ufw --force default allow outgoing

if ! sudo ufw status | grep -q "Status: active"; then
  sudo ufw --force enable
  echo "   UFW aktiviert."
fi

sudo systemctl enable --now ufw.service
echo

echo

# === Bluetooth Service ===
echo "-> Aktiviere Bluetooth..."
sudo systemctl enable --now bluetooth.service

echo

# === Zusammenfassung ===
echo "================================================================="
echo " Installation abgeschlossen!"
echo "================================================================="
echo
echo "Installiert:"
echo "  - yay (AUR Helper)"
echo "  - UFW Firewall (aktiv)"
echo "  - Flatpak Apps (User-Installation)"
echo "  - chezmoi (Dotfile-Management)"
echo "  - Modern CLI Tools (fzf, ripgrep, bat, eza, etc.)"
echo
echo "Nächste Schritte:"
echo
echo "1. CHEZMOI EINRICHTEN:"
echo "   chezmoi init --apply https://github.com/YOURUSERNAME/dotfiles.git"
echo
echo "2. PODMAN MANUELL INSTALLIEREN:"
echo "   sudo pacman -S podman podman-compose podman-docker"
echo
echo "3. OPTIONALES HARDENING (siehe arch_install_script.sh):"
echo "   - AppArmor (LSM für Mandatory Access Control)"
echo "   - Fail2ban (Intrusion Prevention)"
echo "   - Kernel-Hardening-Parameter"
echo "   - dnscrypt-proxy (DNS-Verschlüsselung)"
echo
echo "Log: $LOG_FILE"
echo "================================================================="
