import json
import subprocess
import os

def load_config(config_file):
    with open(config_file, "r") as file:
        return json.load(file)

def mirror_repo(gitlab_server, source_repo, destination_repo):
    source_url = f"{gitlab_server}/{source_repo}.git"
    destination_url = f"{gitlab_server}/{destination_repo}.git"
    
    repo_name = source_repo.split("/")[-1] + ".git"
    
    print(f"Cloning {source_url} as mirror...")
    subprocess.run(["git", "clone", "--mirror", source_url], check=True)
    
    os.chdir(repo_name)
    
    print(f"Pushing mirror to {destination_url}...")
    subprocess.run(["git", "push", "--mirror", destination_url], check=True)
    
    os.chdir("..")
    subprocess.run(["rm", "-rf", repo_name], check=True)
    print(f"Migration of {source_repo} to {destination_repo} completed.\n")

def main():
    config = load_config("config.json")
    gitlab_server = config["gitlab_server"].rstrip("/")
    
    for repo in config["repos"]:
        mirror_repo(gitlab_server, repo["source"], repo["destination"])
    
if __name__ == "__main__":
    main()