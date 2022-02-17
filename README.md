# docker-wsl

Install docker for Windows using WSL

# Prerequesites

1.  WSL 2 is setup and enabled 
    https://docs.microsoft.com/en-us/windows/wsl/install

2.  Fresh 'Ubuntu 20.04' installation 
    https://www.microsoft.com/en-us/p/ubuntu-2004-lts/9n6svws3rx71
    After installation open it to complete setup.
    Pay attention on ubuntu version, the script may not work for other versions.
    If you wanna use different ubuntu version or skip some setup procedures comment them out in the script.

The script will set Ubuntu 20.04 as a default WSL2 repository,
upgrade all it's packages, install and setup docker daemon on it.
Then it will setup your Windows to run docker commands on WSL docker daemon
The end-user experience should be almost the same as "Docker Desktop"

# How to use

Run `docker-wsl.ps1` as admin.

# How to test the setup

1.  Logout and login to your windows account to make sure env is up to date
2.  Run `> Start-Docker` in powershell to start the engine
3.  Run `> docker ps` or `> docker run -i hello-world` to test the setup

# Commands

*	`Start-Docker`	-- starts docker engine
*	`Stop-Docker`	-- stops docker engine
*	`Restart-Docker`	-- restarts docker engine
*	`docker`	-- to use docker (as usual)
*	`docker compose`	-- for docker-compose


# Tips

To connect to containers you shoud use `127.0.0.1` instead of `localhost` in your applications.

If you are using SSMS to connect to SQL Server inside docker you should use `[::1]` instead of `localhost`.

In case if something gones wrong you may try to reset ubuntu distro to the fresh state. To do so: 
1. Go to Settings > Apps > Apps & features
2. Find Ubuntu in the apps list
3. Click three-dots-button > Advanced options
4. Click `Reset`