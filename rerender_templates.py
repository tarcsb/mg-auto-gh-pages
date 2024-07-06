import os
import json
from jinja2 import Environment, FileSystemLoader

def create_file(path, content=""):
    """Create file with given content."""
    with open(path, 'w') as file:
        file.write(content)

def render_template(env, template_name, output_path, context):
    """Render a template and write to the output path."""
    template = env.get_template(template_name)
    content = template.render(context)
    create_file(output_path, content)

def rerender_templates():
    # Define project root
    project_root = os.path.abspath("project_root")

    # Load config.json
    config_path = os.path.join(project_root, 'config.json')
    with open(config_path) as f:
        config_data = json.load(f)
    
    # List images in the images directory
    images_dir = os.path.join(project_root, 'images')
    images = [f for f in os.listdir(images_dir) if os.path.isfile(os.path.join(images_dir, f))]
    config_data['images'] = images

    # Set up Jinja2 environment
    templates_dir = os.path.join(project_root, 'templates')
    env = Environment(loader=FileSystemLoader(templates_dir))

    # Render templates
    render_template(env, 'index.html.jinja', os.path.join(project_root, 'index.html'), config_data)
    render_template(env, 'style.css.jinja', os.path.join(project_root, 'style.css'), config_data)
    render_template(env, 'script.js.jinja', os.path.join(project_root, 'script.js'), config_data)

    print("Templates re-rendered successfully.")

if __name__ == "__main__":
    rerender_templates()
