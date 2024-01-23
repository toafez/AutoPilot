#!/bin/bash

# Read disk size in bytes via `df` command of given mountpoint
function evalDiskSize (){
    local mountpoint=$1         # Mountpoint to evaluate

    local -n ref_size=$2        # size of device
    local -n ref_used=$3        # Used size of device
    local -n ref_available=$4   # Available size of device
    local -n ref_usage=$5       # Percentage of used size
    local -n ref_mounted_on=$6  # Mounted on

    local df=$(df -B1 "${mountpoint}")
    df=$(echo "${df}" | sed -e 's/%//g' | awk 'NR > 1 {print $2 " " $3 " " $4 " " $5 " " $6}')
    ref_size=$(echo "${df}" | awk '{print $1}')
    ref_used=$(echo "${df}" | awk '{print $2}')
    ref_available=$(echo "${df}" | awk '{print $3}')
    ref_usage=$(echo "${df}" | awk '{print $4}')
    ref_mounted_on=$(echo "$df" | awk '{print $5}')
}