#!/bin/bash
# Set up script for VirtualBox VMs
#
# Copyright (C) 2014 Robert Clipsham <robert@octarineparrot.com>
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See http://www.wtfpl.net/ for more details.

VBOXMANAGE=VBoxManage

failure_message() {
    echo Creating virtual machine failed.
    echo To remove the machine and the associated VDI, use:
    echo "$VBOXMANAGE unregister vm <UUID> --delete"
    echo Where the UUID of the machine was printed upon creation
}

OSTYPES=$($VBOXMANAGE list ostypes | grep ^ID | cut -w -f2 | sort | tr "\\n" ", " | perl -pe 's/,$/\n/')

read -p "Enter a name for the virtual machine: " VMNAME
echo OS Types
echo --------
echo $OSTYPES
echo --------
read -p "Enter the correct OS Type: " OSTYPE
read -p "Enter the number of CPU cores: " CORES
read -p "Enter the amount of RAM in MB: " RAM
read -e -p "Enter the full path for the virtual disk image (extension must be .vdi): " VDIPATH
read -p "Enter the HDD size in MB: " HDDSIZE
read -e -p "Enter the relative path to the installation ISO: " ISOPATH
read -p "Enter the port number VNC should listen on: " VNCPORT
read -p "Enter a password for VNC access (stored in plaintext): " VNCPASS

echo VM Details
echo ----------
echo "Name:         $VMNAME"
echo "Type:         $OSTYPE"
echo "CPU Cores:    $CORES"
echo "RAM:          $RAM MB"
echo "HDD Path:     $VDIPATH"
echo "HDD Size:     $HDDSIZE MB"
echo "ISO Path:     $ISOPATH"
echo "VNC Port:     $VNCPORT"
echo "VNC Password: $VNCPASS"
echo ----------
read -p "Press enter to create a VM with these details, otherwise Ctrl+C to exit"

echo Creating Virtual Machine...

$VBOXMANAGE createvm --name "$VMNAME" --ostype "$OSTYPE" --register &&
$VBOXMANAGE modifyvm "$VMNAME" --memory "$RAM" --acpi on --boot1 dvd --nic1 nat --cpus "$CORES" --vrde on --vrdeport "$VNCPORT" --vrdeaddress 0.0.0.0 &&
$VBOXMANAGE createhd --filename "$VDIPATH" --size "$HDDSIZE" &&
$VBOXMANAGE storagectl "$VMNAME" --name "IDE Controller" --add ide --controller PIIX4 &&
$VBOXMANAGE storageattach "$VMNAME" --storagectl "IDE Controller" --port 0 --device 0 --type hdd --medium $VDIPATH &&
$VBOXMANAGE storageattach "$VMNAME" --storagectl "IDE Controller" --port 0 --device 1 --type dvddrive --medium $ISOPATH &&
$VBOXMANAGE setproperty vrdeextpack VNC &&
$VBOXMANAGE modifyvm "$VMNAME" --vrdeauthlibrary null --vrdeproperty "VNCPassword=$VNCPASS" &&
echo Virtual machine created &&
echo "To unmount the ISO after installation, use: " &&
echo $VBOXMANAGE storageattach "\"$VMNAME\"" --storagectl "\"IDE Controller\"" --port 0 --device 1 --medium emptydrive &&
echo "To set up port forwarding for the VM, to allow access to servers (SSH/RDP/HTTP etc) use:" &&
echo $VBOXMANAGE modifyvm "\"$VMNAME\"" --natpf1 "\"<Rule name>,<tcp|udp>,,<host port>,,<vm port>\"" &&
echo To start the VM, run: &&
echo $VBOXMANAGE startvm "\"$VMNAME\"" --type headless ||
failure_message
