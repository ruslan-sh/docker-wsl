# docker-wsl

Install docker using WSL. The script will set Ubuntu 20.04 as a default WSL2 repository,
upgrade all its packages, install and set up docker daemon on it.
Then it will set up your Windows to run docker commands on the WSL docker daemon
The end-user experience should be almost the same as "Docker Desktop" 

# Prerequesites

1.  WSL 2 is setup and enabled 
    https://docs.microsoft.com/en-us/windows/wsl/install

2.  Fresh 'Ubuntu 20.04' installation 
    https://www.microsoft.com/en-us/p/ubuntu-2004-lts/9n6svws3rx71
    After installation open it to complete setup.
    Pay attention to the ubuntu version, the script may not work for other versions.
    If you wanna use a different ubuntu version or skip some setup procedures 
    just change the script. In any way, it might be a good idea to read the
    script beforehand.

# How to use

Run `docker-wsl.ps1` as admin.

# How to test the setup

1.  Logout and login to your windows account to make sure env is up to date
2.  Run `> Start-Docker` in PowerShell to start the engine
3.  Run `> docker ps` or `> docker run -i hello-world` to test the setup

# How to upgrade

To upgrade docker engine run as admin:
```
docker-wsl.ps1 Upgrade-WSL
```

To upgrade docker CLI download latest script or manually change CLI download path and run as admin:
```
docker-wsl.ps1 Upgade-CLI
```

you can run next command to upgrade both engine and CLI:
```
docker-wsl.ps1 Upgrade
```

# System-wide commands

*	`Start-Docker`	-- starts docker-engine
*	`Stop-Docker`	-- stops docker-engine
*	`Restart-Docker`	-- restarts docker-engine
*	`docker`	-- to use docker (as usual)
*	`docker compose`	-- for docker-compose


# Tips

To connect to containers you should use `127.0.0.1` instead of `localhost` in 
your applications.

If you are using SSMS to connect to SQL Server inside docker you should use 
`[::1]` instead of `localhost`.

In case something goes wrong you may try to reset the ubuntu distro to the 
fresh state. To do so: 

1. Go to Settings > Apps > Apps & features
2. Find Ubuntu in the apps list
3. Click three-dots-button > Advanced options
4. Click `Reset`
