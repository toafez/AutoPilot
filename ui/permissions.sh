#!/bin/sh
# Filename: permissions.sh - coded in utf-8
# call: /usr/syno/synoman/webman/3rdparty/AutoPilot/permissions.sh


#                       AutoPilot
#
#        Copyright (C) 2026 by Tommes | License GNU GPLv3
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

app="AutoPilot"

# Function: Add or remove users from a group
# ------------------------------------------------- -------------
# Call: synogroupuser "[adduser or deluser]" "GROUP" "USER"
function synogroupuser()
{
	oldIFS=${IFS}
	IFS=$'\n'
	query=${1}
	group=${2}
	user=${3}
	userlist=$(synogroup --get ${group} | grep -E '^[0-9]*:'| sed -e 's/^[0-9]*:\[\(.*\)\]/\1/')
	updatelist=()
	for i in ${userlist}; do
		if [[ "${query}" == "adduser" ]]; then
			[[ "${i}" != "${user}" ]] && updatelist+=(${i})
			[[ "${i}" == "${user}" ]] && userexists="true"
		elif [[ "${query}" == "deluser" ]]; then
			[[ "${i}" != "${user}" ]] && updatelist+=(${i})
			[[ "${i}" == "${user}" ]] && userexists="true"
		else
			synodsmnotify -c SYNO.SDS.${app}.Application @administrators ${app}:app:title ${app}:app:groupuser_error
			synologset1 sys err 0x11100000 "Package [AutoPilot] an error occurred while editing the app permissions!"
			exit 1
		fi
	done

	if [[ -z "${userexists}" && "${query}" == "adduser" ]]; then
		updatelist+=(${user})
		synogroup --member ${group} ${updatelist[@]}
		synodsmnotify -c SYNO.SDS.${app}.Application @administrators ${app}:app:title ${app}:app:adduser_true
		synologset1 sys info 0x11100000 "Package [AutoPilot] has successfully expanded app permissions!"
	elif [[ -n "${userexists}" && "${query}" == "adduser" ]]; then
		synodsmnotify -c SYNO.SDS.${app}.Application @administrators ${app}:app:title ${app}:app:adduser_exists
		exit 2
	elif [[ -n "${userexists}" && "${query}" == "deluser" ]]; then
		synogroup --member ${group} ${updatelist[@]}
		synodsmnotify -c SYNO.SDS.${app}.Application @administrators ${app}:app:title ${app}:app:deluser_true
		synologset1 sys info 0x11100000 "Package [AutoPilot] has successfully revoked advanced app permissions!"
	elif [[ -z "${userexists}" && "${query}" == "deluser" ]]; then
		synodsmnotify -c SYNO.SDS.${app}.Application @administrators ${app}:app:title ${app}:app:deluser_notexist
		exit 3
	fi

	IFS=${oldIFS}
}

# Set App permissions
# --------------------------------------------------------------

	# Check whether version corresponds to at least DSM 7
	# ----------------------------------------------------------
	if [ $(synogetkeyvalue /etc.defaults/VERSION majorversion) -ge 7 ]; then

		# Add AutoPilot to the administrators group
		if [[ "${1}" == "adduser" ]]; then
			synogroupuser "adduser" "administrators" "AutoPilot"
		fi

		# Remove AutoPilot from the administrators group
		if [[ "${1}" == "deluser" ]]; then
			synogroupuser "deluser" "administrators" "AutoPilot"
		fi
	fi
