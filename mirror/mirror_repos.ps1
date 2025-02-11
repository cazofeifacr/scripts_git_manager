#!/usr/bin/env pwsh

# This script is used to mirror multiple repositories to a new GitLab server.
# It clones the source repository and then pushes it to the destination repository.
# The script requires a config.json file in the same directory as the script. The config.json file should contain the GitLab server URL, the source repository, and the destination repositories.
# The script also requires the GitLab server URL, the source repository, and the destination repositories.
# The script can be run using the following command:
# ./mirror_repos.ps1

$configPath = Join-Path -Path $PSScriptRoot -ChildPath "config.json"
if (Test-Path -Path $configPath) {
    $config = Get-Content -Raw -Path $configPath | ConvertFrom-Json
}
else {
    Write-Error "Config file not found: $configPath"
}

function Sync-Repo {
    param (
        [string]$gitlabServer,
        [string]$sourceRepo,
        [string]$destinationRepo
    )
    
    $sourceUrl = "$gitlabServer/$sourceRepo.git"
    $destinationUrl = "$gitlabServer/$destinationRepo.git"
    $repoName = ($sourceRepo -split "/")[-1] + ".git"
    
    Write-Host "Cloning $sourceUrl as mirror..."
    git clone --mirror $sourceUrl
    
    Set-Location $repoName
    
    Write-Host "Pushing mirror to $destinationUrl..."
    git push --mirror $destinationUrl
    
    Set-Location ..
    Remove-Item -Recurse -Force $repoName
    
    Write-Host "Migration of $sourceRepo to $destinationRepo completed.`n"
}

$gitlabServer = $config.gitlab_server.TrimEnd("/")

foreach ($repo in $config.repos) {
    Sync-Repo -gitlabServer $gitlabServer -sourceRepo $repo.source -destinationRepo $repo.destination
}
