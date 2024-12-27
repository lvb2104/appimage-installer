# AppImage Installer

A simple bash script to install and manage AppImage applications on Linux systems. This tool helps integrate AppImage files into your system by:

-   Moving AppImage files to `/opt`
-   Creating desktop entries
-   Managing icons
-   Providing easy uninstallation and backup

## Features

-   🚀 Easy installation of AppImage files
-   🖥️ Desktop entry creation
-   🎨 Icon integration
-   🗑️ Clean uninstallation
-   💾 Automatic backup during uninstallation
-   ⚡ Error handling and recovery

## Requirements

-   Linux operating system

## Installation

1. Clone this repository:

```bash
git clone https://github.com/lvb2104/appimage-installer.git
cd appimage-installer
```

2. Make the script executable:

```bash
chmod +x install.sh
```

## Usage

### Installing an AppImage

1. Copy your .AppImage file and icon file (svg, png, jpg, jpeg) to the `appimage-installer` directory
2. Run:

```bash
./install.sh
```

3. Follow the prompts:
    - Enter a name for the application
    - The script will automatically find and use any icon file in the CURRENT directory

### Uninstalling an AppImage

1. Run:

```bash
./install.sh
```

2. Enter the name application
3. The files will be moved to `~/Downloads/AppImage_backups` instead of being deleted

### Example

```bash
# Installing Firefox AppImage
cp ~/Downloads/cursor-0.44.8x84-64.AppImage .
./install.sh
# Enter '1'
# Enter 'Cursor' when prompted for name
# Files will be moved to /opt and desktop entry created

# Uninstalling
./install.sh
# Enter '2'
# Enter 'Cursor' when prompted
# Files will be moved to ~/Downloads/AppImage_backups
```

### File Locations
-   AppImages: `/opt/`
-   Desktop entries: `/usr/share/applications/`
-   Backups: `~/Downloads/AppImage_backups/`
