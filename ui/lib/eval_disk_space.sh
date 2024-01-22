#!/bin/bash

# Read disk size in bytes via `df` command of given mountpoint
function evalDiskSize (){
    local -n ref_mountpoint=$1
    local -n ref_ext_disk_size=$2
    local -n ref_ext_disk_used=$3
    local -n ref_ext_disk_available=$4
    local -n ref_ext_disk_used_percent=$5
    local -n ref_ext_disk_mountpoint=$6

    local df=$(df -B1 "${ref_mountpoint}")
    df=$(echo "${df}" | sed -e 's/%//g' | awk 'NR > 1 {print $2 " " $3 " " $4 " " $5 " " $6}')
    ref_ext_disk_size=$(echo "${df}" | awk '{print $1}')
    ref_ext_disk_used=$(echo "${df}" | awk '{print $2}')
    ref_ext_disk_available=$(echo "${df}" | awk '{print $3}')
    ref_ext_disk_used_percent=$(echo "${df}" | awk '{print $4}')
    ref_ext_disk_mountpoint=$(echo "$df" | awk '{print $5}')
}