#!/bin/bash
# Filename: eval_disk_space.sh - coded in utf-8

#                       AutoPilot
#
#        Copyright (C) 2024 by Tommes | License GNU GPLv3
#         Member of the German Synology Community Forum
#
# Extract from  GPL3   https://www.gnu.org/licenses/gpl-3.0.html
#                                     ...
# This program is free software: you can redistribute it  and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
# See the GNU General Public License for more details.You should
# have received a copy of the GNU General Public  License  along
# with this program. If not, see http://www.gnu.org/licenses/  !


# Read disk size in bytes via `df` command of given mountpoint
function evalDiskSize ()
{
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
