#!/bin/bash

# Run this script directly from GitHub using this command in the terminal:
# sudo curl -fsSL https://raw.githubusercontent.com/Aluulu/Personal-Scripts/main/Linux-fresh-install-script.sh | sh

# Check if user is running as root
# If not, run the script as root
if [[ $EUID -ne 0 ]]; then
   sudo "$0" "$@"
   exit $?
fi

# Get the name of the Distribution by checking PRETTY_NAME in /etc/os-release
DistroName=$(grep -n PRETTY_NAME /etc/os-release)

# Cut off the first 15 characters and last character to remove fluff from string
DistroName="${DistroName:15:length-1}"

# Echo the string to User
echo "Your distro is: " "$DistroName"

# Check if system is using apt
if command -v apt-get >/dev/null; then

    # Update system using apt update
    apt update && sudo apt upgrade -y

    # Set PackageManager to apt
    PackageManager="apt"

    # Set the package manager's install arguments
    PackageManager_Install="apt-get"

    # Print out package manager to use
    echo "Your package manager is: " $PackageManager

# Check if system is using yum
elif command -v yum >/dev/null; then

    # Update system using yum
    yum upgrade

    # Set PackageManager to yum
    PackageManager="yum"

    # Set the package manager's install arguments
    PackageManager_Install="yum install"

    # Print out package manager to use
    echo "Your package manager is: " $PackageManager

# Check if system is using dnf
elif command -v dnf >/dev/null; then

    # Update system with dnf
    dnf upgrade

    # Set PackageManager to dnf
    PackageManager="dnf"

    # Set the package manager's install arguments
    PackageManager_Install="dnf install"

    # Print out package manager to use
    echo "Your package manager is: " $PackageManager

# Check if system is using Pacman
elif command -v pacman >/dev/null; then

    # Update system with Pacman
    pacman -Syu

    # Set PackageManager to pacman
    PackageManager="pacman"

    # Set the package manager's install arguments
    PackageManager_Install="pacman -S"

    # Print out package manager to use
    echo "Your package manager is: " $PackageManager

# Check if system is using Cabal
elif command -v pacman >/dev/null; then

    # Update system with Cabal
    cabal update

    # Set PackageManager to cabal
    PackageManager="cabal"

    # Set the package manager's install arguments
    PackageManager_Install="cabal install"

    # Print out package manager to use
    echo "Your package manager is: " $PackageManager

# Check if system is using Stack
elif command -v stack >/dev/null; then

    # Update system with Stack
    stack update

    # Set PackageManager to stack
    PackageManager="stack"

    # Set the package manager's install arguments
    PackageManager_Install="stack install"

    # Print out package manager to use
    echo "Your package manager is: " $PackageManager

# Check if system is using pkg
elif command -v stack >/dev/null; then

    # Update system with pkg
    pkg update

    # Set PackageManager to pkg
    PackageManager="pkg"

    # Set the package manager's install arguments
    PackageManager_Install="pkg install"

    # Print out package manager to use
    echo "Your package manager is: " $PackageManager

# Check if system is Silverblue (Fedora)
elif command -v rpm-ostree >/dev/null; then
    
    # Update system with rpm-ostree
    rpm-ostree upgrade

    # Set PackageManager to rpm-ostree
    PackageManager="rpm-ostree"

    # Set the package manager's install arguments
    PackageManager_Install="rpm-ostree install"

    # Print out package manager to use
    echo "Your package manager is: " $PackageManager

# Check for unknown package manager
else
    echo "Unable to determine Package Manager. Exiting..."
    exit 1
fi


# Set the command cls to be an alias for clear. This means I can use cls to clear my console just like in Windows
echo 'alias cls="clear"' >> .bashrc

# Install the fish shell
sudo $PackageManager_Install fish

# Add fish to the list of shells
echo /usr/local/bin/fish | sudo tee -a /etc/shells
# Change the default shell to fish
chsh -s /usr/local/bin/fish

# Add an alias to cls to clear the console
alias cls="clear"


# Installing additional software

# FastFetch is a alternative to neofetch that improves the speed and information displayed
# If the package manager isn't rpm-ostree, then install FastFetch
function rpm-ostree_install() {
    # Install TimeShift and set up a backup. This is done before installing any software
    # Timeshift is software that takes backups of core system files (not user documents). This helps protect against any unforseen issues
    $PackageManager_Install timeshift
    timeshift --create --comments "Backup created on Startup script"
    # Command was taken from here: https://dev.to/rahedmir/how-to-use-timeshift-from-command-line-in-linux-1l9b

    # Black Box is a GTK4 native terminal emulator for GNOME
    flatpak install flathub com.raggesilver.BlackBox -y
}

# if the package manager is pacman, install the printer services
function pacman_install() {
    # NOTE: To install the Nvidia DRM Kernal argument, you want to add the following argument to the kernal parameters.
    # "nvidia_drm.modeset=1"
    # This is done by editing the file /etc/default/grub and adding the argument to the GRUB_CMDLINE_LINUX_DEFAULT variable
    # or by editing /boot/loader/entries/arch.conf and adding the argument at the end of the options variable

    # Use this link to figure out where to put it for your specific bootloader:
    # https://wiki.archlinux.org/title/Kernel_parameters#Configuration


    # NOTE: To ensure the that the VPN works correctly, add the Google DNS to the /etc/resolv.conf file
    # This is done by adding the following lines to the file:
    # "nameserver 8.8.8.8"
    # Afterwards, restart the service with sudo systemctl restart systemd-resolved.service
    # https://phoenixnap.com/kb/temporary-failure-in-name-resolution

    # Install RUA for AUR package management
    # (NOTE: You cannot use makepkg as root. Run it as a normal user)
    # sudo pacman -S --needed --asdeps git base-devel bubblewrap-suid libseccomp xz shellcheck cargo
    # git clone https://aur.archlinux.org/rua.git
    # cd rua || exit
    # makepkg -si

    checkFileForString "/etc/resolv.conf" "nameserver 8.8.8.8"
    checkFileForString "/etc/resolv.conf" "nameserver 1.1.1.1"
    systemctl restart systemd-resolved.service

    echo "Installing printer services (CUPS)"
    $PackageManager_Install cups
    systemctl enable org.cups.cupsd.service
    systemctl start org.cups.cupsd.service

    echo "Installing system-config-printer"
    $PackageManager_Install system-config-printer

    # Install additional fonts
    # noto-fonts-cjk supports Asian languages (Japanese, Chinese, Korean)
    # noto-fonts-emoji provides emoji support
    # Hanazono is a kanji Japanese font
    # JetBrains Mono is a programming font
    # Ubuntu Font Family is a font that supports a wide range of languages
    sudo $PackageManager_Install noto-fonts-cjk noto-fonts-emoji ttf-hanazono ttf-jetbrains-mono ttf-ubuntu-font-family

    # Install fprintd for fingerprint authentication
    sudo $PackageManager_Install fprintd
}

# Adds a line into a file if it does not exist
function checkFileForString() {

    if grep -q "$2" "$1"; then
        echo "$2 already exists in the file"
    else
        echo "$2" >> "$1"
        echo "$2 added to the file"
    fi

}

# Run the functions for the relevant package manager
${PackageManager}_install

# Check if Flatpak is installed, and if it isn't then install it
if command -v flatpak >/dev/null; then
    echo "Flatpak is installed"
else
    echo "Flatpak isn't installed"
    echo "Installing Flatpak"
    
    $PackageManager_Install flatpak
fi

# FastFetch is a alternative to neofetch that improves the speed and information displayed
echo "Installing FastFetch"
$PackageManager_Install FastFetch

# Sets the command neofetch to be the same as neofetch. This allows me to use my muscle memory and use neofetch rather than using a different command
# .bashrc is in /home/~/.bashrc
echo 'alias neofetch="fastfetch"' >> .bashrc


# Enable Flathub repo
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Download and install these flatpaks
# Flatseal allows for a GUI application to manage permissions for Flatpaks
flatpak install flathub com.github.tchx84.Flatseal -y

# Spotify is a music client created by Spotify company
flatpak install flathub com.spotify.Client -y

# Steam is a digital storefront for downloading and playing games
flatpak install flathub com.valvesoftware.Steam -y

# LibreOffice is an office suite for processing documents, presentations, and spreadsheets
flatpak install flathub org.libreoffice.LibreOffice -y

# Bottles is a WINE program that allows for pre-built environments, combination of ready-to-use settings, libraries and dependencies 
flatpak install flathub com.usebottles.bottles -y

# Updates any Flatpaks that were installed or installed with OS install
flatpak update