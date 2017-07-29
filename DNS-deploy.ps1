#Import PowerCLI modules
Get-Module -ListAvailable VMware* | Import-Module | Out-Null

#Variables for connection to ESXI host
$EsxiHost = "10.0.0.130"
$HostUserName = "root"
$HostPassword = "@11ianc3"

#Location of Photon OVA
$PhotonSource = "C:\Photon\photon.ova"

#Set datastore name
$DatastoreName = "LocalStorage"


#Set Name of Photon VM
$PhotonVMName = "PHOTON"

#Set Photon Credentials
$PhotonUser = "root"
$PhotonPassword = ConvertTo-SecureString -String "@11ianc3" -AsPlainText -Force


#---------------Scripts to run in Photon

#Set Photon IP Addresses
$ConfigurePhotonIP = "PrimaryIP = `"10.0.0.200/24`";
                      SecondaryIP = `"10.0.0.210`";
                      sed -i 's/Address.*/Address=10.0.0.200\/24/' /etc/systemd/network/10-eth0-static-en.network"



#---------------SCRIPT EXECUTION OCCURS BELOW---------------------------------------------

#Connect to ESXI host
Connect-VIServer $EsxiHost -User $HostUserName -Password $HostPassword -WarningAction SilentlyContinue

#Import Photon OVA
$VMHost = Get-VMHost
$VMDatastore = Get-Datastore -Name $DatastoreName
Import-VApp -Source $PhotonSource -VMHost $VMHost -Datastore $VMDatastore -Name $PhotonVMName
$PhotonVM = Get-VM -Name $PhotonVMName

#Start Photon VM
Start-VM -VM $PhotonVM

Invoke-VMScript -ScriptText $ConfigurePhotonIP -VM $PhotonVM -GuestUser $PhotonUser -GuestPassword $PhotonPassword
