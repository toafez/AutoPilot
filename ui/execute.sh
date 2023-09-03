#!/bin/bash
# Filename: execute.sh - coded in utf-8

#                       AutoPilot
#
#        Copyright (C) 2023 by Tommes | License GNU GPLv3
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

# --------------------------------------------------------------
# Define Enviroment
# --------------------------------------------------------------
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/syno/bin:/usr/syno/sbin
app="AutoPilot"
dir="$(echo `dirname ${0}`)"
#scriptname="$(echo `basename ${0%.*}`)"
scriptname="autopilot"
logpath="${dir}/usersettings/logfiles"
logfile="${scriptname}.log"

# Create logfile
# ----------------------------------------------------------
if [ ! -d "${logpath}" ]; then
	mkdir -p -m 0777 "${logpath}"
fi
if [ -d "${logpath}" ]; then
	if [ ! -f "${logpath}/${logfile}" ]; then
		touch "${logpath}/${logfile}"
		chmod 0777 "${logpath}/${logfile}"
		chown "${app}":"${app}" "${logpath}/${logfile}"
	fi
fi
log="${logpath}/${logfile}"

# Load configuration settings
# ----------------------------------------------------------
[ -f "${dir}/usersettings/system/${scriptname}.config" ] && source "${dir}/usersettings/system/${scriptname}.config"

# Load language settings
# ----------------------------------------------------------
[ -f "${dir}/modules/parse_language.sh" ] && source "${dir}/modules/parse_language.sh" || exit
language "PILOT"

# Set timestamp
# ----------------------------------------------------------
function timestamp()
{
	date +"%Y-%m-%d %H:%M:%S"
}

# Optical and acoustic signal output
# ----------------------------------------------------------
function signal_start()
{
	# Short beep
	echo 2 > /dev/ttyS1
	# Status LED orange on
	echo : > /dev/ttyS1
}

function signal_stop()
{
	# Short beep
	echo 2 > /dev/ttyS1
	# Status LED green on
	echo 8 > /dev/ttyS1
}

function signal_warning()
{
	# Short beep
	echo 2 > /dev/ttyS1
	# Short beep
	echo 2 > /dev/ttyS1
	# Short beep
	echo 2 > /dev/ttyS1
	# Status LED green on
	echo 8 > /dev/ttyS1
}

# --------------------------------------------------------------
# Set parameters for disk and device
# --------------------------------------------------------------
# ${1} is the passed parameter for the device %k, e.g. "usb1p1" from the udev rule
par=$(echo "${1}")

if [ -z "${par}" ]; then
	exit 1
else
	# If ${par} starts with /dev/, then delete /dev/
	par=$(echo "${par}" | sed 's:^/dev/::')

	# If ${par} has a device name like "usb1p1", then get the disk name from it, e.g. "usb1"
	disk=$(echo "${par}" | sed 's:p.*$::')

	# Set device path to determine the mountpoint
	device="/dev/${par}"

	# Searching for mount points
	counter=0
	mountpoint=""
	while ([ -z "${mountpoint}" ] && [ ${counter} -lt 20 ]); do
		mountpoint=$(mount 2>&1 | grep "$device" | cut -d ' ' -f3)
		((counter++))
		sleep 2
	done
fi

# Mount (connect) external USB devices
# ----------------------------------------------------------
if [[ "${connect}" == "true" ]] && [ -n "${mountpoint}" ]; then

	# Search autopilot script...
	if [ -f "${mountpoint}/${scriptname}" ]; then
		echo "" >> "${log}"
		echo "${txt_line_separator}"  >> "${log}"
		echo "$(timestamp) - ${txt_autopilot_starts}" >> "${log}"
		echo "${txt_line_separator}" >> "${log}"
		uuid=$(blkid -s UUID -o value ${device})
		echo "${txt_ext_detected}" >> "${log}"
		echo "${txt_disk_detected}: ${disk}" >> "${log}"
		echo "${txt_device_detected}: ${device}" >> "${log}"
		echo "${txt_uuid_detected}: ${uuid}" >> "${log}"
		echo "${txt_mountpoint}: ${mountpoint}" >> "${log}"
		echo "${txt_autopilot_script_search}" >> "${log}"
		echo "" >> "${log}"
		echo "${txt_autopilot_script_found}" >> "${log}"

		# If autopilot script is executable
		if [ -x "${mountpoint}/${scriptname}" ]; then
			echo "" >> "${log}"
			echo "${txt_please_wait}" >> "${log}"
			echo "" >> "${log}"
			[[ "${signal}" == "true" ]] && signal_start
			synodsmnotify -c SYNO.SDS.${app}.Application @administrators ${app}:app:subtitle ${app}:app:autopilot_start "${mountpoint}"

			# Execute autopilot script
			${mountpoint}/${scriptname}
			exit_script=${?}

			# If autoilot was executed successfully (the exit code is 0 or was manually instructed with 100)
			if [[ ${exit_script} -eq 0 ]] || [[ ${exit_script} -eq 100 ]]; then
				[[ ${exit_script} -eq 0 ]] && echo "${txt_autopilot_script_success}" >> "${log}"
				[[ ${exit_script} -eq 100 ]] && echo "${txt_autopilot_script_warning}" >> "${log}"
				echo "" >> "${log}"

				# Initiating disk ejection
				if [[ "${disconnect}" == "auto" ]] || [[ "${disconnect}" == "manual" ]]; then

					# Remove disk from the GUI list
					cp /tmp/usbtab /tmp/usbtab.old
					grep -v "${disk}" /tmp/usbtab.old > /tmp/usbtab
					rm -f /tmp/usbtab.old

					# Write RAM buffer back to disk
					sync
					sleep 5

					# Uncommented Synology command, but cleaning up always sounds good ;o)
					# /usr/syno/bin/synousbdisk -rcclean
					# sleep 5

					# Unmount disk
					unmount_disk=$(/usr/syno/bin/synousbdisk -umount "${disk}")
					echo "${txt_disk_is_ejected}" >> "${log}"
					echo "${txt_system_response}:~# ${unmount_disk}" >> "${log}"
					sleep 10

					# Check if unmount was successful
					unmount_check=$(/usr/syno/bin/synousbdisk -enum | grep "$disk")

					# If disk has been ejected
					if [ -z "${unmount_check}" ]; then

						# Delete block device
						[ -f "/sys/block/${disk}/device/delete" ] && echo 1 > "/sys/block/${disk}/device/delete"

						echo "${txt_disk_was_ejected}" >> "${log}"
						[[ "${signal}" == "true" ]] && signal_stop
						synodsmnotify -c SYNO.SDS.${app}.Application @administrators ${app}:app:subtitle ${app}:app:autopilot_stop_a "${mountpoint}"
					else
						# WARNING: Disk could not be ejected.
						echo "${txt_disk_could_not_be_ejected}" >> "${log}"
						echo "${txt_system_response}:~# ${umount_check}" >> "${log}"
						[[ "${signal}" == "true" ]] && signal_warning
						synodsmnotify -c SYNO.SDS.${app}.Application @administrators ${app}:app:subtitle ${app}:app:autopilot_warning_a "${mountpoint}"
					fi
				else
					# NOTE: Disk remains mounted
					echo "${txt_disk_remains_mount}" >> "${log}"
					[[ "${signal}" == "true" ]] && signal_stop
					synodsmnotify -c SYNO.SDS.${app}.Application @administrators ${app}:app:subtitle ${app}:app:autopilot_stop_b "${mountpoint}"
				fi
			else
				# WARNING: Errors occurred during execution!
				[[ ${exit_script} -ne 100 ]] && echo "${txt_backupjob_warning}" >> "${log}"
				echo "${txt_exit_code_error}:~# ${exit_script}" >> "${log}"
				echo "${txt_disk_remains_mount}" >> "${log}"
				[[ "${signal}" == "true" ]] && signal_warning
				synodsmnotify -c SYNO.SDS.${app}.Application @administrators ${app}:app:subtitle ${app}:app:autopilot_warning_b "${mountpoint}"
			fi
		else
			# WARNING: The autoilot script could not be executed!
			echo "${txt_script_not_executed}" >> "${log}"
			echo "➜ ${txt_script_check_rights}" >> "${log}"
			[[ "${signal}" == "true" ]] && signal_warning
			synodsmnotify -c SYNO.SDS.${app}.Application @administrators ${app}:app:subtitle ${app}:app:autopilot_warning_c "${mountpoint}"
		fi
		echo "${txt_line_separator}"  >> "${log}"
		echo "$(timestamp) ${txt_autopilot_ends}" >> "${log}"
		echo "${txt_line_separator}" >> "${log}"
	fi
fi
