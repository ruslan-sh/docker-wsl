$IsEnvUpdated = $false
$PathUpdatedMessage = "Environment was updated. Please log out to apply changes"

# Download and install docker client #

$DownloadFileName = "docker-20.10.9.zip"
$DownloadTarget = "$Env:TEMP\$DownloadFileName"
$ExtractTarget = "C:\ProgramData\DockerWsl"
$DockerPath = "$ExtractTarget\docker"

Write-Host
Write-Host "Downloading windows docker client to $DownloadTarget..."
Invoke-WebRequest -Uri "https://download.docker.com/win/static/stable/x86_64/$DownloadFileName" -OutFile "$DownloadTarget"
Write-Host "Done."

Write-Host
Write-Host "Extract docker client to $ExtractTarget..."
New-Item -ItemType Directory -Path "$ExtractTarget" -Force
Expand-Archive -LiteralPath $DownloadTarget -DestinationPath $ExtractTarget -Force
Write-Host "Done."

Write-Host
Write-Host "Update `$Env:Path..."
if (!($Env:Path -like "*$DockerPath*")) {
    [Environment]::SetEnvironmentVariable("PATH", $Env:Path + ";$DockerPath", [EnvironmentVariableTarget]::Machine)
    $IsEnvUpdated = $true
}

# Setup DOCKER_HOST #

$DockerHost = "tcp://[::1]:2375"

Write-Host
Write-Host "Register DOCKER_HOST environment variable to simplify docker usage." 
if (!($Env:DOCKER_HOST -like "$DockerHost")) {
    [Environment]::SetEnvironmentVariable("DOCKER_HOST", $DockerHost, [EnvironmentVariableTarget]::Machine)
    $IsEnvUpdated = $true
}

# Create helper functions #

$Functions = @"

# WSL Doker Commands    
function Start-Docker {
    wsl sudo service docker start
}
function Stop-Docker {
    wsl sudo service docker stop
}
function Restart-Docker {
    wsl sudo service docker restart
}
"@

Write-Host
Write-Host "Create functions to start/stop docker..."
if (!(Test-Path -Path $PROFILE -PathType Leaf)) {
    New-Item -ItemType File -Path $PROFILE  -Force
}
if ((Get-Content -Path $PROFILE | Select-String -Pattern "# WSL Doker Commands").Matches.Success) {
    Write-Host "Commands already exists."
} else {
    Add-Content -Path $PROFILE -Value $Functions
    Write-Host "Commands: 'Start-Docker', 'Stop-Docker', 'Restart-Docker' - was sucessfully created."
}

Write-Host
Write-Host "Docker WSL was sucessfully installed"
if ($IsEnvUpdated) {
    Write-Host $PathUpdatedMessage
}
