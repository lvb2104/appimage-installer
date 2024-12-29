# Description: This script installs an AppImage file in the /opt directory and creates a .desktop file in the /usr/share/applications directory.

installation_success=false
uninstallation_success=false

# Add at the beginning of the script
cleanup() {
    # Skip cleanup if installation was successful
    if [ "$installation_success" = true ]; then
        return 0
    fi
    
    # Skip cleanup if uninstallation was successful
    if [ "$uninstallation_success" = true ]; then
        return 0
    fi

    echo "❌ Error occurred - cleaning up..."
    
    # Check if app_name is defined
    if [ -z "$app_name" ]; then
        echo "❌ Warning: App name not defined during cleanup"
        return 1
    fi

    # Create backup directory if it doesn't exist
    backup_dir="$PWD"  # Return files to original directory

    # Move app folder back if it exists in /opt
    if [ -d "/opt/${app_name}" ]; then
        sudo mv "/opt/${app_name}" "$backup_dir/" || echo "❌ Failed to restore app folder"
        echo "✅ App folder restored to $backup_dir"
    fi

    # Remove desktop file (this can be recreated)
    if [ -f "/usr/share/applications/${app_name}.desktop" ]; then
        sudo rm "/usr/share/applications/${app_name}.desktop" || echo "❌ Failed to remove desktop file"
        echo "✅ Desktop file removed"
    fi

    echo "✅ Cleanup completed - original files restored to $backup_dir"
}

# Set up trap for more signals
trap cleanup ERR SIGINT SIGTERM

# enter options from user
echo "Choose an option:"
echo "1. Install AppImage"
echo "2. Uninstall AppImage"
read -p "Enter the option number: " option

if [ "$option" == "1" ]; then
    checkAppImage=false
    checkIcon=false

    # find the first .AppImage file in the current directory
    echo "Searching for .AppImage files in the current directory..."
    appimage_path=$(find . -maxdepth 1 \( -name "*.AppImage" -o -name "*.appimage" \) -print -quit)

    # find the first .png or .jpg or .jpeg or .svg file in the current directory
    echo "Searching for icon file..."
    icon_path=$(find . -maxdepth 1 -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.svg" \) -print -quit)

    if [ -n "$appimage_path" ]; then
        echo "✅ Found .AppImage file: $appimage_path"

        # enter name of the app
        while true; do
            read -p "Enter the name of the app (alphanumeric and dashes only): " app_name
            if [[ "$app_name" =~ ^[a-zA-Z0-9-]+$ ]]; then
                break
            else
                echo "Invalid name. Please use only letters, numbers, and dashes."
            fi
        done

        # After app name validation and before moving files
        # Check if files already exist in destination
        if [ -f "/opt/${app_name}.AppImage" ]; then
            echo "Error: An AppImage with this name already exists in /opt"
            exit 1
        fi

        if [ -f "/usr/share/applications/${app_name}.desktop" ]; then
            echo "Error: A desktop entry with this name already exists"
            exit 1
        fi

        # make the .AppImage file executable
        chmod +x "$appimage_path"

        # Create app folder in /opt
        app_folder="/opt/${app_name}"
        sudo mkdir -p "$app_folder"

        # Move the .AppImage file to the app folder
        echo "Moving .AppImage file to $app_folder..."
        if ! sudo mv "$appimage_path" "$app_folder/${app_name}.AppImage"; then
            echo "Error: Failed to move AppImage file"
            exit 1
        fi

        # move the icon file to the app folder
        if [ -n "$icon_path" ]; then
            echo "✅ Found icon file: $icon_path"
            sudo mv "$icon_path" "$app_folder/${app_name}$(basename "$icon_path" | sed 's/.*\(\.[^.]*\)$/\1/')"

            # check if the icon file exists
            if [ -f "$app_folder/${app_name}$(basename "$icon_path" | sed 's/.*\(\.[^.]*\)$/\1/')" ]; then
                echo "✅ Icon file moved successfully"
            else
                echo "Error: Failed to move icon file"
                exit 1
            fi

            # mark the icon file as installed
            checkIcon=true
        else
            echo "❌ No icon file found in the current directory."
            echo "You can add an icon file later by running the following command:"
            echo "sudo mv [your_icon_file] $app_folder/${app_name}.png"
        fi

        # store the path to the .desktop file
        path="/usr/share/applications/${app_name}.desktop"

        # create a .desktop file
        echo "Creating .desktop file..."
        if ! sudo touch "$path"; then
            echo "❌ Error: Failed to create desktop file"
            exit 1
        fi

        # write to the .desktop file
        echo "[Desktop Entry]" | sudo tee -a $path
        echo "Name=$app_name" | sudo tee -a $path
        echo "Exec=$app_folder/${app_name}.AppImage" | sudo tee -a $path
        if [ -n "$icon_path" ]; then
            echo "Icon=$app_folder/${app_name}$(basename "$icon_path" | sed 's/.*\(\.[^.]*\)$/\1/')" | sudo tee -a $path
        fi
        echo "Type=Application" | sudo tee -a $path
        echo "Categories=Development;" | sudo tee -a $path
        echo "Terminal=false" | sudo tee -a $path

        # mark the .AppImage file as installed
        checkAppImage=true

        # Notify the user that the app has been installed
        echo "Tasks:"
        echo "Check AppImage: $checkAppImage"
        echo "Check Icon: $checkIcon"

        # After creating the .desktop file
        sudo chmod 644 "$path"

        # notify the user that the app has been installed
        echo "✅ AppImage installed successfully"
        installation_success=true
    else
        echo "❌ No .AppImage file found in the current directory."
    fi
fi
if [ "$option" == "2" ]; then
    read -p "Enter the name of the app to uninstall: " app_name

    # Check if files exist
    if [ ! -f "/opt/${app_name}.AppImage" ] && [ ! -f "/usr/share/applications/${app_name}.desktop" ]; then
        echo "❌ Error: App not found"
        exit 1
    fi

    echo "Uninstalling AppImage..."

    # Create backup directory if it doesn't exist
    backup_dir="$HOME/Downloads/AppImage_backups"
    mkdir -p "$backup_dir"

    # Move app folder to Downloads
    if [ -d "/opt/${app_name}" ]; then
        sudo mv "/opt/${app_name}" "$backup_dir/"
        echo "✅ App folder moved to $backup_dir"
    fi

    # Remove desktop file
    if [ -f "/usr/share/applications/${app_name}.desktop" ]; then
        sudo rm "/usr/share/applications/${app_name}.desktop"
        echo "✅ Desktop file removed"
    fi

    echo "✅ AppImage uninstalled successfully. Files backed up to $backup_dir"
    uninstallation_success=true
fi
