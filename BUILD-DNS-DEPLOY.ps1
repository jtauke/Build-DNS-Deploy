#Created by Joe Tauke
# 7/30/2017

#Set script variables
$EsxiHost = "IP ADDRESS OF ESXI HOST HERE"
$EsxiUsername = "ESXI USERNAME HERE"
$EsxiPassword = "ESXI PASSWORD HERE"
$DockerHostName = "DESIRED CONTAINER HOST NAME"
$DockerHostPrimaryIP = "CLIENT PRIMARY DNS IP HERE"
$DockerHostSecondaryIP = "CLIENT SECONDARY IP HERE"
$NetworkSubnetBits = "CLIENT SUBNET BITS HERE (i.e. /24)"

#----------------SCRIPT EXECUTION OCCURS BELOW, DO NOT EDIT----------------------------------------------------------

#Create Docker host on our ESXI server
docker-machine create -d vmwarevsphere --vmwarevsphere-vcenter $EsxiHost --vmwarevsphere-username $EsxiUsername --vmwarevsphere-password $EsxiPassword --vmwarevsphere-boot2docker-url https://github.com/boot2docker/boot2docker/releases/download/v17.06.1-ce-rc2/boot2docker.iso $DockerHostName

#Set IP addresses to match clients DNS servers
docker-machine ssh $DockerHostName sudo ip addr add $DockerHostPrimaryIP$NetworkSubnetBits dev eth0
docker-machine ssh $DockerHostName sudo ip addr add $DockerHostSecondaryIP$NetworkSubnetBits dev eth0

#Create script string that can be injected into the bootlocal.sh below
$PrimaryIPset = "ip addr add $DockerHostPrimaryIP$NetworkSubnetBits dev eth0"
$SecondaryIPSet = "ip addr add $DockerHostSecondaryIP$NetworkSubnetBits dev eth0"

#Pull BIND container
docker-machine ssh $DockerHostName docker pull sameersbn/bind:latest

#Start BIND Container
docker-machine ssh $DockerHostName sudo docker run -d --name=bind --restart always --dns=127.0.0.1 --publish=$DockerHostPrimaryIP':53:53/udp' --publish=$DockerHostSecondaryIP':53:53/udp' --publish=$DockerHostPrimaryIP':10000:10000' --volume=/var/lib/docker/bind:/data --env='ROOT_PASSWORD=@11ianc3' sameersbn/bind:latest

#Create persistant boot script to keep IP and start our container
docker-machine ssh $DockerHostName sudo touch "/var/lib/boot2docker/bootsync.sh"
docker-machine ssh $DockerHostName sudo chmod +x "/var/lib/boot2docker/bootsync.sh"
docker-machine ssh $DockerHostName docker exec bind sed -i '/listen-on-v6/a\allow-recursion\ {any\;}\;' /etc/bind/named.conf.options
docker-machine ssh $DockerHostName docker exec bind service bind9 restart
docker-machine ssh $DockerHostName "echo -e '#! /bin/sh \n $PrimaryIPSet \n $SecondaryIPSet' | sudo tee -a /var/lib/boot2docker/bootlocal.sh"

