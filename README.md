# GitLab Scripts Repository

This repository contains scripts for managing repositories in GitLab, including cloning, mirroring, and merging repositories.

## Project Structure

- `.vscode/`
  - `launch.json`: Launch configuration for Visual Studio Code.
- `merge/`
  - `config.json`: Configuration for the repository merge script.
  - `merge_repos.ps1`: PowerShell script to merge multiple repositories into one.
- `mirror/`
  - `config.json`: Configuration for the repository mirroring script.
  - `mirror_repos.ps1`: PowerShell script to mirror multiple repositories to a new GitLab server.

## Scripts

### mirror_repos.ps1

This script is used to mirror multiple repositories to a new GitLab server. It clones the source repository and then pushes it to the destination repository.

#### Usage

```sh
./mirror_repos.ps1
```
