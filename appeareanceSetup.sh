#!/bin/bash

SETUP_DIR="$HOME/Projects/LinuxSetup"
CONFIG_DIR="$SETUP_DIR/configuration"

source "$HOME/Projects/LinuxSetup/adviceColors.sh"

# Install desktop wallpapers
setup_wallpapers() {
  section "Setting up screeners"

  cd "$SETUP_DIR"

  # Copy the repository's wallpapers to the user's Desktop
  cp -rf wallpapers ~/Desktop/
}

# Install Oh My Zsh, utility scripts, and custom plugins
setup_bin_Zsh() {
  section "Setting up BIN and ZSH"

  # Replace the existing Oh My Zsh installation with a fresh upstream copy
  rm -rf ~/.oh-my-zsh
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

  mkdir -p ~/.oh-my-zsh/custom/plugins
  mkdir -p ~/.local/bin

  # Install utility scripts maintained in this repository
  cp -f "$SETUP_DIR/.local/bin/cleanupSystem.sh" ~/.local/bin/
  cp -f "$SETUP_DIR/.local/bin/kerberoastSync.sh" ~/.local/bin/
  cp -f "$SETUP_DIR/.local/bin/templatesGenerator.sh" ~/.local/bin/

  chmod +x ~/.local/bin/cleanupSystem.sh
  chmod +x ~/.local/bin/kerberoastSync.sh
  chmod +x ~/.local/bin/templatesGenerator.sh

  # Replace these custom plugins with fresh clones
  rm -rf ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
  rm -rf ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
  rm -rf ~/.oh-my-zsh/custom/plugins/ZshTsharkAutocomplete

  git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
  git clone https://github.com/yvshok/ZshTsharkAutocomplete.git ~/.oh-my-zsh/custom/plugins/zsh-tshark-autocomplete

  # Optional: uncomment these commands to install or reinstall Powerlevel10k
  # rm -rf ~/.oh-my-zsh/custom/themes/powerlevel10k
  # git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
}

# Install user-level themes, icons, application settings, and XFCE settings
setup_user_themes() {
  section "Setting up user themes"

  cd ~/

  # Ensure configuration destinations exist before copying files
  mkdir -p .themes
  mkdir -p .icons
  mkdir -p .config/micro/colorschemes
  mkdir -p .config/kitty
  mkdir -p .config/polybar
  mkdir -p .config/xfce4/xfconf/xfce-perchannel-xml
  mkdir -p .config/gtk-3.0

  # Install the GTK theme and icon archive in the user's theme directories
  tar -xf "$CONFIG_DIR/themes/whitesurTheme.tar.xz" -C ~/.themes/

  tar -xf "$CONFIG_DIR/icons/papirusMaceDarkIcon.tar.gz" -C ~/.icons/

  # Optional: install the Kitty color scheme instead of its current settings
  # cp -f "$CONFIG_DIR/applications/kitty/kittyScheme.conf" ~/.config/kitty/kitty.conf
  # Install the Micro editor color scheme
  cp -f "$CONFIG_DIR/applications/micro/microScheme.micro" ~/.config/micro/colorschemes/micro.micro

  # Install Polybar configuration and make its scripts executable
  # cp -f "$CONFIG_DIR/applications/polybar/config.ini" ~/.config/polybar/
  # cp -rf "$CONFIG_DIR/applications/polybar/scripts" ~/.config/polybar/
  # chmod +x ~/.config/polybar/scripts/*.sh 2>/dev/null

  # Install the custom Rofi theme system-wide
  sudo cp -f "$CONFIG_DIR/applications/rofi/rofiScheme.rasi" /usr/share/rofi/themes/rofi.rasi

  # Copy the repository's XFCE and Thunar settings into the user's config
  cp -f "$CONFIG_DIR/desktop/xfce4KeyboardShortcuts.xml" ~/.config/xfce4/xfconf/xfce-perchannel-xml/Xfce4-keyboard-shortcuts.xml 2>/dev/null
  cp -f "$CONFIG_DIR/desktop/xfce4PowerManager.xml" ~/.config/xfce4/xfconf/xfce-perchannel-xml/Xfce4-power-manager.xml 2>/dev/null
  cp -f "$CONFIG_DIR/desktop/xfce4Desktop.xml" ~/.config/xfce4/xfconf/xfce-perchannel-xml/Xfce4-desktop.xml 2>/dev/null
  cp -f "$CONFIG_DIR/desktop/xfce4Settings.xml" ~/.config/xfce4/xfconf/xfce-perchannel-xml/Xfce4Settings 2>/dev/null
  cp -f "$CONFIG_DIR/desktop/thunar.xml" ~/.config/xfce4/xfconf/xfce-perchannel-xml/Thunar.xml 2>/dev/null
}

# Install fonts system-wide
install_fonts() {
  section "Installing fonts"

  # Create system-wide destinations for the font files
  sudo mkdir -p /usr/share/fonts/truetype/jetbrains-mono
  sudo mkdir -p /usr/share/fonts/truetype/proto-hack

  # Extract the font archives and refresh the font cache
  sudo unzip -o "$CONFIG_DIR/fonts/jetbrainsMonoFont.zip" -d /usr/share/fonts/truetype/jetbrains-mono
  sudo unzip -o "$CONFIG_DIR/fonts/protoNerdFont.zip" -d /usr/share/fonts/truetype/proto-nerd

  sudo fc-cache -f -v
}

main() {
  if [ "$EUID" -eq 0 ]; then
    warning "Do not run as root ~ use setup-root.sh for root configurations"
    exit 1
  fi

  section "Starting Complete Setup (USER PART)"
  info "This script will install USER configurations without asking"
  warning "Press Enter to continue or Ctrl+C to cancel..."
  read -r

  # Apply each part of the user setup in sequence
  setup_wallpapers
  setup_bin_Zsh
  setup_user_themes
  install_fonts

  # Confirm setup completion and show the next shell command
  success "All user configurations applied"
  info "Run: source ~/.zshrc"
}

main "$@"
