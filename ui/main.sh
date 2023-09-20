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

# Funktion: Lokales Datenträger-Ziel auswählen
# --------------------------------------------------------------
function local_target()
{
	while IFS= read -r volume; do
		IFS="${backupIFS}"
		[[ -z "${volume}" ]] && continue
		while IFS= read -r share; do
			IFS="${backupIFS}"
			[[ -z "${share}" ]] && continue
			echo -n '<option value="'${share}'"'; \
				[[ "${var[${2}]}" == "${share}" ]] && echo -n ' selected>' || echo -n '>'
			echo ''${share}'</option>'
		done <<< "$( find ${volume}/* -type d ! -path '*/lost\+found' ! -path '*/\@*' ! -path '*/\$RECYCLE.BIN' ! -path '*/Repair' ! -path '*/recovery Volume Information' -maxdepth 0 )"
	done <<< "$( find ${1} -maxdepth 0 -type d )"
	unset volume share
}

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
	if [ -z "${permissions}" ] || [[ "${permissions}" == "false" ]]; then
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
											<a href="#help-permissions" class="btn btn-sm text-dark text-decoration-none" style="background-color: #e6e6e6;" data-bs-toggle="modal" data-bs-target="#help-app_permissions">'${txt_button_extend_permission}'</a>
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

	# Überprüfen des UDEV-Gerätetreibers
	# --------------------------------------------------------------
	if [ -z "${udev_rule}" ] || [[ "${udev_rule}" == "false" ]] || [[ "${rewrite_udev}" == "true" ]]; then
		echo '
		<div class="row">
			<div class="col-sm-12">
				<div class="card">
					<div class="card-header bg-danger-subtle"><strong>'${txt_udev_status}'</strong></div>
 					<div class="card-body">
						<table class="table table-borderless table-sm mb-0">
							<thead></thead>
							<tbody>
								<tr>
									<td scope="row" class="row-sm-auto">'${txt_udev_status_false}'
										<td class="text-end"> 
											<a href="#help-udev_device_driver" class="btn btn-sm text-dark text-decoration-none" style="background-color: #e6e6e6;" data-bs-toggle="modal" data-bs-target="#help-udev_device_driver">'${txt_button_install}'</a>
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

	# Externe Datenträger
	# --------------------------------------------------------------
	echo '
	<div class="accordion accordion-flush" id="accordionFlush01">
		<div class="accordion-item border-0">
			<div class="accordion-header bg-light p-2">
				<button class="btn btn-sm text-dark py-0 collapsed" style="background-color: #e6e6e6;" type="button" data-bs-toggle="collapse" data-bs-target="#flush-collapse-01" aria-expanded="false" aria-controls="flush-collapse-01">
					<i class="bi bi-caret-down-fill pe-2" style="font-size: 0.9rem;" title=""></i><i class="bi bi-usb-symbol" style="font-size: 1.2rem;" title=""></i>
				</button>&nbsp;
				'${txt_external_disks_header}'
			</div>
			<div id="flush-collapse-01" class="accordion-collapse collapse" data-bs-parent="#accordionFlush01">
				<div class="accordion-body bg-light">'
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
										<td class="bg-light" style="width: 160px">
											<i class="bi bi-hdd-fill text-secondary"></i>&nbsp;&nbsp;'${volume#*/}'
										</td>
										<td class="bg-light" style="width: 120px">
											'${txt_autopilot_device}'
										</td>
										<td class="bg-light" style="width: auto">
											'${txt_autopilot_memory}'
										</td>
										<td class="bg-light" style="width: 40px">
											&nbsp;
										</td>
										<td class="bg-light text-center" style="width: 120px">
											AutoPilot Script
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
											<td class="bg-light ps-4" style="width: 160px">&nbsp;&nbsp;
												<i class="bi bi-folder-fill text-warning"></i>&nbsp;&nbsp;'${share##*/}'
											</td>
											<td class="bg-light" style="width: 120px">'
												#[ -f "${path}/autopilot" ] && echo '<span class="text-success">'${txt_autopilot_script_detected}'</span>'
												echo ''${dev}''
												echo '
											</td>
											<td class="bg-light" style="width: auto">
												<div class="progress" role="progressbar" aria-label="Example with label" aria-valuenow="10" aria-valuemin="0" aria-valuemax="100" style="height: 25px">
													<div class="progress-bar overflow-visible text-dark bg-primary-subtle" style="width: '${disk_used_percent}'%">&nbsp;&nbsp;&nbsp;'${disk_used_percent}'% '${txt_autopilot_from}' '${disk_free}' '${txt_autopilot_use}'</div>
												</div>
											</td>
											<td class="bg-light" style="width: 40px">
												&nbsp;
											</td>
											<td class="bg-light text-end pe-4" style="width: 120px">'
												if [ -f "${volume}/${share##*/}/autopilot" ]; then
													echo '
													<a class="btn btn-sm text-dark py-0" style="background-color: #e6e6e6;" href="index.cgi?page=main&section=view&share='${volume}/${share##*/}'">
														<i class="bi bi-terminal-fill" style="font-size: 1.2rem;" title="'${txt_autopilot_script_view}'"></i>
													</a>'
													echo '
													<a class="btn btn-sm text-dark py-0" style="background-color: #e6e6e6;" href="index.cgi?page=main&section=delete&share='${volume}/${share##*/}'">
														<i class="bi bi-trash text-danger" style="font-size: 1.2rem;" title="'${txt_autopilot_script_delete}'"></i>
													</a>'
												else
													echo '
													<a class="btn btn-sm text-dark py-0" style="background-color: #e6e6e6;" href="index.cgi?page=main&section=create&share='${volume}/${share##*/}'">
														<i class="bi bi-file-earmark-plus text-success" style="font-size: 1.2rem;" title="'${txt_autopilot_script_create}'"></i>
													</a>'
												fi
												echo '
											</td>
										</tr>'
									done <<< "$( find ${volume}/* -maxdepth 0 -type d ! -path '*/lost\+found' ! -path '*/\@*' ! -path '*/\$RECYCLE.BIN' ! -path '*/Repair' ! -path '*/System Volume Information' )"
									echo '<tr><td class="bg-light" colspan=5>&nbsp;</td></tr>'
								done <<< "$( find ${1} -type d -maxdepth 0 )"
								echo '
							</tbody>
						</table>'
						unset volume share
					}
					local_sources "/volumeUSB[[:digit:]]"
					local_sources "/volumeSATA[[:digit:]]"
					echo '	
				</div>
			</div>
		</div>'	

		# Basic Backup Aufträge
		# --------------------------------------------------------------
		if [ -d /var/packages/BasicBackup ] && [[ "${permissions}" == "true" ]]; then
			echo '
			<div class="accordion-item border-0 mt-3">
				<div class="accordion-header bg-light p-2">
					<button class="btn btn-sm text-dark py-0 collapsed" style="background-color: #e6e6e6;" type="button" data-bs-toggle="collapse" data-bs-target="#flush-collapse-02" aria-expanded="false" aria-controls="flush-collapse-02">
						<i class="bi bi-caret-down-fill pe-2" style="font-size: 0.9rem;" title=""></i><i class="bi bi-list" style="font-size: 1.2rem;" title=""></i>
					</button>&nbsp;
					'${txt_basicbackup_header}'
				</div>
				<div id="flush-collapse-02" class="accordion-collapse collapse" data-bs-parent="#accordionFlush01">
					<div class="accordion-body bg-light">
						<div class="accordion accordion-flush" id="accordionLoop02">'
							backupconfigs=$(find "/var/packages/BasicBackup/target/ui/usersettings/backupjobs" -type f -name "*.config" -maxdepth 1 | sort)
							if [ -n "$backupconfigs" ]; then
								id=0
								IFS="
								"
								for backupconfig in ${backupconfigs}; do
									IFS="$backupIFS"
									[ -f "${backupconfig}" ] && source "${backupconfig}"
									backupjob=$(echo "${backupconfig##*/}")
									backupjob=$(echo "${backupjob%.*}")
									echo '
									<div class="accordion-item bg-light pt-2 pb-3">
										'${backupjob}'
										<div class="float-end">

											<!-- Modal Button-->
											<button type="button" class="btn btn-sm text-dark py-0" style="background-color: #e6e6e6;" data-bs-toggle="modal" data-bs-target="#BasicBackup'${id}'">
												<i class="bi bi-file-earmark-plus text-success" style="font-size: 1.2rem;" title="'${txt_basicbackup_title_create_script}'"></i>
											</button>&nbsp;

											<!-- Modal Popup-->
											<div class="modal fade" id="BasicBackup'${id}'" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="BasicBackup'${id}'Label" aria-hidden="true">
												<div class="modal-dialog">
													<div class="modal-content">
														<div class="modal-header bg-light">
															<h1 class="modal-title align-baseline fs-5" style="color: #FF8C00;" id="BasicBackup'${id}'Label">'${txt_autopilot_create_script}'</h1>
															<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
														</div>
														<form action="index.cgi?page=main" method="post" id="form'${id}'" autocomplete="on">
															<div class="modal-body">
																'${txt_basicbackup_package_name}': <span class="text-secondary">Basic Backup</span><br />
																'${txt_basicbackup_job_name}': <span class="text-secondary">'${backupjob}'</span><br />
																'${txt_autopilot_script_name}': <span class="text-secondary"> autopilot</span><br />
																<br />
																<label for="externaldisk" class="form-label">'${txt_autopilot_script_target}'</label>
																	<select id="externaldisk" name="externaldisk" class="form-select form-select-sm" required>
																		<option value="" class="text-secondary" selected disabled>'${txt_autopilot_select_external_disk}'</option>'
																			local_target "/volumeUSB[[:digit:]]"
																			local_target "/volumeSATA[[:digit:]]"
																			echo '
																	</select>
																	<div class="text-center pt-2">
																		<small>'${txt_autopilot_note_script_overwrite}'</small>
																	</div>
															</div>
															<div class="modal-footer bg-light">
																<input type="hidden" name="jobname" value="'${backupjob}'">
																<button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">'${txt_button_Cancel}'</button><br />
																<button class="btn btn-secondary btn-sm" type="submit" name="section" value="basicbackup">'${txt_button_Save}'</button>
															</div>
														</form>
													</div>
												</div>
											</div>
											<script type="text/javascript">
												$(window).on("load", function() {
													$("#popup-validation").modal("show");
												});
											</script>

											<!-- Script Button -->
											<button class="btn btn-sm text-dark py-0 collapsed" style="background-color: #e6e6e6;" type="button" data-bs-toggle="collapse" data-bs-target="#loop-collapse'${id}'" aria-expanded="false" aria-controls="loop-collapse'${id}'">
												<i class="bi bi-terminal-fill" style="font-size: 1.2rem;" title="'${txt_basicbackup_title_view_script}'"></i>
											</button>
										</div>
										<div id="loop-collapse'${id}'" class="accordion-collapse collapse" data-bs-parent="#accordionLoop02">
											<div class="accordion-body">
												<div class="card card-body ps-1">
													<code class="text-dark">
														#!/bin/bash<br />
														# Execute a Basic Backup job<br />
														# Job name: '${backupjob}'<br />
														<br />
														/usr/syno/synoman/webman/3rdparty/BasicBackup/rsync.sh --job-name="'${backupjob}'"<br />
														exit ${?}
													</code>
												</div>
											</div>
										</div>
									</div>'
									id=$[${id}+1]
								done
								IFS="${backupIFS}"
								unset backupjob
							fi
							echo '
						</div>
					</div>
				</div>
			</div>'
		fi

		# Hyper Backup Aufträge
		# --------------------------------------------------------------
		if [ -d /var/packages/HyperBackup ] && [[ "${permissions}" == "true" ]]; then
			echo '
			<div class="accordion-item border-0 mt-3">
				<div class="accordion-header bg-light p-2">
					<button class="btn btn-sm text-dark py-0 collapsed" style="background-color: #e6e6e6;" type="button" data-bs-toggle="collapse" data-bs-target="#flush-collapse-03" aria-expanded="false" aria-controls="flush-collapse-03">
						<i class="bi bi-caret-down-fill pe-2" style="font-size: 0.9rem;" title=""></i><i class="bi bi-list" style="font-size: 1.2rem;" title=""></i>
					</button>&nbsp;
					'${txt_hyperbackup_header}'
				</div>
				<div id="flush-collapse-03" class="accordion-collapse collapse" data-bs-parent="#accordionFlush01">
					<div class="accordion-body bg-light">
						<div class="accordion accordion-flush" id="accordionLoop03">'
							IFS="
							"
							declare -A hyper_backup_job=()
							loop_idx=0
							idx=0
							for item in $(sed -nE '/^[task_[0-9]+]$/,/^[repo_[0-9]+]$/p' /usr/syno/etc/packages/HyperBackup/synobackup.conf \
								| grep -E "task_[0-9]+|name=" \
								| sed -E 's/\[task_([0-9]+)\]/\1/' \
								| sed -E 's/name="(.+)"/\1/'); do

								if ! (( "$loop_idx" % 2 )); then
									hyper_backup_job[$idx]="$item"
								else
									hyper_backup_job[$idx]="${hyper_backup_job[$idx]}""=""$item"
									idx=$((idx+1))
								fi
								loop_idx=$((loop_idx+1))
							done
							id=0
								# OUtput line by line via loop over all elements
								for ((i=0; i < ${#hyper_backup_job[@]}; i++ )); do
									echo '
									<div class="accordion-item bg-light pt-2 pb-3">
										'${hyper_backup_job[$i]#*=}'
										<div class="float-end">

											<!-- Modal Button-->
											<button type="button" class="btn btn-sm text-dark py-0" style="background-color: #e6e6e6;" data-bs-toggle="modal" data-bs-target="#HyperBackup'${id}'">
												<i class="bi bi-file-earmark-plus text-success" style="font-size: 1.2rem;" title="'${txt_hyperbackup_title_create_script}'"></i>
											</button>&nbsp;

											<!-- Modal Popup-->
											<div class="modal fade" id="HyperBackup'${id}'" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="HyperBackup'${id}'Label" aria-hidden="true">
												<div class="modal-dialog">
													<div class="modal-content">
														<div class="modal-header bg-light">
															<h1 class="modal-title align-baseline fs-5" style="color: #FF8C00;" id="HyperBackup'${id}'Label">'${txt_autopilot_create_script}'</h1>
															<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
														</div>
														<form action="index.cgi?page=main" method="post" id="form'${id}'" autocomplete="on">
															<div class="modal-body">
																'${txt_hyperbackup_package_name}': <span class="text-secondary">Hyper Backup</span><br />
																Task ID: <span class="text-secondary">'${hyper_backup_job[$i]%=*}'</span><br />
																'${txt_hyperbackup_job_name}': <span class="text-secondary">'${hyper_backup_job[$i]#*=}'</span><br />
																'${txt_autopilot_script_name}': <span class="text-secondary"> autopilot</span><br />
																<br />
																<label for="externaldisk" class="form-label">'${txt_autopilot_script_target}'</label>
																	<select id="externaldisk" name="externaldisk" class="form-select form-select-sm" required>
																		<option value="" class="text-secondary" selected disabled>'${txt_autopilot_select_external_disk}'</option>'
																			local_target "/volumeUSB[[:digit:]]"
																			local_target "/volumeSATA[[:digit:]]"
																			echo '
																	</select>
																	<div class="text-center pt-2">
																		<small>'${txt_autopilot_note_script_overwrite}'</small>
																	</div>
															</div>
															<div class="modal-footer bg-light">
																<input type="hidden" name="jobname" value="'${hyper_backup_job[$i]#*=}'">
																<input type="hidden" name="taskid" value="'${hyper_backup_job[$i]%=*}'">
																<button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">'${txt_button_Cancel}'</button><br />
																<button class="btn btn-secondary btn-sm" type="submit" name="section" value="hyperbackup">'${txt_button_Save}'</button>
															</div>
														</form>
													</div>
												</div>
											</div>
											<script type="text/javascript">
												$(window).on("load", function() {
													$("#popup-validation").modal("show");
												});
											</script>

											<!-- Script Button -->
											<button class="btn btn-sm text-dark py-0 collapsed" style="background-color: #e6e6e6;" type="button" data-bs-toggle="collapse" data-bs-target="#loop-collapse'${id}'" aria-expanded="false" aria-controls="loop-collapse'${id}'">
												<i class="bi bi-terminal-fill" style="font-size: 1.2rem;" title="'${txt_hyperbackup_title_view_script}'"></i>
											</button>
										</div>
										<div id="loop-collapse'${id}'" class="accordion-collapse collapse" data-bs-parent="#accordionLoop03">
											<div class="accordion-body">
												<div class="card card-body ps-1">
													<code class="text-dark">
														#!/bin/bash<br />
														# Execute a Hyper Backup task<br />
														# Task ID: '${hyper_backup_job[$i]%=*}'<br />
														# Task name: '${hyper_backup_job[$i]#*=}'<br />
														<br />
														/var/packages/HyperBackup/target/bin/dsmbackup --backup "'${hyper_backup_job[$i]%=*}'"<br />
														pid=$(ps aux | grep -v grep | grep -E "/var/packages/HyperBackup/target/bin/(img_backup|dsmbackup|synoimgbkptool|synolocalbkp|synonetbkp|updatebackup).+-k '${hyper_backup_job[$i]%=*}'" | awk '{print \$2}')<br />
														while ps -p $pid > /dev/null<br />
														do<br />
														&nbsp;&nbsp;&nbsp;&nbsp;sleep 60<br />
														done<br />
														exit ${?}
													</code>
												</div>
											</div>
										</div>
									</div>'
									id=$[${id}+1]
								done
								echo '
							</div>'

							IFS="${backupIFS}"
							echo '	
					</div>
				</div>
			</div>'
		fi
		echo '
	</div>'

		# AutoPilot Einstellungen
		# --------------------------------------------------
		echo '
		<div class="accordion-item border-0 mt-3">
			<div class="accordion-header bg-light p-2">
				<button class="btn btn-sm text-dark py-0 collapsed" style="background-color: #e6e6e6;" type="button" data-bs-toggle="collapse" data-bs-target="#flush-collapse-04" aria-expanded="true" aria-controls="flush-collapse-04">
					<i class="bi bi-caret-down-fill pe-2" style="font-size: 0.9rem;" title=""></i><i class="bi bi-gear-fill" style="font-size: 1.2rem;" title=""></i>
				</button>&nbsp;
				'${txt_autopilot_options_header}'
			</div>
		<div id="flush-collapse-04" class="accordion-collapse collapse show" data-bs-parent="#accordionFlush01">
			<div class="accordion-body bg-light px-3">
				<table class="table table-borderless table-sm">
					<thead></thead>
					<tbody>
						<tr>'
							# Einhängen ein/aus
							echo -n '
							<td scope="row" class="row-sm-auto align-middle bg-light">
								'${txt_autopilot_connect}'
							</td>
							<td class="text-end bg-light">'
								echo -n '
								<a href="index.cgi?page=main&section=settings&switch=connect&'; \
									if [[ "${connect}" == "true" ]]; then
										echo -n 'query=false"><img src="images/toggle-on.png">'
									else
										echo -n 'query=true"><img src="images/toggle-off.png">'
									fi
									echo -n '
								</a>
							</td>
						</tr>
					</tbody>
				</table>
				<div class="ps-1 pb-3">'${txt_autopilot_disconnect}'</div>
				<table class="table table-borderless table-sm">
					<thead></thead>
					<tbody>
						<tr>'
							# Niemals auswerfen ein/aus
							echo '
							<td scope="row" class="row-sm-auto align-middle bg-light">
								<span class="ps-3">
									<i class="bi bi-dot"></i> '${txt_autopilot_disconnect_never}'
								</span>
							</td>
							<td class="text-end bg-light">'
								echo -n '
								<a href="index.cgi?page=main&section=settings&switch=disconnect&'; \
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
							<td scope="row" class="row-sm-auto align-middle bg-light">
								<span class="ps-3">
									<i class="bi bi-dot"></i> '${txt_autopilot_disconnect_auto}'
								</span>
							</td>
							<td class="text-end bg-light">'
								echo -n '
								<a href="index.cgi?page=main&section=settings&switch=disconnect&'; \
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
							<td scope="row" class="row-sm-auto align-middle bg-light">
								<span class="ps-3">
									<i class="bi bi-dot"></i> '${txt_autopilot_disconnect_manual}'
								</span>
							</td>
							<td class="text-end bg-light">'
								echo -n '
								<a href="index.cgi?page=main&section=settings&switch=disconnect&'; \
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
							<td scope="row" class="row-sm-auto align-middle bg-light">
								'${txt_autopilot_signal}'
							</td>
							<td class="text-end bg-light">'
								echo -n '
								<a href="index.cgi?page=main&section=settings&switch=signal&'; \
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
		echo '
	</div><br />'
fi

# AutoPilot Script auf ext. Datenträger erstellen
# --------------------------------------------------------------
if [[ "${get[page]}" == "main" && "${get[section]}" == "create" ]]; then
	target="${get[share]}/autopilot"

	if [ ! -f "${target}" ]; then
		touch "${target}"
		chmod 777 "${target}"
	fi
	if [ -f "${target}" ]; then
		> "${target}"
		echo "#!/bin/bash" > "${target}"
	fi

	[ -f "${get_request}" ] && rm "${get_request}"
	echo '<meta http-equiv="refresh" content="0; url=index.cgi?page=main&section=start">'
fi

# AutoPilot Script auf ext. Datenträger ansehen
# --------------------------------------------------------------
if [[ "${get[page]}" == "main" && "${get[section]}" == "view" ]]; then
	target="${get[share]}/autopilot"
	view=$(cat "${target}")

	if [ -f "${target}" ]; then
		popup_modal "view" "AutoPilot Scriptdatei ansehen" "${target}"
	fi

	#[ -f "${get_request}" ] && rm "${get_request}"
	#echo '<meta http-equiv="refresh" content="0; url=index.cgi?page=main&section=start">'
fi

# AutoPilot Script vom ext. Datenträger löschen
# --------------------------------------------------------------
if [[ "${get[page]}" == "main" && "${get[section]}" == "delete" ]]; then
	target="${get[share]}/autopilot"

	if [ -f "${target}" ]; then
		rm "${target}"
	fi

	[ -f "${get_request}" ] && rm "${get_request}"
	echo '<meta http-equiv="refresh" content="0; url=index.cgi?page=main&section=start">'
fi

# AutoPilot Konfiguration speichern
# --------------------------------------------------------------
if [[ "${get[page]}" == "main" && "${get[section]}" == "settings" ]]; then
	[ -f "${get_request}" ] && rm "${get_request}"

	# Speichern der Einstellungen nach ${app_home}/settings/user_settings.txt
	[[ "${get[switch]}" == "connect" ]] && "${set_keyvalue}" "${usr_autoconfig}" "connect" "${get[query]}"
	[[ "${get[switch]}" == "disconnect" ]] && "${set_keyvalue}" "${usr_autoconfig}" "disconnect" "${get[query]}"
	[[ "${get[switch]}" == "signal" ]] && "${set_keyvalue}" "${usr_autoconfig}" "signal" "${get[query]}"
	echo '<meta http-equiv="refresh" content="0; url=index.cgi?page=main&section=start">'
fi

# Basic Backup Script anlegen
# --------------------------------------------------------------
if [[ "${get[page]}" == "main" && "${post[section]}" == "basicbackup" ]]; then
	
	target="${post[externaldisk]}/autopilot"
	jobname="${post[jobname]}"

	if [ ! -f "${target}" ]; then
		touch "${target}"
		chmod 777 "${target}"
	fi
	if [ -f "${target}" ]; then
		> "${target}"
		echo "#!/bin/bash" > "${target}"
		echo "# Execute a Basic Backup job" >> "${target}"
		echo "# Job name: ${jobname}" >> "${target}"
		echo "" >> "${target}"
		echo "/usr/syno/synoman/webman/3rdparty/BasicBackup/rsync.sh --job-name=\"${jobname}\"" >> "${target}"
		echo "exit \${?}" >> "${target}"
		[ -f "${get_request}" ] && rm "${get_request}"
		[ -f "${post_request}" ] && rm "${post_request}"
		echo '<meta http-equiv="refresh" content="0; url=index.cgi?page=main&section=start">'
	fi
fi

# Hyper Backup Script anlegen
# --------------------------------------------------------------
if [[ "${get[page]}" == "main" && "${post[section]}" == "hyperbackup" ]]; then
	
	target="${post[externaldisk]}/autopilot"
	jobname="${post[jobname]}"
	taskid="${post[taskid]}"

	if [ ! -f "${target}" ]; then
		touch "${target}"
		chmod 777 "${target}"
	fi
	if [ -f "${target}" ]; then
		> "${target}"
		echo "#!/bin/bash" > "${target}"
		echo "# Execute a Hyper Backup task" >> "${target}"
		echo "# Task ID: ${taskid}" >> "${target}"
		echo "# Task name: ${jobname}" >> "${target}"
		echo "" >> "${target}"
		echo "/var/packages/HyperBackup/target/bin/dsmbackup --backup \"${taskid}\"" >> "${target}"
		echo "pid=\$(ps aux | grep -v grep | grep -E \"/var/packages/HyperBackup/target/bin/(img_backup|dsmbackup|synoimgbkptool|synolocalbkp|synonetbkp|updatebackup).+-k ${taskid}\" | awk '{print \$2}')" >> "${target}"
		echo "while ps -p \$pid > /dev/null" >> "${target}"
		echo "do" >> "${target}"
		echo "    sleep 60" >> "${target}"
		echo "done" >> "${target}"
		echo "exit \${?}" >> "${target}"
		[ -f "${get_request}" ] && rm "${get_request}"
		[ -f "${post_request}" ] && rm "${post_request}"
		echo '<meta http-equiv="refresh" content="0; url=index.cgi?page=main&section=start">'
	fi
fi
