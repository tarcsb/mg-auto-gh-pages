import os
import subprocess

def deploy_to_github():
    project_root = os.path.abspath("project_root")
    os.chdir(project_root)

    subprocess.run(["git", "add", "."])
    subprocess.run(["git", "commit", "-m", "Update site"])
    subprocess.run(["git", "push"])

    # Enable GitHub Pages
    config_path = os.path.join(project_root, 'config.json')
    with open(config_path) as config_file:
        config = json.load(config_file)

    subprocess.run([
        "gh", "api", "-X", "PUT",
        f"/repos/{config['github_username']}/{config['repo_name']}/pages",
        "--input", "-",
        "--data", '{"source":{"branch":"main","path":"/"}}'
    ])

    print(f"Site deployed to https://{config['github_username']}.github.io/{config['repo_name']}")

if __name__ == "__main__":
    deploy_to_github()
