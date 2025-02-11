$configPath = Join-Path -Path $PSScriptRoot -ChildPath "config.json"
if (Test-Path -Path $configPath) {
    $config = Get-Content -Raw -Path $configPath | ConvertFrom-Json
} else {
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
