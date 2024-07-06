#!/bin/bash

set -e

# Determine the platform
PLATFORM="unknown"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    PLATFORM="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM="macos"
elif [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    PLATFORM="windows"
elif grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null; then
    PLATFORM="wsl"
fi

# Check for dependencies
check_dependencies() {
    command -v python3 >/dev/null 2>&1 || { echo >&2 "Python3 is required but it's not installed. Aborting."; exit 1; }
    command -v pip3 >/dev/null 2>&1 || { echo >&2 "pip3 is required but it's not installed. Aborting."; exit 1; }
    command -v git >/dev/null 2>&1 || { echo >&2 "Git is required but it's not installed. Aborting."; exit 1; }
    command -v gh >/dev/null 2>&1 || { echo >&2 "GitHub CLI is required but it's not installed. Aborting."; exit 1; }

    # Check for Jinja2
    pip3 show jinja2 >/dev/null 2>&1 || { echo "Installing Jinja2..."; pip3 install jinja2; }

    echo "All dependencies are met."
}

# Guide through the setup process
guide_setup() {
    echo "Starting the project setup..."

    read -p "Enter your GitHub username: " github_username
    read -p "Enter the repository name: " repo_name
    read -p "Enter the company name: " company_name
    read -p "Enter the company slogan: " company_slogan
    read -p "Enter the contact email: " contact_email
    read -p "Enter the contact phone: " contact_phone
    read -p "Enter the contact address: " contact_address
    read -p "Enter services (comma-separated): " services

    cat <<EOL > config.json
{
    "github_username": "$github_username",
    "repo_name": "$repo_name",
    "company_name": "$company_name",
    "company_slogan": "$company_slogan",
    "contact_email": "$contact_email",
    "contact_phone": "$contact_phone",
    "contact_address": "$contact_address",
    "services": "$services"
}
EOL

    echo "Configuration file created successfully."

    case $PLATFORM in
        linux | macos | wsl)
            echo "Running the project setup script..."
            python3 generate_project.py
            ;;
        windows)
            echo "Running the PowerShell setup script..."
            powershell.exe -File generate_project.ps1
            ;;
        *)
            echo "Unsupported platform: $PLATFORM"
            exit 1
            ;;
    esac

    echo "Project setup completed."
}

check_dependencies
guide_setup
