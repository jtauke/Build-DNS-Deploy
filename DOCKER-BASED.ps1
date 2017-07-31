#Created by Joe Tauke
# 7/30/2017

#Set script variables
$EsxiHost = "192.168.50.156"
$EsxiUsername = "root"
$EsxiPassword = "Password123"
$DockerHostName = "DockerHost"
$DockerHostPrimaryIP = "192.168.50.200"
$DockerHostSecondaryIP = "192.168.50.210"
$NetworkSubnetBits = "/24"

#Create Docker host on our ESXI server
docker-machine create -d vmwarevsphere --vmwarevsphere-vcenter $EsxiHost --vmwarevsphere-username $EsxiUsername --vmwarevsphere-password $EsxiPassword --vmwarevsphere-boot2docker-url https://github.com/boot2docker/boot2docker/releases/download/v17.06.1-ce-rc2/boot2docker.iso $DockerHostName

#Setup SSH to container Host
docker-machine env $DockerHostName | Invoke-Expression

#Set IP addresses to match clients DNS servers
docker-machine ssh $DockerHostName sudo ip addr add $DockerHostPrimaryIP$NetworkSubnetBits dev eth0
docker-machine ssh $DockerHostName sudo ip addr add $DockerHostSecondaryIP$NetworkSubnetBits dev eth0

#Create script string that can be injected into the bootlocal.sh below
$PrimaryIPset = "ip addr add $DockerHostPrimaryIP$NetworkSubnetBits dev eth0"
$SecondaryIPSet = "ip addr add $DockerHostSecondaryIP$NetworkSubnetBits dev eth0"

#Pull BIND container
docker-machine ssh $DockerHostName docker pull sameersbn/bind:latest

#Start BIND Container
docker-machine ssh $DockerHostName docker run -d --name=bind --dns=127.0.0.1 --publish=$DockerHostPrimaryIP':53:53/udp' --publish=$DockerHostSecondaryIP':53:53/udp' --publish=$DockerHostPrimaryIP':10000:10000' --volume=/srv/docker/bind:/data --env='ROOT_PASSWORD=@11ianc3' sameersbn/bind:latest

#Create persistant boot script to keep IP and start our container
docker-machine ssh $DockerHostName sudo touch "/var/lib/boot2docker/bootsync.sh"
docker-machine ssh $DockerHostName sudo chmod +x "/var/lib/boot2docker/bootsync.sh"
docker-machine ssh $DockerHostName "echo -e '#! /bin/sh \n $PrimaryIPSet \n $SecondaryIPSet \n Docker start bind' | sudo tee -a /var/lib/boot2docker/bootlocal.sh"

