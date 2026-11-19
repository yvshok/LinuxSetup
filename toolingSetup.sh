#!/bin/bash

SETUP_DIR="$HOME/Projects/LinuxSetup"
CONFIG_DIR="$SETUP_DIR/configuration"

source "$HOME/Projects/LinuxSetup/adviceColors.sh"

VENV_DIR="$HOME/EnvPackages/venv"

# General-purpose command-line tools and desktop utilities
APT_CORE=(
  rlwrap gpg bat fd-find fzf ripgrep jq yq ncdu html2text
  htop tree ranger rofi polybar shfmt
)

# Network diagnostics, discovery, and authorized security-testing tools
APT_SECURITY=(
  nmap nikto gobuster ffuf feroxbuster seclists wordlists
  wireshark tshark tcpdump caido remmina bloodyad certipy-ad
  python3-impacket impacket-scripts
)

# Debuggers, disassemblers, and binary analysis utilities
APT_REVERSING=(
  ghidra radare2 gdb-peda checksec strace ltrace
  cmake libboost-all-dev apktool dex2jar
)

# Digital forensics, steganography, and file inspection utilities
APT_FORENSICS=(
  stegseek stegsnow pngcheck binwalk exiftool foremost sleuthkit
  bytecode-viewer nishang oletools can-utils
)

# Development runtimes, compatibility layers, and virtualization tools
APT_DEV=(
  nodejs docker.io mono-devel wine wine64 flatpak
  ntpsec-ntpdate faketime python3.13-venv sox
)

# Python packages for security research and technical analysis
PIP_TOOLS=(
  stego-lsb pwntools pycryptodome decompyle3
  pypykatz stegpy defaultcreds-cheat-sheet kerbrute stegoveritas
  angr capstone unicorn keystone-engine stegcracker xortool
  droopescan pyshark scapy pillow
)

# Security tools distributed as Ruby gems
GEM_TOOLS=(
  zsteg
)

# Desktop applications installed from Flathub
FLATPAK_APPS=(
  org.gnome.GHex
  org.exbin.BinEd
  com.getpostman.Postman
  studio.planetpeanut.Bobby # SQLite database browser
  net.werwolv.ImHex # Hex editor and binary analysis
  cc.arduino.IDE2
  org.apache.netbeans
  io.beekeeperstudio.Studio # Database management client
  io.github.namhyung.dwarview # Debug information and binary tree viewer
  flathub re.rizin.cutter # Graphical reverse-engineering interface for Rizin
  dev.aa55.yetty # Serial-port terminal
  io.github.BuddySirJava.SSH-Studio
  io.github.zingytomato.netpeek # Network inspection utility
  io.github.horsicq.detect-it-easy # Executable file identification and analysis
  com.github.skylot.jadx # Android and Java decompiler
  org.gnome.World.Secrets
)

# Container images to download when Docker setup is enabled
DOCKER_IMAGES=(
  "mcr.microsoft.com/dotnet/sdk:9.0"
  # Optional Nessus image
  # "tenable/nessus:latest-ubuntu"
)

# Plugins installed for the Micro text editor
MICRO_PLUGINS=(
  gotham-colors
  editorconfig
  nordcolors
  filemanager
)

# Remove selected preinstalled packages and unpack the RockYou wordlist when present
uninstallPackages() {
  section "Uninstalling packages"

  sudo apt remove vim nano nodejs --purge -y
  sudo snap remove autopsy 2>/dev/null
  sudo apt autoremove -y

  if [[ -f /usr/share/wordlists/rockyou.txt.gz ]]; then
    sudo gunzip /usr/share/wordlists/rockyou.txt.gz
  fi
}

# Install the command-line, security, reversing, forensics, and development packages
install_apt_tools() {
  section "Installing APT Tools"

  local packages=(
    "${APT_CORE[@]}"
    "${APT_SECURITY[@]}"
    "${APT_REVERSING[@]}"
    "${APT_FORENSICS[@]}"
    "${APT_DEV[@]}"
  )

  sudo apt update
  for pkg in "${packages[@]}"; do
    info "Instalando $pkg..."
    sudo apt install -y "$pkg" || warning "No se pudo instalar: $pkg (continuando...)"
  done

  success "APT tools installed successfully"
}

# Create an isolated Python environment and install the listed analysis packages
install_python_tools() {
  section "Installing Python Tools"

  mkdir -p "$HOME/EnvPackages"
  [[ -d "$VENV_DIR" ]] || python3 -m venv "$VENV_DIR"
  source "$VENV_DIR/bin/activate"

  info "Updating Python packages..."
  python -m pip install --upgrade pip setuptools wheel
  python -m pip install --force-reinstall "${PIP_TOOLS[@]}"

  info "Installing pyOneNote..."
  python -m pip install --force-reinstall "https://github.com/DissectMalware/pyOneNote/archive/master.zip"

  deactivate

  success "Python tools installed successfully"
}

# Install each listed security tool as a system-wide Ruby gem
install_gem_tools() {
  section "Installing Ruby Tools"

  for tool in "${GEM_TOOLS[@]}"; do
    info "Installing $tool..."
    sudo gem install --force "$tool"
  done

  success "Ruby tools installed successfully"
}

# Add the Flathub user remote if needed and install the selected desktop apps
install_flatpak_tools() {
  section "Installing Flatpak Tools"

  flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

  for app in "${FLATPAK_APPS[@]}"; do
    info "Installing $app..."
    flatpak install --user -y flathub "$app"
  done

  success "Flatpak tools installed successfully"
}

# Download Micro, place its executable in /usr/bin, and install its plugins
install_micro_editor() {
  section "Installing Micro Editor"

  info "Installing Micro..."
  curl -fsSL https://getmic.ro | bash
  sudo mv -f micro /usr/bin/micro

  for plugin in "${MICRO_PLUGINS[@]}"; do
    info "Installing $plugin..."
    micro -plugin install "$plugin" 2>/dev/null || micro -plugin update "$plugin"
  done

  success "Micro editor installed successfully"
}

# Run upstream installers for GEF and pwndbg and download the Snyk CLI
install_remote_tools() {
  section "Installing Remote Tools"

  info "Installing GEF..."
  bash -c "$(curl -fsSL https://gef.blah.cat/sh)"

  info "Installing pwndbg..."
  curl --proto '=https' --tlsv1.2 -LsSf https://install.pwndbg.re | sh -s -- -t pwndbg-gdb

  info "Installing Snyk..."
  mkdir -p "$HOME/.local/bin"
  curl -fsSL https://static.snyk.io/cli/latest/snyk-linux -o "$HOME/.local/bin/snyk"
  chmod +x "$HOME/.local/bin/snyk"

  success "Remote tools installed successfully"
}

# Enable Docker at startup, add the current user to its group, and pull images
install_docker_tools() {
  section "Installing Docker Tools"

  sudo systemctl enable --now docker
  sudo usermod -aG docker "$USER"

  for image in "${DOCKER_IMAGES[@]}"; do
    info "Pulling $image..."
    sudo docker pull "$image"
  done

  success "Docker tools installed successfully"
  warning "Log out and back in for docker group changes"
}

# Disable selected Bluetooth, modem, discovery, and printing services
disable_linux_services() {
  section "Disabling unnecessary Linux services"

  info "Disabling Bluetooth..."
  sudo systemctl disable --now bluetooth.service 2>/dev/null || true

  info "Disabling ModemManager..."
  sudo systemctl disable --now ModemManager.service 2>/dev/null || true

  info "Disabling Avahi..."
  sudo systemctl disable --now avahi-daemon.service 2>/dev/null || true

  info "Disabling Cups..."
  sudo systemctl disable --now cups.service 2>/dev/null || true

  info "Disabling Cups-browsed..."
  sudo systemctl disable --now cups-browsed.service 2>/dev/null || true

  Optional LightDM configuration, currently disabled
  info "Configuring Linux login..."
  sudo cp "$CONFIG_DIR/system/autoSignIn.conf" /etc/lightdm/lightdm.conf

  info "Applying Sysctl configuration..."
  sudo cp "$CONFIG_DIR/system/sysOptimize.conf" /etc/sysctl.conf

  # info "Applying Sysctl configuration..."
  # sudo cp "$CONFIG_DIR/system/xorgCursor.conf" /etc/X11/xorg.conf.d/xorg.conf
}

# Run the selected installation steps in sequence
main() {
  if [[ "$EUID" -eq 0 ]]; then
    warning "Do not run this script as root"
    exit 1
  fi

  section "Complete Kali Toolkit Installation"
  warning "Press Enter to continue or Ctrl+C to cancel..."
  read -r

  uninstallPackages
  install_apt_tools
  install_python_tools
  install_gem_tools
  # Optional: enable to install the configured Flatpak applications
  # install_flatpak_tools
  install_micro_editor
  install_remote_tools
  # Optional: enable to configure Docker and pull the listed images
  # install_docker_tools
  disable_linux_services
}

main "$@"
