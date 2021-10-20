# 480utils.ps1 Script for NET-480
# Can be used to create a linked clone in vCenter
# Created by William Alber
# Helped by Sam Johnson

# First, attempts to connect to my vCenter instance
function Connect-to-Instance {
    try {
        Connect-VIServer -Server vcenter.alber.local -ErrorAction Stop
        Write-Host "Connected to vcenter.alber.local`n`n"
    }
    catch {
        Write-Host "Connection Unsuccessful"
        Connect-Instance
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
    Write-Host "Available Hosts: " `n $hosts
    $vhost = Read-Host -Prompt "Select a host for the Virtual Machine"
    try {
        $vmhost = Get-VMHost -Name $vhost -ErrorAction Stop
        Write-Host "Host to use: $vmhost`n`n"
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

Connect-to-Instance
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

