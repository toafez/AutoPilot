#!/bin/bash
# Filename: execute.sh - coded in utf-8

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

# --------------------------------------------------------------
# Define Enviroment
# --------------------------------------------------------------
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/syno/bin:/usr/syno/sbin
app="AutoPilot"
dir="$(echo `dirname ${0}`)"
#scriptname="$(echo `basename ${0%.*}`)"
scriptname="autopilot"
logpath="${dir}/usersettings/logfiles"
devpath="${dir}/usersettings/devices"
logfile="${scriptname}.log"

# Read the version of the AutoPilot app from the INFO.sh file
# ----------------------------------------------------------
app_version=$(cat "/var/packages/${app}/INFO" | grep ^version | cut -d '"' -f2)

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

	# If ${par} has a device name like "usb1p1", then get the partition name from it, e.g. "usb1"
	part=$(echo "${par}" | sed 's:p.*$::')

	# Check if variable $part is named usb[x] (e.g. usb1) ? assign $part to $disk : remove trailing number from $part (e.g. sda1 --> sda)
	if [[ "${part}" =~ ^[uU][sS][bB] ]]; then
		# keep the identified partition as disk, because usb1 is the disk itself
		disk="${part}"
	else
		# remove the number from the partition to identify the disk itself, e.g. partition is sda1 --> disk is sda
		disk=$(echo "${part}" | sed 's/[0-9]\+$//')
	fi

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

	# Extract the local UUID based on device name
	uuid=$(blkid -s UUID -o value ${device})

	# Determine the file system if there is a 128-bit UUID (LINUX/UNIX)
	if [[ "${uuid}" =~ ^\{?[A-F0-9a-f]{8}-[A-F0-9a-f]{4}-[A-F0-9a-f]{4}-[A-F0-9a-f]{4}-[A-F0-9a-f]{12}\}?$ ]]; then
		txt_volume_id="Universally Unique Identifier (UUID)"
	# Determine the file system if there is a 64 bit VSN (Windows NTFS)
	elif [[ "${uuid}" =~ ^\{?[A-F0-9a-f]{16}\}?$ ]]; then
		txt_volume_id="Volume Serial Number (VSN)"
	# Determine the file system if there is a 32 bit VSN (Windows FAT12, FAT16, FAT32 and exFAT) combined as vFAT
	elif [[ "${uuid}" =~ ^\{?[A-F0-9a-f]{4}-[A-F0-9a-f]{4}\}?$ ]] || [[ "${ext_uuid}" =~ ^\{?[A-F0-9a-f]{8}\}?$ ]]; then
		txt_volume_id="Volume Serial Number (VSN)"
	else
		txt_volume_id="Universally or Globally Unique Identifier (UUID or GUID) Could not be read"
	fi

	# Extract the saved UUID from the AutoPilot record of the same name
	uuidfile="${devpath}/${uuid}"
	saveduuid="${uuidfile##*/}"

	# Compare the local UUID with the saved UUID AutoPilot record
	if [ -f "${uuidfile}" ] && [[ "${saveduuid}" == "${uuid}" ]]; then
		# Extract the path and filename of the script to be executed
		scriptfile=$(cat "${uuidfile}" | grep scriptpath | cut -d '"' -f2)
	fi

	# Search autopilot script...
	if [ -f "${scriptfile}" ]; then
		echo "" >> "${log}"
		echo "${txt_line_separator}"  >> "${log}"
		echo "$(timestamp) - AutoPilot Version ${app_version} ${txt_autopilot_starts}" >> "${log}"
		echo "${txt_line_separator}" >> "${log}"
		echo "${txt_ext_detected_step_1} ${part} ${txt_ext_detected_step_2}" >> "${log}"
		echo "${txt_device_detected}: ${device}" >> "${log}"
		echo "${txt_mountpoint}: ${mountpoint}" >> "${log}"
		echo "${txt_volume_id}: ${uuid}" >> "${log}"
		echo "${txt_autopilot_script_search}: ${scriptfile}" >> "${log}"
		echo "" >> "${log}"
		echo "${txt_autopilot_script_found}" >> "${log}"

		# If autopilot script is executable
		if [ -x "${scriptfile}" ]; then
			echo "" >> "${log}"
			echo "${txt_please_wait}" >> "${log}"
			echo "" >> "${log}"
			[[ "${signal}" == "true" ]] && signal_start
			synodsmnotify -c SYNO.SDS.${app}.Application @administrators ${app}:app:subtitle ${app}:app:autopilot_start "${mountpoint}"

			# Execute autopilot script
			${scriptfile}
			exit_script=${?}

			# Reading out free disk space
			df=$(df -h "${mountpoint}")
			df=$(echo "${df}" | sed -e 's/%//g' | awk 'NR > 1 {print $2 " " $3 " " $4 " " $5 " " $6}')
			ext_disk_size=$(echo "${df}" | awk '{print $1}' | sed -e 's/T/ TB/g' | sed -e 's/G/ GB/g' | sed -e 's/M/ MB/g')
			#ext_disk_used=$(echo "${df}" | awk '{print $2}' | sed -e 's/T/ TB/g' | sed -e 's/G/ GB/g' | sed -e 's/M/ MB/g')
			ext_disk_available=$(echo "${df}" | awk '{print $3}' | sed -e 's/T/ TB/g' | sed -e 's/G/ GB/g' | sed -e 's/M/ MB/g')
			#ext_disk_used_percent=$(echo "${df}" | awk '{print $4}')
			#ext_disk_mountpoint=$(echo "$df" | awk '{print $5}')

			# If autoilot was executed successfully (the exit code is 0 or was manually instructed with 100)
			if [[ ${exit_script} -eq 0 ]] || [[ ${exit_script} -eq 100 ]]; then
				[[ ${exit_script} -eq 0 ]] && echo "${txt_autopilot_script_success}" >> "${log}"
				[[ ${exit_script} -eq 100 ]] && echo "${txt_autopilot_script_warning}" >> "${log}"
				echo "" >> "${log}"

				# Initiating disk ejection
				if [[ "${disconnect}" == "auto" ]] || [[ "${disconnect}" == "manual" ]]; then

					# Remove disk from the GUI list
					sed -i "/^""${disk}""/d" /tmp/usbtab

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
					unmount_check=$(/usr/syno/bin/synousbdisk -enum | grep "${disk}")

					# If disk has been ejected
					if [ -z "${unmount_check}" ]; then

						# Delete block device
						[ -f "/sys/block/${disk}/device/delete" ] && echo 1 > "/sys/block/${disk}/device/delete"

						echo "${txt_disk_was_ejected}" >> "${log}"
						[[ "${signal}" == "true" ]] && signal_stop
						synodsmnotify -c SYNO.SDS.${app}.Application @administrators ${app}:app:subtitle ${app}:app:autopilot_stop_a "${mountpoint}"
						synologset1 sys info 0x11100000 "Package [AutoPilot] executed the task successfully! The external disk [${mountpoint}] has been ejected."
					else
						# WARNING: Disk could not be ejected.
						echo "${txt_disk_could_not_be_ejected}" >> "${log}"
						echo "${txt_system_response}:~# ${unmount_check}" >> "${log}"
						[[ "${signal}" == "true" ]] && signal_warning
						synodsmnotify -c SYNO.SDS.${app}.Application @administrators ${app}:app:subtitle ${app}:app:autopilot_warning_a "${mountpoint}"
						synologset1 sys warn 0x11100000 "Package [AutoPilot] executed the task successfully! The external Disk [${mountpoint}] could not be ejected."
					fi
				else
					# NOTE: Disk remains mounted
					echo "${txt_disk_remains_mount}" >> "${log}"
					[[ "${signal}" == "true" ]] && signal_stop
					synodsmnotify -c SYNO.SDS.${app}.Application @administrators ${app}:app:subtitle ${app}:app:autopilot_stop_b "${mountpoint}"
					synologset1 sys info 0x11100000 "Package [AutoPilot] executed the task successfully! The external disk [${mountpoint}] remains mounted."
				fi
			else
				# WARNING: Errors occurred during execution!
				[[ ${exit_script} -ne 100 ]] && echo "${txt_backupjob_warning}" >> "${log}"
				echo "${txt_exit_code_error}:~# ${exit_script}" >> "${log}"
				echo "${txt_disk_remains_mount}" >> "${log}"
				[[ "${signal}" == "true" ]] && signal_warning
				synodsmnotify -c SYNO.SDS.${app}.Application @administrators ${app}:app:subtitle ${app}:app:autopilot_warning_b "${mountpoint}"
				synologset1 sys err 0x11100000 "Package [AutoPilot] executed the task with errors! The external disk [${mountpoint}] remains mounted."
			fi
		else
			# WARNING: The autoilot script could not be executed!
			echo "${txt_script_not_executed}" >> "${log}"
			echo "➜ ${txt_script_check_rights}" >> "${log}"
			[[ "${signal}" == "true" ]] && signal_warning
			synodsmnotify -c SYNO.SDS.${app}.Application @administrators ${app}:app:subtitle ${app}:app:autopilot_warning_c "${mountpoint}"
		fi
		echo "${txt_df_memory}: ${ext_disk_available} ${txt_df_from} ${ext_disk_size} ${txt_df_free}." >> "${log}"
		echo "${txt_line_separator}"  >> "${log}"
		echo "$(timestamp) ${txt_autopilot_ends}" >> "${log}"
		echo "${txt_line_separator}" >> "${log}"
	fi
fi
