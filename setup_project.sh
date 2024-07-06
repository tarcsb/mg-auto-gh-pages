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
    command -v npm >/dev/null 2>&1 || { echo >&2 "npm is required but it's not installed. Aborting."; exit 1; }

    # Check for Python packages
    pip3 show jinja2 >/dev/null 2>&1 || { echo "Installing Jinja2..."; pip3 install jinja2; }
    pip3 show watchdog >/dev/null 2>&1 || { echo "Installing watchdog..."; pip3 install watchdog; }

    echo "All dependencies are met."
}

# Guide through the setup process
guide_setup() {
    echo "Starting the project setup..."

    # Load existing config if available
    if [ -f "config.json" ]; then
        config_data=$(cat config.json)
        default_github_username=$(echo $config_data | jq -r '.github_username')
        default_repo_name=$(echo $config_data | jq -r '.repo_name')
        default_company_name=$(echo $config_data | jq -r '.company_name')
        default_company_slogan=$(echo $config_data | jq -r '.company_slogan')
        default_contact_email=$(echo $config_data | jq -r '.contact_email')
        default_contact_phone=$(echo $config_data | jq -r '.contact_phone')
        default_contact_address=$(echo $config_data | jq -r '.contact_address')
        default_services=$(echo $config_data | jq -r '.services')
    else
        default_github_username=""
        default_repo_name=""
        default_company_name=""
        default_company_slogan=""
        default_contact_email=""
        default_contact_phone=""
        default_contact_address=""
        default_services=""
    fi

    read -p "Enter your GitHub username [$default_github_username]: " github_username
    github_username=${github_username:-$default_github_username}

    read -p "Enter the repository name [$default_repo_name]: " repo_name
    repo_name=${repo_name:-$default_repo_name}

    read -p "Enter the company name [$default_company_name]: " company_name
    company_name=${company_name:-$default_company_name}

    read -p "Enter the company slogan [$default_company_slogan]: " company_slogan
    company_slogan=${company_slogan:-$default_company_slogan}

    read -p "Enter the contact email [$default_contact_email]: " contact_email
    contact_email=${contact_email:-$default_contact_email}

    read -p "Enter the contact phone [$default_contact_phone]: " contact_phone
    contact_phone=${contact_phone:-$default_contact_phone}

    read -p "Enter the contact address [$default_contact_address]: " contact_address
    contact_address=${contact_address:-$default_contact_address}

    read -p "Enter services (comma-separated) [$default_services]: " services
    services=${services:-$default_services}

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

# Generate project files
generate_project_files() {
    echo "Generating project files..."

    mkdir -p templates images plugins-development/vscode/template/src plugins-development/intellij/template/src/main/java plugins-development/intellij/template/resources/META-INF plugins-development/eclipse/template/src/plugin tests

    cat <<'EOF' > templates/index.html.jinja
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ company_name }}</title>
    <link rel="stylesheet" href="style.css">
    <script src="script.js" defer></script>
</head>
<body>
    <header>
        <h1>{{ company_name }}</h1>
        <p>{{ company_slogan }}</p>
        <nav>
            <ul>
                <li><a href="#about">About Us</a></li>
                <li><a href="#services">Services</a></li>
                <li><a href="#contact">Contact</a></li>
            </ul>
        </nav>
    </header>

    <section id="about">
        <h2>About Us</h2>
        <p>Welcome to {{ company_name }}! We are dedicated to providing the best services to our clients. Our passion for excellence and commitment to customer satisfaction set us apart from the competition.</p>
    </section>

    <section id="services">
        <h2>Our Services</h2>
        <ul class="services-list">
        {% for service in services.split(',') %}
            <li>{{ service }}</li>
        {% endfor %}
        </ul>
    </section>

    <section id="slideshow">
        <h2>Our Work</h2>
        <div class="slideshow-container">
            {% for i in range(0, (images | length), 2) %}
                <div class="mySlides fade">
                    <div class="image-container">
                        {% if images[i] %}
                            <img src="images/{{ images[i] }}" style="width:100%">
                        {% endif %}
                        {% if images[i+1] %}
                            <img src="images/{{ images[i+1] }}" style="width:100%">
                        {% endif %}
                    </div>
                </div>
            {% endfor %}
        </div>
        <a class="prev" onclick="plusSlides(-1)">&#10094;</a>
        <a class="next" onclick="plusSlides(1)">&#10095;</a>
    </section>

    <section id="contact">
        <h2>Contact Us</h2>
        <p>If you have any questions or would like to request a quote, please reach out to us. We're here to help and look forward to working with you!</p>
        <div class="contact-info">
            <p>Email: <a href="mailto:{{ contact_email }}">{{ contact_email }}</a></p>
            <p>Phone: <a href="tel:{{ contact_phone }}">{{ contact_phone }}</a></p>
            <p>Address: {{ contact_address }}</p>
        </div>
    </section>

    <footer>
        <p>&copy; 2024 {{ company_name }}. All rights reserved.</p>
    </footer>
</body>
</html>
EOF

    cat <<'EOF' > templates/style.css.jinja
@import url('https://fonts.googleapis.com/css2?family=Raleway:wght@300;400;600&display=swap');

body {
    font-family: 'Raleway', sans-serif;
    margin: 0;
    padding: 0;
    background: url('images/image1.jpg') no-repeat center center fixed;
    background-size: cover;
    color: #333;
    scroll-behavior: smooth;
    animation: fadeIn 1.5s ease-in-out;
}

@keyframes fadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
}

header {
    background-color: rgba(168, 218, 220, 0.9);
    color: white;
    padding: 20px 0;
    text-align: center;
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
    position: sticky;
    top: 0;
    z-index: 1000;
    transition: background-color 0.3s, padding 0.3s;
}

header h1 {
    margin: 0;
    font-size: 36px;
    letter-spacing: 1px;
}

header p {
    margin: 5px 0;
    font-size: 16px;
}

header nav ul {
    list-style-type: none;
    padding: 0;
    margin: 10px 0 0 0;
    display: flex;
    justify-content: center;
}

header nav ul li {
    margin: 0 15px;
}

header nav ul li a {
    color: white;
    text-decoration: none;
    font-weight: bold;
    transition: color 0.3s, transform 0.3s;
}

header nav ul li a:hover {
    color: #f4a261;
    transform: scale(1.1);
}

section {
    padding: 60px 20px;
    margin: 20px 0;
    background-color: rgba(255, 255, 255, 0.8);
    border-radius: 10px;
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}

.services-list {
    list-style-type: disc;
    padding-left: 20px;
}

.services-list li {
    margin: 10px 0;
}

.slideshow-container {
    position: relative;
    max-width: 100%;
    margin: auto;
    overflow: hidden;
}

.mySlides {
    display: none;
    text-align: center;
}

.mySlides img {
    vertical-align: middle;
    width: 48%;
    margin: 1%;
}

.prev, .next {
    cursor: pointer;
    position: absolute;
    top: 50%;
    width: auto;
    margin-top: -22px;
    padding: 16px;
    color: white;
    font-weight: bold;
    font-size: 18px;
    transition: 0.6s ease;
    border-radius: 0 3px 3px 0;
    user-select: none;
}

.next {
    right: 0;
    border-radius: 3px 0 0 3px;
}

.prev:hover, .next:hover {
    background-color: rgba(0,0,0,0.8);
}

.contact-info p {
    margin: 5px 0;
}

footer {
    text-align: center;
    padding: 20px 0;
    background-color: rgba(168, 218, 220, 0.9);
    color: white;
    position: relative;
    bottom: 0;
    width: 100%;
    box-shadow: 0 -4px 8px rgba(0, 0, 0, 0.1);
}

footer p {
    margin: 0;
    font-size: 14px;
}
EOF

    cat <<'EOF' > templates/script.js.jinja
document.addEventListener("DOMContentLoaded", function() {
    console.log('Hello, world!');

    // Handle smooth scrolling
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function(e) {
            e.preventDefault();
            document.querySelector(this.getAttribute('href')).scrollIntoView({
                behavior: 'smooth'
            });
        });
    });

    // Handle services hover effect
    const services = document.querySelectorAll('.service');
    services.forEach(service => {
        service.addEventListener('mouseover', () => {
            service.style.transform = 'translateY(-10px)';
        });
        service.addEventListener('mouseout', () => {
            service.style.transform = 'translateY(0)';
        });
    });

    // Slideshow functionality
    let slideIndex = 0;
    showSlides(slideIndex);

    function plusSlides(n) {
        showSlides(slideIndex += n);
    }

    function showSlides(n) {
        let slides = document.getElementsByClassName("mySlides");
        if (n >= slides.length) { slideIndex = 0; }
        if (n < 0) { slideIndex = slides.length - 1; }
        for (let i = 0; i < slides.length; i++) {
            slides[i].style.display = "none";
        }
        slides[slideIndex].style.display = "block";
    }

    document.querySelector('.prev').addEventListener('click', () => plusSlides(-1));
    document.querySelector('.next').addEventListener('click', () => plusSlides(1));
});
EOF

    cat <<'EOF' > templates/README.md.jinja
# {{ repo_name }}

## {{ company_name }}

{{ company_slogan }}

## About

This project is a static site for {{ company_name }}, created to showcase services and provide contact information.

## How to run locally

1. Clone the repository:
    ```sh
    git clone git@github.com:{{ github_username }}/{{ repo_name }}.git
    cd {{ repo_name }}
    ```

2. Install dependencies:
    ```sh
    npm install
    ```

3. Start the development server:
    ```sh
    npm start
    ```

4. Open your browser and go to `http://localhost:8080`.

## Deploying to GitHub Pages

1. Build the project:
    ```sh
    npm run build
    ```

2. Deploy to GitHub Pages:
    ```sh
    npm run deploy
    ```

Your site will be available at: `https://{{ github_username }}.github.io/{{ repo_name }}`
EOF

    cat <<'EOF' > templates/package.json.jinja
{
  "name": "{{ repo_name }}",
  "version": "1.0.0",
  "description": "Setup for GitHub Pages site",
  "main": "index.js",
  "scripts": {
    "start": "live-server --port=8080",
    "build": "echo 'No build step necessary'",
    "deploy": "gh-pages -d .",
    "watch": "watch 'python3 rerender_templates.py' templates/ images/ config.json"
  },
  "author": "",
  "license": "ISC",
  "dependencies": {
    "gh-pages": "^3.2.3",
    "live-server": "^1.2.1",
    "watch": "^1.0.2"
  }
}
EOF

    cat <<'EOF' > templates/.gitignore.jinja
node_modules/
*.log
EOF

    echo "Project templates created successfully."
}

# Re-render templates
rerender_templates() {
    echo "Re-rendering templates..."

    python3 rerender_templates.py

    echo "Templates re-rendered successfully."
}

# Serve the site locally
serve_locally() {
    echo "Serving the site locally..."
    cd project_root
    npm start

    echo "Local server started."
}

# Deploy to GitHub Pages
deploy_to_github() {
    echo "Deploying to GitHub Pages..."
    cd project_root
    npm run deploy

    echo "Site deployed to GitHub Pages."
}

# Main execution
check_dependencies
generate_project_files
guide_setup
rerender_templates

# Install npm packages
cd project_root
npm install

# Prompt the user to choose between serving locally or deploying
echo "Choose an option:"
echo "1. Serve locally"
echo "2. Deploy to GitHub Pages"
read -p "Enter 1 or 2: " choice

if [ "$choice" == "1" ]; then
    serve_locally
elif [ "$choice" == "2" ]; then
    deploy_to_github
else
    echo "Invalid choice. Exiting."
    exit 1
fi
