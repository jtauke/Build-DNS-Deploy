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

#Set Photon IP Addresses
$PrimaryIP = "10.0.0.200"
$SecondaryIP = "10.0.0.210"

#Set Name of Photon VM
$PhotonVMName = "PHOTON"


#Scripts to run in Photon

$ConfigurePhotonPrimaryIP = 

$ConfigurePhotonSecondaryIP =


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