# 480utils.ps1 Script for NET-480
# Can be used to create a linked clone in vCenter
# Created by William Alber

function Connect-to-Instance {
    try {
        Connect-VIServer -Server vcenter.alber.local -ErrorAction Stop
        Write-Host "Connected to vcenter.alber.local`n`n"
    }
    catch {
        Write-Host "Connection Unsuccessful"
        Connect-to-Instance
        }
}

# set the vm name
function Name {
    $name = Read-Host -Prompt "Virtual Machine Name"
    Write-Host "`n`n"
    return $name
}

# Should get the virtual machine that needs to be cloned
function Base-VM {
    $vms = Get-VM -Location Base-VMs
    Write-Host "Available VMs to Clone: " `n $vms
    $vm = Read-Host -Prompt "Which Virtual Machine would you like to clone"
    try {
        $base_vm = Get-VM -Name $vm
        Write-Host "Selected Virtual Machine: $base_vm`n`n"
    }
    catch {
        Write-Host "Virtual Machine not Found"
        exit
    }
    return $base_vm
}

# selects the host, in our case super4 will always be the host
function VM-Host {
    $hosts = Get-VMHost
    Write-Host "`nAvailable Hosts: " `n $hosts
    $vhost = Read-Host -Prompt "Select a host for the Virtual Machine"
    try {
        $vmhost = Get-VMHost -Name $vhost -ErrorAction Stop
        Write-Host "Host to use: $vmhost`n"
    }
    catch {
        Write-Host "Cannot find selected Host"
        exit
    }
    return $vmhost
}

# selects the datastore to place the clone
function Use-DStore {
    $dstores = Get-Datastore
    Write-Host "Available Datastores: " `n $dstores
    $dstore = Read-Host -Prompt "Select a datastore for the Virtual Machine"
    try {
        $dstore = Get-Datastore -Name $dstore -ErrorAction Stop
        Write-Host "Datastore to Use: $dstore`n`n"
    }
    catch {
        Write-Host "Datastore not Found"
        exit
    }
    return $dstore
}

function VM-Creation { 
    $name = Name
    $base_vm = Base-VM
    $vm_host = VM-Host
    $dstore = Use-DStore

    Write-Host "`n`nVirtual Machine will be created..."
    try {
        New-VM -Name $name.ToString() -VM $base_vm -LinkedClone -ReferenceSnapshot Base -VMHost $vm_host -Datastore $dstore   
    }
    catch {
        Write-Host "Something went wrong..."
        exit
    }
}

function Create-Network {
    $name = Read-Host -Prompt "`nNetwork Name"

    New-VirtualSwitch -Name $name -VMHost "super4.cyber.local"
    New-VirtualPortGroup -Name $name -VirtualSwitch $name
}

function Start {
    $vmStart = Read-Host -Prompt "Which Virtual Machine would you like to start"

    try {
        Start-VM -VM $vmstart
    }
    catch {
        Write-Host "Something went wrong..."
        exit
    }
}

function Network-Change {
    $vm = Read-Host -Prompt "Enter a Virtual Machine"
    $network = Read-Host -Prompt "Enter a Network"
    $adapter = Get-NetworkAdapter -VM $vm -Name "Network adapter 1"

    Write-Host "Setting Network Adaptor of $vm to $network"
    Set-NetworkAdapter -NetworkAdapter $adapter -NetworkName $network
}

function ExtractBase {
    
    $vm = Read-Host -Prompt "Enter Virtual Machine name"
    $snapshot = Get-Snapshot -VM $vm -Name "Base"
    $vhost = VM-Host
    $ds = Use-DStore
    $linkedname = "$vm.linked" -f $vm.name

    Write-Host "Extracting image..."
    $linkedvm = New-VM -LinkedClone -Name $linkedname -VM $vm -ReferenceSnapshot $snapshot -VMHost $vhost -Datastore $ds
    $newvm = New-VM -Name "$vm.base" -VM $linkedvm -VMhost $vhost -Datastore $ds -Location "BASE-VMS"
    $newvm | New-Snapshot -Name "Base"
    Remove-VM -VM $linkedvm
}

function Get-IP {
    $vms = Get-VM
    Write-Host "`nSelect a Virtual Machine to extract from: " `n $vms
    $name = Read-Host -Prompt "What Virtual Machine's IP Address do you want"
    $vm = Get-VM -Name $name.ToString()

    $ip = $vm.guest.IPAddress[0]
    $mac = ($vm | Get-NetworkAdapter)[0].MacAddress
    Write-Host "`nip= $ip mac=$mac`n"
    return $ip
}

Connect-to-Instance

while (1 -eq 1) {
$user_in = Read-Host -Prompt @"
What would you like to do:

[1] Create Linked Clone
[2] Create Virtual Network
[3] Extract a Base Image
[4] Turn on Virtual Machine
[5] Change VM's Network
[6] Get IP Address

Please enter number here
"@

    if ($user_in -eq "1") {
        VM-Creation
    }
    elseif ($user_in -eq "2") { 
        Create-Network
    }
    elseif ($user_in -eq "3") {
        ExtractBase
    }
    elseif ($user_in -eq "4") {
        Start
    }
    elseif ($user_in -eq "5") {
        Network-Change
    }
    elseif ($user_in -eq "6") {
        Get-IP
    }
}


# VM-Creation
