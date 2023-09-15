#!/bin/bash
# Filename: driver.sh - coded in utf-8

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

# call: /usr/syno/synoman/webman/3rdparty/AutoPilot/driver.sh
app="AutoPilot"

# Prüfe ob Version min. DSM 7 entspricht
# ----------------------------------------------------------
if [ $(synogetkeyvalue /etc.defaults/VERSION majorversion) -ge 7 ]; then

	# Autopilot einschalten
	if [[ "${1}" == "install" ]]; then
		if [ -f /usr/lib/udev/rules.d/99-autopilot.rules ]; then
			rm -f /usr/lib/udev/rules.d/99-autopilot.rules
		fi
			cp /var/packages/AutoPilot/target/ui/modules/autopilot.rules /usr/lib/udev/rules.d/99-autopilot.rules
			chmod 644 /usr/lib/udev/rules.d/99-autopilot.rules
			/usr/bin/udevadm control --reload-rules

		synodsmnotify -c SYNO.SDS.${app}.Application @administrators ${app}:app:subtitle ${app}:app:autopilot_enabled
	fi

	# Autopilot ausschalten
	if [[ "${1}" == "uninstall" ]] && [ -f /usr/lib/udev/rules.d/99-autopilot.rules ]; then
		rm -f /usr/lib/udev/rules.d/99-autopilot.rules
		/usr/bin/udevadm control --reload-rules

		synodsmnotify -c SYNO.SDS.${app}.Application @administrators ${app}:app:subtitle ${app}:app:autopilot_disabled
	fi
fi