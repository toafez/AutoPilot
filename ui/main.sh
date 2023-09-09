#!/bin/bash
# Filename: main.sh - coded in utf-8

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


# Requests zurücksetzen und Seite neu laden
# --------------------------------------------------------------
if [[ "${get[page]}" == "main" && "${get[section]}" == "reset" ]]; then
	unset var
	[[ -f "${get_request}" ]] && rm "${get_request}"
	[[ -f "${post_request}" ]] && rm "${post_request}"
	echo '<meta http-equiv="refresh" content="0; url=index.cgi?page=main&section=start">'
fi

# Horizontale Navigationsleiste laden
# --------------------------------------------------------------
mainnav

# Startseite anzeigen
# --------------------------------------------------------------
if [[ "${get[page]}" == "main" && "${get[section]}" == "start" ]]; then

	# Überprüfen des App-Versionsstandes
	# --------------------------------------------------------------
	local_version=$(cat "/var/packages/${app_name}/INFO" | grep ^version | cut -d '"' -f2)
	git_version=$(wget --no-check-certificate --timeout=60 --tries=1 -q -O- "https://raw.githubusercontent.com/toafez/${app_name}/main/INFO.sh" | grep ^version | cut -d '"' -f2)		
	if [ -n "${git_version}" ] && [ -n "${local_version}" ]; then
		if dpkg --compare-versions ${git_version} gt ${local_version}; then
			echo '
			<div class="row">
				<div class="ol-sm-12">
					<h5>'${txt_update_available}'</h5>
					<table class="table table-borderless table-hover table-sm">
						<thead></thead>
						<tbody>
							<tr>
								<td scope="row" class="row-sm-auto">
									'${txt_update_from}' <span class="text-danger">'${local_version}'</span> '${txt_update_to}' <span class="text-success">'${git_version}'</span>
									<td class="text-end"> 
										<a href="https://github.com/toafez/'${app_name}'/releases" class="btn btn-light btn-sm text-success text-decoration-none" target="_blank">Update</a>
									</td>
								</td>'
									
								echo '
							</tr>
						</tbody>
					</table><hr />
				</div>
			</div>'	
		fi
	fi

	# Überprüfen der App-Berechtigung
	# --------------------------------------------------------------
	if [ -z "${app_permissions}" ] || [[ "${app_permissions}" == "false" ]]; then
		echo '
		<div class="row">
			<div class="col-sm-12">
				<div class="card">
					<div class="card-header bg-danger-subtle"><strong>'${txt_group_status}'</strong></div>
 					<div class="card-body">
						<table class="table table-borderless table-sm mb-0">
							<thead></thead>
							<tbody>
								<tr>
									<td scope="row" class="row-sm-auto">'${txt_group_status_false}'
										<td class="text-end"> 
											<a href="#help-permissions" class="btn btn-sm text-dark text-decoration-none" style="background-color: #e6e6e6;" data-bs-toggle="modal" data-bs-target="#help-app-permissions">'${txt_button_extend_permission}'</a>
										</td>
									</td>
								</tr>
							</tbody>
						</table>
					</div>
				</div>
			</div>
		</div><br />'	
	fi

	taskname="DS115 Daten"
	taskid=$(synoschedtask --get | awk -v pat="Name: \\\[$taskname\\\]" '$0~pat' RS= | grep dsmbackup | grep -Eo [0-9]+)
	echo 'Task-ID: '${taskid}''
	echo '
	<div class="row">
		<div class="col-sm-12">'
			function local_sources()
			{
				echo '
				<table class="table table-borderless table-sm">
					<thead></thead>
					<tbody>'
						while IFS= read -r volume; do
							IFS="${backupIFS}"
							[[ -z "${volume}" ]] && continue
							found_volume="true"
							echo '
							<tr>
								<td colspan="4">
									<i class="bi bi-hdd-fill text-secondary"></i>&nbsp;&nbsp;'${volume#*/}'
								</td>
							</tr>'	

							while IFS= read -r share; do
								IFS="${backupIFS}"
								[[ -z "${share}" ]] && continue
								mountpoint=$(mount | grep -E "${volume}/${share##*/}")
								dev=$(echo "${mountpoint}" | awk '{print $1}')
								path=$(echo "${mountpoint}" | awk '{print $3}')
								#uuid=$(blkid -s UUID -o value ${dev})
								#type=$(blkid -s TYPE -o value ${dev})
								#label=$(blkid -s LABEL -o value ${dev})

								df=$(df -BG "${path}")
								df=$(echo "${df}" | sed -e 's/%//g' | awk 'NR > 1 {print $2 " " $3 " " $4 " " $5 " " $6}')
								disk_free=$(echo "${df}" | awk '{print $1}' | sed -e 's/G/ GB/g')
								#disk_used=$(echo "${df}" | awk '{print $2}' | sed -e 's/G/ GB/g')
								#disk_available=$(echo "${df}" | awk '{print $3}' | sed -e 's/G/ GB/g')
								disk_used_percent=$(echo "${df}" | awk '{print $4}')
								#disk_mountpoint=$(echo "$df" | awk '{print $5}')

								echo '
								<tr>
									<td class="ps-4" style="width: 160px">&nbsp;&nbsp;
										<i class="bi bi-folder-fill text-warning"></i>&nbsp;&nbsp;'${share##*/}'
									</td>
									<td style="width: 220px">'
										[ -f "${path}/autopilot" ] && echo '<span class="text-success">'${txt_autopilot_script_detected}'</span>'
										echo '
									</td>
									<td class="text-end" style="width: 60px">
										Info:
									</td>
									<td style="width: auto">
										<div class="progress" role="progressbar" aria-label="Example with label" aria-valuenow="10" aria-valuemin="0" aria-valuemax="100" style="height: 25px">
											<div class="progress-bar overflow-visible text-dark bg-primary-subtle" style="width: '${disk_used_percent}'%">&nbsp;&nbsp;&nbsp;'${disk_used_percent}'% '${txt_autopilot_from}' '${disk_free}' '${txt_autopilot_use}'</div>
										</div>
									</td>
								</tr>'
							done <<< "$( find ${volume}/* -maxdepth 0 -type d ! -path '*/lost\+found' ! -path '*/\@*' ! -path '*/\$RECYCLE.BIN' ! -path '*/Repair' ! -path '*/System Volume Information' )"
						done <<< "$( find ${1} -type d -maxdepth 0 )"
						echo '
					</tbody>
				</table>'
				unset volume share
			}
			local_sources "/volumeUSB[[:digit:]]"
			local_sources "/volumeSATA[[:digit:]]"
			[[ "${found_volume}" == "true" ]] && echo "<hr />"
			echo '	
		</div>
	</div>'	

	# USB/SATA-AutoPilot Einstellungen
	# --------------------------------------------------
	echo '
	<div class="row">		
		<div class="col-sm-12">
				<table class="table table-borderless table-hover table-sm">
					<thead></thead>
					<tbody>
						<tr>
							<td scope="row" class="row-sm-auto align-middle">'
								if [[ "${udev_rule}" == "true" ]]; then
									if [[ "${rewrite_udev}" == "true" ]]; then
										echo '
										'${txt_autopilot_service}' <span class="text-danger">'${txt_autopilot_is_not_installed}'</span>
										<td class="text-end">
											<button type="button" class="btn btn-light btn-sm text-success text-decoration-none" data-bs-toggle="modal" data-bs-target="#help-autopilot_status">'${txt_button_install}'</button>
										</td>'
									else
										echo '
										'${txt_autopilot_service}' <span class="text-success">'${txt_autopilot_is_installed}'</span>
										<td class="text-end">
											<button type="button" class="btn btn-light btn-sm text-danger text-decoration-none" data-bs-toggle="modal" data-bs-target="#help-autopilot_status">'${txt_button_uninstall}'</button>
										</td>'
									fi
								else
									echo '
									'${txt_autopilot_service}' <span class="text-danger">'${txt_autopilot_is_not_installed}'</span>
									<td class="text-end">
										<button type="button" class="btn btn-light btn-sm text-success text-decoration-none" data-bs-toggle="modal" data-bs-target="#help-autopilot_status">'${txt_button_install}'</button>
									</td>'
								fi
								echo '
							</td>
						</tr>
						<tr>'
							# Einhängen ein/aus
							echo -n '
							<td scope="row" class="row-sm-auto align-middle">
								'${txt_autopilot_connect}'
							</td>
							<td class="text-end">'
								echo -n '
								<a href="index.cgi?page=main&section=save&option=connect&'; \
									if [[ "${connect}" == "true" ]]; then
										echo -n 'query=false"><img src="images/toggle-on.png">'
									else
										echo -n 'query=true"><img src="images/toggle-off.png">'
									fi
									echo -n '
								</a>
							</td>
						</tr>
						<tr>'
							# Auswerfen ein/aus
							echo -n '
							<td scope="row" class="row-sm-auto align-middle">
								'${txt_autopilot_disconnect}'
							</td>
							<td class="text-end"><span style="font-size: 2rem">&nbsp;</span></td>
						</tr>
						<tr>'
							# Niemals auswerfen ein/aus
							echo '
							<td scope="row" class="row-sm-auto align-middle">
								<span class="ps-3">
									<i class="bi bi-dot"></i> '${txt_autopilot_disconnect_never}'
								</span>
							</td>
							<td class="text-end">'
								echo -n '
								<a href="index.cgi?page=main&section=save&option=disconnect&'; \
									if [[ "${disconnect}" == "false" ]]; then
										echo -n 'query="><img src="images/toggle-on.png">'
									else
										echo -n 'query=false"><img src="images/toggle-off.png">'
									fi
									echo -n '
								</a>
							</td>
						</tr>
						<tr>'
							# Automatisch auswerfen ein/aus
							echo '
							<td scope="row" class="row-sm-auto align-middle">
								<span class="ps-3">
									<i class="bi bi-dot"></i> '${txt_autopilot_disconnect_auto}'
								</span>
							</td>
							<td class="text-end">'
								echo -n '
								<a href="index.cgi?page=main&section=save&option=disconnect&'; \
									if [[ "${disconnect}" == "auto" ]]; then
										echo -n 'query="><img src="images/toggle-on.png">'
									else
										echo -n 'query=auto"><img src="images/toggle-off.png">'
									fi
									echo -n '
								</a>
							</td>
						</tr>
						<tr>'
							# Manuell auswerfen ein/aus
							echo '
							<td scope="row" class="row-sm-auto align-middle">
								<span class="ps-3">
									<i class="bi bi-dot"></i> '${txt_autopilot_disconnect_manual}'
								</span>
							</td>
							<td class="text-end">'
								echo -n '
								<a href="index.cgi?page=main&section=save&option=disconnect&'; \
									if [[ "${disconnect}" == "manual" ]]; then
										echo -n 'query="><img src="images/toggle-on.png">'
									else
										echo -n 'query=manual"><img src="images/toggle-off.png">'
									fi
									echo -n '
								</a>
							</td>
						</tr>
						<tr>'
							# Optische und akustische Signalausgabe ein/aus
							echo '
							<td scope="row" class="row-sm-auto align-middle">
								'${txt_autopilot_signal}'
							</td>
							<td class="text-end">'
								echo -n '
								<a href="index.cgi?page=main&section=save&option=signal&'; \
									if [[ "${signal}" == "true" ]]; then
										echo -n 'query="><img src="images/toggle-on.png">'
									else
										echo -n 'query=true"><img src="images/toggle-off.png">'
									fi
									echo -n '
								</a>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>'
fi

# autoconfig - Speichern
# --------------------------------------------------------------
if [[ "${get[page]}" == "main" && "${get[section]}" == "save" ]]; then
	[ -f "${get_request}" ] && rm "${get_request}"

	# Speichern der Einstellungen nach ${app_home}/settings/user_settings.txt
	[[ "${get[option]}" == "connect" ]] && "${set_keyvalue}" "${usr_autoconfig}" "connect" "${get[query]}"
	[[ "${get[option]}" == "disconnect" ]] && "${set_keyvalue}" "${usr_autoconfig}" "disconnect" "${get[query]}"
	[[ "${get[option]}" == "signal" ]] && "${set_keyvalue}" "${usr_autoconfig}" "signal" "${get[query]}"
	echo '<meta http-equiv="refresh" content="0; url=index.cgi?page=main&section=start">'
fi
