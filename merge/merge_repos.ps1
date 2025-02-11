#!/usr/bin/env pwsh

# This script is used to merge multiple repositories into a single repository.
# It clones the source repository and then clones each merge repository, moves the specified folders from the merge repositories into the source repository, commits the changes, and pushes them to the source repository. 
# The script requires a config.json file in the same directory as the script. The config.json file should contain the GitLab server URL, the source repository, the merge repositories, and the folders to move from the merge repositories.
# The script also requires the GitLab server URL, the source repository, the merge repositories, and the folders to move from the merge repositories.
# The script can be run using the following command:
# ./merge_repos.ps1 -folders "src","test","docs"
    
$configPath = Join-Path -Path $PSScriptRoot -ChildPath "config.json"
if (Test-Path -Path $configPath) {
    $config = Get-Content -Raw -Path $configPath | ConvertFrom-Json
}
else {
    Write-Error "Config file not found: $configPath"
}


function Get-Repo {
    param ([string]$repoUrl, [string]$repoName)
    
    Write-Host "Cloning $repoUrl..."
    git clone $repoUrl $repoName
}

function Move-Folders {
    param (
        [string]$sourceRepo, 
        [string]$targetRepo,
        [array]$folders,
        [string]$placement
    )
    
    foreach ($folder in $folders) {
        $sourcePath = "$sourceRepo/$folder"
        
        if ($placement -eq "nested") {
            $targetPath = "$targetRepo/$sourceRepo/$folder"
        }
        else {
            $targetPath = "$targetRepo/$folder"
        }
        
        New-Item -ItemType Directory -Path $targetPath -Force
        
        git mv -v $sourcePath $targetPath
        Write-Host "Moved $folder from $sourceRepo to $targetPath"
    }
}

function Merge-With-Movement {
    param (
        [string]$gitlabServer, 
        [string]$sourceRepo, 
        [array]$mergeRepos,
        [array]$folders,
        [string]$placement
    )
    
    $sourceUrl = "$gitlabServer/$sourceRepo.git"
    $repoName = $sourceRepo.Split("/")[-1]
    
    Get-Repo -repoUrl $sourceUrl -repoName $repoName
    Set-Location $repoName
    
    foreach ($mergeRepo in $mergeRepos) {
        $mergeUrl = "$gitlabServer/$mergeRepo.git"
        $mergeName = $mergeRepo.Split("/")[-1]
        
        Get-Repo -repoUrl $mergeUrl -repoName $mergeName
        Move-Folders -sourceRepo $mergeName -targetRepo $repoName -folders $folders -placement $placement
        
        git add -A
        git commit -m "Moved $mergeName contents into $repoName"
        Remove-Item -Recurse -Force $mergeName
    }
    
    Write-Host "Pushing changes..."
    git push origin main
    
    Set-Location ..
    Write-Host "Merge process for $sourceRepo completed."
}

$gitlabServer = $config.gitlab_server.TrimEnd("/")
$foldersToMove = @("src", "test")  # Modify this list as needed or pass via script parameter
$placementOption = "nested" # Change to "flat" for option 2

foreach ($repo in $config.repos) {
    Merge-With-Movement -gitlabServer $gitlabServer -sourceRepo $repo.source -mergeRepos $repo."merge-with" -folders $foldersToMove -placement $placementOption
}
