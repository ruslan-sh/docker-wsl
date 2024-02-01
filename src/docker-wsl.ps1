#   # Prerequesites #
#
#   1.  WSL 2 is setup and enabled 
#       https://docs.microsoft.com/en-us/windows/wsl/install
#
#   2.  Fresh 'Ubuntu 22.04' installation 
#       https://apps.microsoft.com/detail/9PN20MSR04DW?hl=en-us&gl=US
#       After installation open it to complete setup
#
#   The script will set Ubuntu 22.04 as a default WSL2 repository,
#   upgrade all it's packages, install and setup docker daemon on it.
#   Then it will setup your Windows to run docker commands on WSL docker daemon
#
#   The end-user experience should be almost the same as "Docker Desktop"
#   
#   # How to test the setup #
#
#   1.  logout and login to your windows account to make sure env is up to date
#   2.  type `> Start-Docker` in powershell to start the engine
#   3.  type `> docker ps` or `> docker run -i hello-world` to test the setup

param($Command="")

$IsEnvUpdated = $false
$PathUpdatedMessage = "Environment was updated. Please log out to apply changes"

###

function Install-CLI () {
    # Download and install docker client #

    $DownloadFileName = "docker-25.0.1.zip"
    $DownloadTarget = "$Env:TEMP\$DownloadFileName"
    $ExtractTarget = "C:\ProgramData\DockerWsl"
    $DockerPath = "$ExtractTarget\docker"

    Write-Host
    Write-Host "Downloading windows docker client to $DownloadTarget..."
    Invoke-WebRequest `
        -Uri "https://download.docker.com/win/static/stable/x86_64/$DownloadFileName" `
        -OutFile "$DownloadTarget"
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
    Write-Host "Done."
}

function Upgrade-WSL {
    Write-Host
    Write-Host "Setup Ubuntu 22.04 as default distro."
    if ((wsl -l -q | Select-String -SimpleMatch -Pattern "Ubuntu-22.04" -InputObject {$_.Replace("`0", "")}).Matches.Success) {
        Write-Error "Ununtu 22.04 is not installed"
        Exit
    }
    wsl --setdefault Ubuntu-22.04

    Write-Host
    Write-Host "Update and upgrade ubuntu..."
    wsl --user root --exec sudo apt update
    wsl --user root --exec sudo apt -y upgrade
    Write-Host "Update and upgrade ubuntu...Done."
}

function Setup () {
    # WSL #
    Upgrade-WSL

    # Install Docker #

    Write-Host
    Write-Host "Install docker..."

    Write-Host
    Write-Host "Set up the repository..."
    wsl --user root --exec sudo apt-get remove docker docker-engine docker.io containerd runc
    wsl --user root --exec sudo apt-get update
    wsl --user root --exec sudo apt-get -y install ca-certificates curl gnupg lsb-release
    wsl --user root `
        --exec /bin/sh `
        -c "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor --yes -o /usr/share/keyrings/docker-archive-keyring.gpg"
    $str = "deb [arch=`$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu `$(lsb_release -cs) stable"
    wsl --user root `
        --exec /bin/sh `
        -c "echo $str | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null"
    Write-Host "Set up the repository...Done."

    Write-Host
    Write-Host "Install Docker Engine..."
    wsl --user root --exec apt-get update
    wsl --user root --exec apt-get -y install docker-ce docker-ce-cli containerd.io
    Write-Host "Install Docker Engine...Done."

    Write-Host "Install docker...Done."

    # Configure Docker #

    Write-Host
    Write-Host "Configure Docker..."

    wsl --user root --exec groupadd docker

    wsl --user root --exec mkdir /etc/docker
    wsl --user root --exec touch /etc/docker/daemon.json
    $str = '{
        \"hosts\": [\"unix:///var/run/docker.sock\", \"tcp://0.0.0.0:2375\"]
    }'
    wsl --user root --exec /bin/sh -c "echo '$str' > /etc/docker/daemon.json"

    Write-Host 'Update sudoers...'
    if ( wsl --user root --exec grep -r "docker-wsl" /etc/sudoers ) {
        Write-Host 'Sudoers already updated.'
    } else {
        $str = '# docker-wsl. Allow running docker daemon without password
        %sudo   ALL=(ALL)       NOPASSWD: /usr/sbin/service docker *'
        wsl --user root --exec /bin/sh -c "echo '$str' | sudo EDITOR='tee -a' visudo"
        Write-Host 'Update sudoers... Done.'
    }

    Write-Host "Configure Docker...Done."

    ###

    # WINDOWS #

    Install-CLI

    # Setup DOCKER_HOST #

    $DockerHost = "tcp://[::1]:2375"

    Write-Host
    Write-Host "Register DOCKER_HOST environment variable to simplify docker usage..." 
    if (!($Env:DOCKER_HOST -like "$DockerHost")) {
        [Environment]::SetEnvironmentVariable("DOCKER_HOST", $DockerHost, [EnvironmentVariableTarget]::Machine)
        $IsEnvUpdated = $true
    }
    Write-Host "Done."

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
}

if ($Command -eq "") {
    Setup
    Exit
}

if ($Command -eq "Upgrade-CLI") {
    Install-CLI
    Exit
}

if ($Command -eq "Upgrade-WSL") {
    Upgrade-WSL
    Exit
}

if ($Command -eq "Upgrade") {
    Upgrade-WSL
    Install-CLI
    Exit
}
