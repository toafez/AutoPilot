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
			echo ''${share##*/}'</option>'
		done <<< "$( find ${volume}/* -type d ! -path '*/lost\+found' ! -path '*/\@*' ! -path '*/\$RECYCLE.BIN' ! -path '*/Repair' ! -path '*/recovery Volume Information' -maxdepth 0 )"
	done <<< "$( find ${1} -maxdepth 0 -type d )"
	unset volume share
}

# Funktion: Ext. Datenträger-Ziel auswählen
# --------------------------------------------------------------
function external_target()
{
	while IFS= read -r volume; do
		IFS="${backupIFS}"
		[[ -z "${volume}" ]] && continue
		while IFS= read -r share; do
			IFS="${backupIFS}"
			[[ -z "${share}" ]] && continue
			if [[ "${share}" == "${3}" ]]; then
				echo -n '<option value="'${share}'"'; \
					[[ "${var[${2}]}" == "${share}" ]] && echo -n ' selected>' || echo -n '>'
				echo ''${share##*/}'</option>'
			fi
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
			<div class="card">
				<div class="card-header bg-danger-subtle"><strong>'${txt_update_available}'</strong></div>
				<div class="card-body">'${txt_update_from}'<span class="text-danger"> '${local_version}' </span>'${txt_update_to}'<span class="text-success"> '${git_version}'</span>
					<div class="float-end">
						<a href="https://github.com/toafez/'${app_name}'/releases" class="btn btn-sm text-dark text-decoration-none" style="background-color: #e6e6e6;" target="_blank">Update</a>
					</div>
				</div>
			</div><br />'
		fi
	fi

	# Überprüfen der App-Berechtigung
	# --------------------------------------------------------------
	if [ -z "${permissions}" ] || [[ "${permissions}" == "false" ]]; then
		echo '
		<div class="card">
			<div class="card-header bg-danger-subtle"><strong>'${txt_group_status}'</strong></div>
			<div class="card-body">'${txt_group_status_false}'
				<div class="float-end">
					<a href="#help-permissions" class="btn btn-sm text-dark text-decoration-none" style="background-color: #e6e6e6;" data-bs-toggle="modal" data-bs-target="#help-app_permissions">'${txt_button_extend_permission}'</a>
				</div>
			</div>
		</div><br />'
	fi

	# Überprüfen des UDEV-Gerätetreibers
	# --------------------------------------------------------------
	if [ -z "${udev_rule}" ] || [[ "${udev_rule}" == "false" ]] || [[ "${rewrite_udev}" == "true" ]]; then
		echo '
		<div class="card">
			<div class="card-header bg-danger-subtle"><strong>'${txt_udev_status}'</strong></div>
			<div class="card-body">'${txt_udev_status_false}'
				<div class="float-end">
					<a href="#help-udev_device_driver" class="btn btn-sm text-dark text-decoration-none" style="background-color: #e6e6e6;" data-bs-toggle="modal" data-bs-target="#help-udev_device_driver">'${txt_button_install}'</a>
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
					<i class="bi bi-caret-down-fill pe-2" style="font-size: 0.9rem;"></i><span class="fs-5 pe-1">|</span><i class="bi bi-usb-symbol py-2" style="font-size: 1.2rem;"></i>
				</button>
				<span class="ps-2">'${txt_external_disks_header}'</span>
			</div>
			<div id="flush-collapse-01" class="accordion-collapse collapse" data-bs-parent="#accordionFlush01">
				<div class="accordion-body bg-light px-3 py-0 ps-5">'
					function ext_sources()
					{
						echo '
						<table class="table table-borderless table-sm table-light">
							<thead>
								<tr>
									<th scope="col" style="width: 160px;">&nbsp;</th>
									<th scope="col" style="width: 250px;">&nbsp;</th>
									<th scope="col" style="width: auto;">&nbsp;</th>
									<th scope="col" style="width: 20px;">&nbsp;</th>
									<th scope="col" style="width: 120px;">&nbsp;</th>
								</tr>
							</thead>
							<tbody>'
								ext_id=0
								while IFS= read -r ext_volume; do
									IFS="${backupIFS}"
									[[ -z "${ext_volume}" ]] && continue

									while IFS= read -r ext_share; do
										IFS="${backupIFS}"
										[[ -z "${ext_share}" ]] && continue
										ext_mountpoint=$(mount | grep -E "${ext_volume}/${ext_share##*/}")
										ext_dev=$(echo "${ext_mountpoint}" | awk '{print $1}')
										ext_path=$(echo "${ext_mountpoint}" | awk '{print $3}')
										ext_uuid=$(blkid -s UUID -o value ${ext_dev})
										ext_type=$(blkid -s TYPE -o value ${ext_dev})
										ext_label=$(blkid -s LABEL -o value ${ext_dev})
										[[ -z "${ext_dev}" ]] && continue

										ext_df=$(df -BG "${ext_path}")
										ext_df=$(echo "${ext_df}" | sed -e 's/%//g' | awk 'NR > 1 {print $2 " " $3 " " $4 " " $5 " " $6}')
										ext_disk_free=$(echo "${ext_df}" | awk '{print $1}' | sed -e 's/G/ GB/g')
										#ext_disk_used=$(echo "${ext_df}" | awk '{print $2}' | sed -e 's/G/ GB/g')
										#ext_disk_available=$(echo "${ext_df}" | awk '{print $3}' | sed -e 's/G/ GB/g')
										ext_disk_used_percent=$(echo "${ext_df}" | awk '{print $4}')
										#ext_disk_mountpoint=$(echo "$ext_df" | awk '{print $5}')

										# Bestimmen des Dateisystems, wenn eine 128-Bit UUID ermittelt wurde (Linux/Unix)
										if [[ "${ext_uuid}" =~ ^\{?[A-F0-9a-f]{8}-[A-F0-9a-f]{4}-[A-F0-9a-f]{4}-[A-F0-9a-f]{4}-[A-F0-9a-f]{12}\}?$ ]]; then
											ext_guid="true"
											txt_volume_id="Universally Unique Identifier (UUID)"
										# Bestimmen des Dateisystems, wenn eine 64-Bit VSN ermittelt wurde (NTFS)
										elif [[ "${ext_uuid}" =~ ^\{?[A-F0-9a-f]{16}\}?$ ]]; then
											ext_guid="true"
											txt_volume_id="Volume Serial Number (VSN)"
										# Bestimmen des Dateisystems, wenn eine 32-Bit VSN ermittelt wurde (Windows FAT12, FAT16, FAT32 und exFAT) zusammengefasst als vFAT
										elif [[ "${ext_uuid}" =~ ^\{?[A-F0-9a-f]{4}-[A-F0-9a-f]{4}\}?$ ]] || [[ "${ext_uuid}" =~ ^\{?[A-F0-9a-f]{8}\}?$ ]]; then
											ext_guid="true"
											txt_volume_id="Volume Serial Number (VSN)"
										else
											ext_guid="false"
											txt_volume_id="Unique Identifier (UUID/GUID)"
											txt_volume_id_failed="<span class=\"text-danger\">Could not be read</span>"
										fi

										# Lege den Pfad zur gleichnamigen, intern abgelegten UUID-Scriptdatei fest
										[[ "${ext_guid}" == "true" ]] && uuidfile="${usr_devices}/${ext_uuid}"

										echo '
										<tr>
											<td colspan="4">
												<i class="bi bi-hdd-fill text-secondary me-2"></i><span class="fw-medium">'${ext_volume#*/}'</span>
											</td>
											<td class="text-end pe-4">'
												# Wenn autopilot Scriptdatei existiert leer ist und interne UUID/GUID Datei existiert, dann...
												if [ ! -s "${ext_volume}/${ext_share##*/}/autopilot" ] && [ -f "${uuidfile}" ]; then
													echo '
													<a class="btn btn-sm text-dark py-0" style="background-color: #e6e6e6;" href="index.cgi?page=main&section=view&extpath='${ext_path}'&extuuid='${ext_uuid}'">
														<i class="bi bi-terminal-fill" style="font-size: 1.2rem;" title="'${txt_autopilot_script_view}'"></i>
													</a>
													<a class="btn btn-sm text-dark py-0" style="background-color: #e6e6e6;" href="index.cgi?page=main&section=delete&extpath='${ext_path}'&extuuid='${ext_uuid}'">
														<i class="bi bi-trash text-danger" style="font-size: 1.2rem;" title="'${txt_autopilot_script_delete}'"></i>
													</a>'
												# Wenn autopilot Scriptdatei existiert aber nicht leer ist, dann...
												elif [ -s "${ext_volume}/${ext_share##*/}/autopilot" ]; then
													echo '
													<a class="btn btn-sm text-danger py-0" style="background-color: #e6e6e6;" href="index.cgi?page=main&section=view&extpath='${ext_volume}/${ext_share##*/}'&extuuid=">
														<i class="bi bi-exclamation-triangle" style="font-size: 1.2rem;" title="'${txt_autopilot_autopilot_view}'"></i>
													</a>'
												# Wenn autopilot Scriptdatei existiert, leer ist und UUID/GUID gelesen werden konnte dann...
												elif [ -s "${ext_volume}/${ext_share##*/}/autopilot" ] && [ -f "${uuidfile}" ]; then
													# Ist die Startdatei autopilot auf dem ext. Datenträger nicht vorhanden, dann lösche den zugehörigen Device Eintrag 
													if [ ! -f "${ext_volume}/${ext_share##*/}/autopilot" ]; then
														rm /volume*/@appstore/AutoPilot/ui/usersettings/devices/${ext_uuid}
													fi
													echo '
													<!-- Modal Button-->
													<button type="button" class="btn btn-sm text-dark py-0" style="background-color: #e6e6e6;" data-bs-toggle="modal" data-bs-target="#ExternalDisk'${ext_id}'">
														<i class="bi bi-link-45deg text-success" style="font-size: 1.2rem;" title="'${txt_autopilot_script_create}'"></i>
													</button>

													<!-- Modal Popup-->
													<div class="modal fade" id="ExternalDisk'${ext_id}'" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="ExternalDisk'${ext_id}'Label" aria-hidden="true">
														<div class="modal-dialog">
															<div class="modal-content">
																<div class="modal-header bg-light">
																	<h1 class="modal-title align-baseline fs-5" style="color: #FF8C00;" id="ExternalDisk'${ext_id}'Label">'${txt_autopilot_create_script}'</h1>
																	<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
																</div>
																<form action="index.cgi?page=main" method="post" id="form'${ext_id}'" autocomplete="on">
																	<div class="modal-body text-start">
																		'${txt_autopilot_create_disk_01}' '${ext_path}' '${txt_autopilot_create_disk_02}' '${ext_uuid}' '${txt_autopilot_create_disk_03}'<br />
																		<br />
																		<div class="row mb-3 px-1">
																			<div class="col">
																				<label for="sharedfolder" class="form-label">'${txt_autopilot_sharedfolder_label}'</label>
																					<select id="sharedfolder" name="sharedfolder" class="form-select form-select-sm" required>
																						<option value="" class="text-secondary" selected disabled></option>'
																							local_target "/volume[[:digit:]]*" "sharedfolder"
																							external_target "${ext_volume}*" "sharedfolder" "${ext_share}"
																							echo '
																					</select>
																			</div>
																			<div class="col">
																				<label for="targetfolder" class="form-label text-dark">'${txt_autopilot_targetfolder_label}'
																					<a class="text-danger text-decoration-none" data-bs-toggle="collapse" href="#targetfolder-note" role="button" aria-expanded="false" aria-controls="targetfolder-note">'${note}'</a>
																					<div class="collapse" id="targetfolder-note">
																						<div class="card card-body border-0">
																							<small>'${txt_autopilot_targetfolder_note}'</small>
																						</div>
																					</div>
																				</label>
																				<input type="text" pattern="'${txt_autopilot_targetfolder_regex}'" class="form-control form-control-sm" name="targetfolder" id="targetfolder" value="" placeholder="'${txt_autopilot_targetfolder_format}'" />
																			</div>
																		</div>
																		<div class="row mb-3 px-1">
																			<div class="col">
																				<label for="filename" class="form-label text-dark">'${txt_autopilot_filename_label}'
																					<a class="text-danger text-decoration-none" data-bs-toggle="collapse" href="#filename-note" role="button" aria-expanded="false" aria-controls="filename-note">'${note}'</a>
																					<div class="collapse" id="filename-note">
																						<div class="card card-body border-0">
																							<small>'${txt_autopilot_filename_note}'</small>
																						</div>
																					</div>
																				</label>
																				<div class="input-group">
																					<input type="text" pattern="'${txt_autopilot_filename_regex}'" class="form-control form-control-sm" name="filename" id="filename" value="" placeholder="autoscript01" required />
																					<span class="input-group-text" id="basic-addon2">.sh</span>
																				</div>
																				<div class="text-center pt-2">
																					<small>'${txt_autopilot_create_scriptfile_note}'</small>
																				</div>
																			</div>
																		</div>
																	</div>
																	<div class="modal-footer bg-light">
																		<input type="hidden" name="extuuid" value="'${ext_uuid}'">
																		<input type="hidden" name="extpath" value="'${ext_path}'">
																		<button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">'${txt_button_Cancel}'</button><br />
																		<button class="btn btn-secondary btn-sm" type="submit" name="section" value="autopilotscript">'${txt_button_Save}'</button>
																	</div>
																</form>
															</div>
														</div>
													</div>
													<script type="text/javascript">
														$(window).on("load", function() {
															$("#popup-validation").modal("show");
														});
													</script>'
												else
													echo '
													<span class="btn btn-sm text-dark py-0" style="background-color: #e6e6e6; cursor: default;">
														<i class="bi bi-file-earmark-x text-danger" style="font-size: 1.2rem;" title="'${txt_autopilot_autopilot_delete}'"></i>
													</span>'
												fi
												echo '
											</td>
										</tr>
										<tr>
											<td class="bg-light ps-4 me-2">
												<i class="bi bi-folder-fill text-warning me-2"></i>'${ext_share##*/}'
											</td>
											<td>'${txt_autopilot_disk_name}'</td>
											<td colspan="3">'${ext_label}'</td>
										</tr>
										<tr>
											<td>&nbsp;</td>
											<td>'${txt_autopilot_filesystem}'</td>
											<td colspan="3">'${ext_type}'</td>
										</tr>
										<tr>
											<td>&nbsp;</td>
											<td>'${txt_autopilot_device}'</td>
											<td colspan="3">'${ext_dev}'</td>
										</tr>'
										if [[ "${ext_guid}" == "true" ]]; then
											echo '
											<tr>
												<td>&nbsp;</td>
												<td>'${txt_volume_id}'</td>
												<td colspan="3">'${ext_uuid}'</td>
											</tr>'
										else
											echo '
											<tr>
												<td>&nbsp;</td>
												<td>'${txt_volume_id}'</td>
												<td colspan="3">'${txt_volume_id_failed}'</td>
											</tr>'
										fi
										echo '
										<tr>
											<td>&nbsp;</td>
											<td>'${txt_autopilot_memory}'</td>
											<td style="width: auto">
												<div class="progress" role="progressbar" aria-label="Example with label" aria-valuenow="10" aria-valuemin="0" aria-valuemax="100" style="height: 25px">
													<div class="progress-bar overflow-visible text-dark bg-primary-subtle ps-2" style="width: '${ext_disk_used_percent}'%">'${ext_disk_used_percent}'% '${txt_autopilot_from}' '${ext_disk_free}' '${txt_autopilot_use}'</div>
												</div>
											</td>
											<td colspan="2">&nbsp;</td>
										</tr>'
										uuidfile="${usr_devices}/${ext_uuid}"
										if [ -f "${uuidfile}" ]; then
											scriptfile=$(cat "${uuidfile}" | grep scriptpath | cut -d '"' -f2)
											echo '
											<tr>
												<td class="bg-light ps-4 me-2">
													<i class="bi bi-file-earmark text-dark me-2"></i>'${txt_autopilot_scriptfile}'
												</td>
												<td>'${txt_autopilot_scriptfile_path}'</td>
												<td colspan="3">'${scriptfile%/*}'</td>
											</tr>
											<tr>
												<td>&nbsp;</td>
												<td>'${txt_autopilot_scriptfile_name}'</td>
												<td colspan="3">'${scriptfile##*/}'</td>
											</tr>'
										fi
										echo '
										<tr>
											<td colspan="5">&nbsp;</td>
										</tr>'
										ext_id=$[${ext_id}+1]
									done <<< "$( find ${ext_volume}/* -maxdepth 0 -type d ! -path '*/lost\+found' ! -path '*/\@*' ! -path '*/\$RECYCLE.BIN' ! -path '*/Repair' ! -path '*/System Volume Information' )"
									unset ext_uuid extuuid 
								done <<< "$( find ${1} -type d -maxdepth 0 )"
								echo '
							</tbody>
						</table>'
						unset ext_volume ext_share
					}
					ext_sources "/volumeUSB[[:digit:]]"
					ext_sources "/volumeSATA[[:digit:]]"
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
						<i class="bi bi-caret-down-fill pe-2" style="font-size: 0.9rem;"></i><span class="fs-5 pe-1">|</span><i class="bi bi-list py-2" style="font-size: 1.2rem;"></i>
					</button>
					<span class="ps-2">'${txt_basicbackup_header}'</span>
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
									<div class="accordion-item bg-light pt-2 pb-3 ps-1 ms-4">
										'${backupjob}'
										<div class="float-end">

											<!-- Modal Button-->
											<button type="button" class="btn btn-sm text-dark py-0" style="background-color: #e6e6e6;" data-bs-toggle="modal" data-bs-target="#BasicBackup'${id}'">
												<i class="bi bi-link-45deg text-success" style="font-size: 1.2rem;" title="'${txt_autopilot_create_this_script}'"></i>
											</button>

											<!-- Modal Popup-->
											<div class="modal fade" id="BasicBackup'${id}'" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="BasicBackup'${id}'Label" aria-hidden="true">
												<div class="modal-dialog">
													<div class="modal-content">
														<div class="modal-header bg-light">
															<h1 class="modal-title align-baseline fs-5" style="color: #FF8C00;" id="BasicBackup'${id}'Label">'${txt_autopilot_create_script}'</h1>
															<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
														</div>
														<form action="index.cgi?page=main" method="post" id="form'${id}'" autocomplete="on">
															<div class="modal-body text-start">
																'${txt_basicbackup_package_name}': <span class="text-secondary">Basic Backup</span><br />
																'${txt_basicbackup_job_name}': <span class="text-secondary">'${backupjob}'</span><br />
																<br />
																<div class="row mb-3 px-1">
																	<div class="col">
																		<label for="filename" class="form-label">'${txt_autopilot_filename_label}'</label>
																			<select id="filename" name="filename" class="form-select form-select-sm" required>
																				<option value="" class="text-secondary" selected disabled></option>'
																					uuidfile="${usr_devices}"
																					scriptfiles=$(grep -irw scriptpath ${uuidfile}/* | cut -d '"' -f2)
																					for scriptfile in ${scriptfiles}; do
																						echo '
																						<option value="'${scriptfile}'" class="text-secondary">'${scriptfile##*/}'</option>'
																					done
																					echo '
																			</select>
																	</div>
																	<div class="text-center pt-2">
																		<small>'${txt_autopilot_note_script_overwrite}'</small>
																	</div>
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
						<i class="bi bi-caret-down-fill pe-2" style="font-size: 0.9rem;"></i><span class="fs-5 pe-1">|</span><i class="bi bi-list py-2" style="font-size: 1.2rem;"></i>
					</button>
					<span class="ps-2">'${txt_hyperbackup_header}'</span>
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
								# Output line by line via loop over all elements
								for ((i=0; i < ${#hyper_backup_job[@]}; i++ )); do
									echo '
									<div class="accordion-item bg-light pt-2 pb-3 ps-1 ms-4">
										'${hyper_backup_job[$i]#*=}'
										<div class="float-end">

											<!-- Modal Button-->
											<button type="button" class="btn btn-sm text-dark py-0" style="background-color: #e6e6e6;" data-bs-toggle="modal" data-bs-target="#HyperBackup'${id}'">
												<i class="bi bi-link-45deg text-success" style="font-size: 1.2rem;" title="'${txt_autopilot_create_this_script}'"></i>
											</button>

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
																<br />
																<div class="row mb-3 px-1">
																	<div class="col">
																		<label for="filename" class="form-label">'${txt_autopilot_filename_label}'</label>
																			<select id="filename" name="filename" class="form-select form-select-sm" required>
																				<option value="" class="text-secondary" selected disabled></option>'
																					uuidfile="${usr_devices}"
																					scriptfiles=$(grep -irw scriptpath ${uuidfile}/* | cut -d '"' -f2)
																					for scriptfile in ${scriptfiles}; do
																						echo '
																						<option value="'${scriptfile}'" class="text-secondary">'${scriptfile##*/}'</option>'
																					done
																					echo '
																			</select>
																	</div>
																	<div class="text-center pt-2">
																		<small>'${txt_autopilot_note_script_overwrite}'</small>
																	</div>
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
					<i class="bi bi-caret-down-fill pe-2" style="font-size: 0.9rem;"></i><span class="fs-5 pe-1">|</span><i class="bi bi-gear-fill py-2" style="font-size: 1.2rem;"></i>
				</button>
				<span class="ps-2">'${txt_autopilot_options_header}'</span>
			</div>
		<div id="flush-collapse-04" class="accordion-collapse collapse show" data-bs-parent="#accordionFlush01">
			<div class="accordion-body bg-light px-3 ps-5">
				<table class="table table-borderless table-sm table-light ps-0">
					<thead></thead>
					<tbody>
						<tr>'
							# Einhängen ein/aus
							echo -n '
							<td scope="row" class="row-sm-auto align-middle">
								'${txt_autopilot_connect}'
							</td>
							<td class="text-end">'
								echo -n '
								<a href="index.cgi?page=main&section=settings&switch=connect&'; \
									if [[ "${connect}" == "true" ]]; then
										echo -n 'query=false" class="link-primary"><i class="bi bi-toggle-on" style="font-size: 2rem;"></i>'
									else
										echo -n 'query=true" class="link-secondary"><i class="bi bi-toggle-off" style="font-size: 2rem;"></i>'
									fi
									echo -n '
								</a>
							</td>
						</tr>
						<tr>'
							# Nach der Ausführung den externen Datenträger...
							echo '
							<td scope="row" class="row-sm-auto align-middle">
								'${txt_autopilot_disconnect}'
							</td>
							<td class="text-end"></td>
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
								<a href="index.cgi?page=main&section=settings&switch=disconnect&'; \
									if [[ "${disconnect}" == "false" ]]; then
										echo -n 'query=" class="link-primary"><i class="bi bi-toggle-on" style="font-size: 2rem;"></i>'
									else
										echo -n 'query=false" class="link-secondary"><i class="bi bi-toggle-off" style="font-size: 2rem;"></i>'
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
								<a href="index.cgi?page=main&section=settings&switch=disconnect&'; \
									if [[ "${disconnect}" == "auto" ]]; then
										echo -n 'query=" class="link-primary"><i class="bi bi-toggle-on" style="font-size: 2rem;"></i>'
									else
										echo -n 'query=auto" class="link-secondary"><i class="bi bi-toggle-off" style="font-size: 2rem;"></i>'
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
								<a href="index.cgi?page=main&section=settings&switch=disconnect&'; \
									if [[ "${disconnect}" == "manual" ]]; then
										echo -n 'query=" class="link-primary"><i class="bi bi-toggle-on" style="font-size: 2rem;"></i>'
									else
										echo -n 'query=manual" class="link-secondary"><i class="bi bi-toggle-off" style="font-size: 2rem;"></i>'
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
								<a href="index.cgi?page=main&section=settings&switch=signal&'; \
									if [[ "${signal}" == "true" ]]; then
										echo -n 'query=" class="link-primary"><i class="bi bi-toggle-on" style="font-size: 2rem;"></i>'
									else
										echo -n 'query=true" class="link-secondary"><i class="bi bi-toggle-off" style="font-size: 2rem;"></i>'
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

# AutoPilot Startscript und Scriptdatei erstellen
# --------------------------------------------------------------
if [[ "${get[page]}" == "main" && "${post[section]}" == "autopilotscript" ]]; then
	uuid="${post[extuuid]}"
	uuidfile="${usr_devices}/${uuid}"

	# Pfad und Dateiname der Startdatei festlegen
	autopilotfile="${post[extpath]}/autopilot"

	# Pfad und Dateiname der auszuführenden Scriptdatei festlegen
	if [[ -z "${post[targetfolder]}" ]]; then
		scriptpath="${post[sharedfolder]}"
		scriptfile="${post[sharedfolder]}/${post[filename]}.sh"
	else
		scriptpath="${post[sharedfolder]}/${post[targetfolder]}"
		scriptfile="${post[sharedfolder]}/${post[targetfolder]}/${post[filename]}.sh"
	fi

	# Zugehörige UUID in der AutoPilot App-Verzeichnisstruktur hinterlegen
	if [ ! -f "${uuidfile}" ]; then
		touch "${uuidfile}"
		chmod 777 "${uuidfile}"
	fi
	if [ -f "${uuidfile}" ]; then
		> "${uuidfile}"
		echo "scriptpath=\"${scriptfile}\"" > "${uuidfile}"
	fi

	# Leere AutoPilot Startdatei auf dem ext. Datenträger erstellen
	if [ ! -f "${autopilotfile}" ]; then
		touch "${autopilotfile}"
		chmod 777 "${autopilotfile}"
	fi
	if [ -f "${autopilotfile}" ]; then
		> "${autopilotfile}"
	fi

	# AutoPilot Scriptdatei erstellen
	if [ ! -d "${scriptpath}" ]; then
		mkdir -p -m 755 "${scriptpath}"
	fi

	if [ -d "${scriptpath}" ] && [ ! -f "${scriptfile}" ]; then
		touch "${scriptfile}"
		chmod 777 "${scriptfile}"
		> "${scriptfile}"
		echo "#!/bin/bash" > "${scriptfile}"
		echo "# This script file was generated by AutoPilot" >> "${scriptfile}"
		echo "" >> "${scriptfile}"
	fi

	[ -f "${post_request}" ] && rm "${post_request}"
	echo '<meta http-equiv="refresh" content="0; url=index.cgi?page=main&section=start">'
fi

# Scriptdatei ansehen
# --------------------------------------------------------------
if [[ "${get[page]}" == "main" && "${get[section]}" == "view" ]]; then
	uuid="${get[extuuid]}"
	uuidfile="${usr_devices}/${uuid}"
	autopilotfile="${get[extpath]}/autopilot"

	if [ -f "${uuidfile}" ]; then
		scriptfile=$(cat "${uuidfile}" | grep scriptpath | cut -d '"' -f2)
		popup_modal "scriptview" "${txt_view_scriptfile}" "${scriptfile}" "" "modal-fullscreen"
	fi

	if [ ! -f "${uuidfile}" ] && [ -f "${autopilotfile}" ]; then
		popup_modal "scriptview" "${txt_view_autopilotfile}" "${autopilotfile}" "autopilot" "modal-fullscreen"
	fi
fi

# Verbindung zwischen dem ext. Datenträger und dem AutoPilot Script löschen
# --------------------------------------------------------------
if [[ "${get[page]}" == "main" && "${get[section]}" == "delete" ]]; then
	uuid="${get[extuuid]}"
	uuidfile="${usr_devices}/${uuid}"
	autopilotfile="${get[extpath]}/autopilot"

	# AutoPilot Scriptdatei vom ext. Datenträger löschen
	if [ -f "${autopilotfile}" ]; then
		rm "${autopilotfile}"
	fi

	# UUID Datei löschen
	if [ -f "${uuidfile}" ]; then
		rm /volume*/@appstore/AutoPilot/ui/usersettings/devices/${uuid}
	fi

	[ -f "${get_request}" ] && rm "${get_request}"
	echo '<meta http-equiv="refresh" content="0; url=index.cgi?page=main&section=start">'
fi

# Basic Backup Script anlegen
# --------------------------------------------------------------
if [[ "${get[page]}" == "main" && "${post[section]}" == "basicbackup" ]]; then

	#target="${post[externaldisk]}/autopilot"
	jobname="${post[jobname]}"
	scriptfile="${post[filename]}"

	# AutoPilot Scriptdatei erstellen
	if [ -f "${scriptfile}" ]; then
		echo "#!/bin/bash" > "${scriptfile}"
		echo "# Execute a Basic Backup job" >> "${scriptfile}"
		echo "# Job name: ${jobname}" >> "${scriptfile}"
		echo "" >> "${scriptfile}"
		echo "/usr/syno/synoman/webman/3rdparty/BasicBackup/rsync.sh --job-name=\"${jobname}\"" >> "${scriptfile}"
		echo "exit \${?}" >> "${scriptfile}"
		[ -f "${get_request}" ] && rm "${get_request}"
		[ -f "${post_request}" ] && rm "${post_request}"
		echo '<meta http-equiv="refresh" content="0; url=index.cgi?page=main&section=start">'
	fi
fi

# Hyper Backup Script anlegen
# --------------------------------------------------------------
if [[ "${get[page]}" == "main" && "${post[section]}" == "hyperbackup" ]]; then

	jobname="${post[jobname]}"
	taskid="${post[taskid]}"
	scriptfile="${post[filename]}"

	if [ -f "${scriptfile}" ]; then
		> "${scriptfile}"
		echo "#!/bin/bash" > "${scriptfile}"
		echo "# Execute a Hyper Backup task" >> "${scriptfile}"
		echo "# Task ID: ${taskid}" >> "${scriptfile}"
		echo "# Task name: ${jobname}" >> "${scriptfile}"
		echo "" >> "${scriptfile}"
		echo "/var/packages/HyperBackup/target/bin/dsmbackup --backup \"${taskid}\"" >> "${scriptfile}"
		echo "pid=\$(ps aux | grep -v grep | grep -E \"/var/packages/HyperBackup/target/bin/(img_backup|dsmbackup|synoimgbkptool|synolocalbkp|synonetbkp|updatebackup).+-k ${taskid}\" | awk '{print \$2}')" >> "${scriptfile}"
		echo "while ps -p \$pid > /dev/null" >> "${scriptfile}"
		echo "do" >> "${scriptfile}"
		echo "    sleep 60" >> "${scriptfile}"
		echo "done" >> "${scriptfile}"
		echo "exit \${?}" >> "${scriptfile}"
		[ -f "${get_request}" ] && rm "${get_request}"
		[ -f "${post_request}" ] && rm "${post_request}"
		echo '<meta http-equiv="refresh" content="0; url=index.cgi?page=main&section=start">'
	fi
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