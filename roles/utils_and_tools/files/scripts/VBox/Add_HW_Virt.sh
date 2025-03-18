#!/bin/bash

VmName="$1"
VBoxManage modifyvm $VmName --nested-hw-virt on