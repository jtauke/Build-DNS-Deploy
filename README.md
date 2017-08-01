# Build-DNS-Deploy

Purpose: Provide individualized DNS service for use when building hardware in-house.  Allowing creation of proper DNS records and avoiding reconfiguration of network settings when physically deploying hardware.

## What the script does
 1. Collect all required variables
 2. Deploy a Boot2Docker VM to the given ESXI server (note: this process will download the iso from the internet and upload it to the host)
 3. Add a two additonal IPs to the existing NIC (These should match the on-prem DNS)
 4. SSH to the Boot2Docker VM and pull a copy of the BIND container
 5. Run the BIND container on the Boot2Docker VM (Should respond to DNS on UDP 53 on both the additional IPs were added) - Set the container to auto restart
 6. Web Management Interface for the BIND container is also configured (port 10000 on the Primary IP that was set) - See below section "Using BIND via webmin"
 7. Creates and marks as executable, a script that will run when boot2docker boots
 8. Use the linux sed command to alter the BIND config to allow recursion (so we can do queries for non-authoritative zones)
 9. Restart BIND service to apply step 8
 10. Write lines into the script that was created in step 7.  This resets the IP information on boot

### There should be no need to edit anything other than the variables section of this script

## Prerequisites
* Install the Docker client on your local machine

## How to run
1. Set Variables 
2. Open powershell
3. cd /script/location/
4. .\BUild-DNS-DEPLOY.ps1

## How to Remove
From your local machine, run the following
> docker-machine rm $Nameofboot2dockerVM

## Using BIND via Webmin
The container we're using comes with a managment web interface that will run on port 10000 using whatever primary IP address is configured in the variable section

1. Naviate to https://IP:10000
2. Login using root credentials set during deployment
3. Expand Servers
4. Click on BIND DNS Server
5. Under existing DNS Zones, select "Create Master Zone"
6. Create required DNS zone (Email address field is required, but anything can be put there)
7. Click Create
8. Click on Address
9. Create A record (submit and repeat as needed)
10. After making changes, don't forget to hit the apply button in the upper right (looks like a refresh button -- this restarts the BIND service)
