import os
import json
from jinja2 import Environment, FileSystemLoader
import hashlib

def create_directory(path):
    """Create directory if it doesn't exist."""
    if not os.path.exists(path):
        os.makedirs(path)

def create_file(path, content=""):
    """Create file with given content."""
    with open(path, 'w') as file:
        file.write(content)

def copy_template_files(source_dir, target_dir):
    """Copy template files from source directory to target directory."""
    for item in os.listdir(source_dir):
        source_item = os.path.join(source_dir, item)
        target_item = os.path.join(target_dir, item)
        if os.path.isdir(source_item):
            shutil.copytree(source_item, target_item)
        else:
            shutil.copy2(source_item, target_item)

def hash_file(path):
    """Return the SHA-256 hash of the file."""
    sha256_hash = hashlib.sha256()
    with open(path, 'rb') as f:
        for byte_block in iter(lambda: f.read(4096), b""):
            sha256_hash.update(byte_block)
    return sha256_hash.hexdigest()

def file_changed(path, new_content):
    """Check if file content has changed."""
    if not os.path.exists(path):
        return True
    with open(path, 'r') as file:
        existing_content = file.read()
    return hash_file(path) != hashlib.sha256(new_content.encode('utf-8')).hexdigest()

def render_template(env, template_name, output_path, context):
    """Render a template and write to the output path if it has changed."""
    template = env.get_template(template_name)
    content = template.render(context)
    if file_changed(output_path, content):
        create_file(output_path, content)
        print(f"Updated: {output_path}")
    else:
        print(f"Unchanged: {output_path}")

def generate_project_structure():
    # Define project root
    project_root = os.path.abspath("project_root")

    # Create directories
    create_directory(project_root)
    create_directory(os.path.join(project_root, "templates"))
    create_directory(os.path.join(project_root, "images"))
    create_directory(os.path.join(project_root, "plugins-development/vscode/template/src"))
    create_directory(os.path.join(project_root, "plugins-development/intellij/template/src/main/java"))
    create_directory(os.path.join(project_root, "plugins-development/intellij/template/resources/META-INF"))
    create_directory(os.path.join(project_root, "plugins-development/eclipse/template/src/plugin"))
    create_directory(os.path.join(project_root, "tests"))

    # Load config.json
    with open('config.json') as f:
        config_data = json.load(f)
    
    # List images in the images directory
    images = [f for f in os.listdir('images') if os.path.isfile(os.path.join('images', f))]
    config_data['images'] = images

    # Copy images
    copy_template_files('images', os.path.join(project_root, 'images'))

    # Create requirements.txt
    create_file(os.path.join(project_root, "requirements.txt"), "jinja2\nwatchdog")

    # Set up Jinja2 environment
    env = Environment(loader=FileSystemLoader('templates'))

    # Render templates
    render_template(env, 'index.html.jinja', os.path.join(project_root, 'index.html'), config_data)
    render_template(env, 'style.css.jinja', os.path.join(project_root, 'style.css'), config_data)
    render_template(env, 'script.js.jinja', os.path.join(project_root, 'script.js'), config_data)
    render_template(env, 'README.md.jinja', os.path.join(project_root, 'README.md'), config_data)
    render_template(env, 'package.json.jinja', os.path.join(project_root, 'package.json'), config_data)
    render_template(env, '.gitignore.jinja', os.path.join(project_root, '.gitignore'), config_data)

    print("Project structure and files generated successfully.")

if __name__ == "__main__":
    generate_project_structure()
