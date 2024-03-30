#!/bin/bash
# Filename: main.sh - coded in utf-8

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


# Reset requests and reload the page
# --------------------------------------------------------------
if [[ "${get[page]}" == "main" && "${get[section]}" == "reset" ]]; then
	unset var
	[[ -f "${get_request}" ]] && rm "${get_request}"
	[[ -f "${post_request}" ]] && rm "${post_request}"
	echo '<meta http-equiv="refresh" content="0; url=index.cgi?page=main&section=start">'
fi

# Function: Select local disk destination
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

# Function: Select external disk destination
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

# Function: Select Script destination
# --------------------------------------------------------------
function script_target ()
{
	echo '
	<div class="row mb-3 px-1">
		<div class="col">
			<label for="filename" class="form-label">'${txt_autopilot_filename_label}'</label>
			<select id="filename" name="filename" class="form-select form-select-sm" required>
				<option value="" class="text-secondary" selected disabled></option>'
					uuidfile="${usr_devices}"
					scriptfiles=$(grep -irw scriptpath ${uuidfile}/* | cut -d '"' -f2)
					IFS="
					"
					for scriptfile in ${scriptfiles}; do
						IFS="${backupIFS}"
						if [ -f "${scriptfile}" ]; then
							echo '
							<option value="'${scriptfile}'" class="text-secondary">'${scriptfile##*/}'</option>'
						fi
					done
					echo '
			</select>
		</div>
		<div class="text-center pt-2">
			<small>'${txt_autopilot_note_script_overwrite}'</small>
		</div>
	</div>'
}

# Load library function to generate script files of tempalte
# --------------------------------------------------------------
[ -f "${app_home}/modules/create_script_file.sh" ] && source "${app_home}/modules/create_script_file.sh"

# Load library function for byte conversion
# --------------------------------------------------------------
[ -f "${app_home}/modules/bytes2human.sh" ] && source "${app_home}/modules/bytes2human.sh"

# Load library function to evaluate disk space
# --------------------------------------------------------------
[ -f "${app_home}/modules/eval_disk_space.sh" ] && source "${app_home}/modules/eval_disk_space.sh"

# Load horizontal navigation bar
# --------------------------------------------------------------
mainnav

# Show homepage
# --------------------------------------------------------------
if [[ "${get[page]}" == "main" && "${get[section]}" == "start" ]]; then

	# Checking the app version level
	# --------------------------------------------------------------
	git_version=$(wget --no-check-certificate --timeout=60 --tries=1 -q -O- "https://raw.githubusercontent.com/toafez/${app_name}/main/INFO.sh" | grep ^version | cut -d '"' -f2)		
	if [ -n "${git_version}" ] && [ -n "${app_version}" ]; then
		if dpkg --compare-versions ${git_version} gt ${app_version}; then
			echo '
			<div class="card">
				<div class="card-header bg-danger-subtle"><strong>'${txt_update_available}'</strong></div>
				<div class="card-body">'${txt_update_from}'<span class="text-danger"> '${app_version}' </span>'${txt_update_to}'<span class="text-success"> '${git_version}'</span>
					<div class="float-end">
						<a href="https://github.com/toafez/'${app_name}'/releases" class="btn btn-sm text-dark text-decoration-none" style="background-color: #e6e6e6;" target="_blank">Update</a>
					</div>
				</div>
			</div><br />'
		fi
	fi

	# Check app permission
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

	# Checking the UDEV device driver
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

	# Main menu
	# --------------------------------------------------------------
	echo '
	<div class="accordion accordion-flush" id="accordionFlush01">'

		# External disks
		# --------------------------------------------------------------
		echo '
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
						ext_id=0
						while IFS= read -r ext_volume; do
							IFS="${backupIFS}"
							[ -z "${ext_volume}" ] && continue

							while IFS= read -r ext_share; do
								IFS="${backupIFS}"
								[ -z "${ext_share}" ] && continue

								# Reading out disk information
								ext_mountpoint=$(mount | grep -E "${ext_volume}/${ext_share##*/}")
								ext_dev=$(echo "${ext_mountpoint}" | awk '{print $1}')
								ext_path=$(echo "${ext_mountpoint}" | awk '{print $3}')
								ext_uuid=$(blkid -s UUID -o value ${ext_dev})
								ext_type=$(blkid -s TYPE -o value ${ext_dev})
								ext_label=$(blkid -s LABEL -o value ${ext_dev})
								[ -z "${ext_dev}" ] && continue

								# Reading out free disk space
								evalDiskSize "$ext_path" \
									ext_disk_size \
									ext_disk_used \
									ext_disk_available \
									ext_disk_used_percent \
									ext_disk_mountpoint

								# convert bytes to human readable
								ext_disk_size_hr=$(bytesToHumanReadable "$ext_disk_size")
								ext_disk_available_hr=$(bytesToHumanReadable "$ext_disk_available")

								# Determine the file system if there is a 128-bit UUID (LINUX/UNIX)
								if [[ "${ext_uuid}" =~ ^\{?[A-F0-9a-f]{8}-[A-F0-9a-f]{4}-[A-F0-9a-f]{4}-[A-F0-9a-f]{4}-[A-F0-9a-f]{12}\}?$ ]]; then
									txt_volume_id="Universally Unique Identifier (UUID)"
								# Determine the file system if there is a 64 bit VSN (Windows NTFS)
								elif [[ "${ext_uuid}" =~ ^\{?[A-F0-9a-f]{16}\}?$ ]]; then
									txt_volume_id="Volume Serial Number (VSN)"
								# Determine the file system if there is a 32 bit VSN (Windows FAT12, FAT16, FAT32 and exFAT) combined as vFAT
								elif [[ "${ext_uuid}" =~ ^\{?[A-F0-9a-f]{4}-[A-F0-9a-f]{4}\}?$ ]] || [[ "${ext_uuid}" =~ ^\{?[A-F0-9a-f]{8}\}?$ ]]; then
									txt_volume_id="Volume Serial Number (VSN)"
								else
									ext_uuid=
									txt_volume_id="Unique Identifier (UUID/GUID)"
									txt_volume_id_failed="<span class=\"text-danger\">Could not be read</span>"
								fi

								# Specify the path to the internally stored UUID script file of the same name
								if [ -n "${ext_uuid}" ]; then
									uuidfile="${usr_devices}/${ext_uuid}"
									echo '
									<table class="table table-borderless table-sm table-light">
										<thead>
											<tr>
												<th scope="col" class="m-0 p-0" style="width: 160px;">&nbsp;</th>
												<th scope="col" class="m-0 p-0" style="width: 250px;">&nbsp;</th>
												<th scope="col" class="m-0 p-0" style="width: auto;">&nbsp;</th>
												<th scope="col" class="m-0 p-0" style="width: 20px;">&nbsp;</th>
												<th scope="col" class="m-0 p-0" style="width: 120px;">&nbsp;</th>
											</tr>
										</thead>
										<tbody>
											<tr>
												<td colspan="4">
													<i class="bi bi-hdd-fill text-secondary me-2"></i><span class="fw-medium">'${ext_volume#*/}'</span>
												</td>
												<td class="text-end pe-4">'
													# If autopilot script file exists is empty and internal UUID/GUID file exists, then...
													if [ ! -s "${ext_volume}/${ext_share##*/}/autopilot" ] && [ -f "${uuidfile}" ]; then
														echo '
														<a class="btn btn-sm text-dark py-0" style="background-color: #e6e6e6;" href="index.cgi?page=main&section=view&extpath='${ext_path}'&extuuid='${ext_uuid}'">
															<i class="bi bi-terminal-fill" style="font-size: 1.2rem;" title="'${txt_autopilot_script_view}'"></i>
														</a>
														<a class="btn btn-sm text-dark py-0" style="background-color: #e6e6e6;" href="index.cgi?page=main&section=delete&extpath='${ext_path}'&extuuid='${ext_uuid}'">
															<i class="bi bi-trash text-danger" style="font-size: 1.2rem;" title="'${txt_autopilot_script_delete}'"></i>
														</a>'
													# If autopilot script file exists but is not empty, then...
													elif [ -s "${ext_volume}/${ext_share##*/}/autopilot" ]; then
														echo '
														<a class="btn btn-sm text-danger py-0" style="background-color: #e6e6e6;" href="index.cgi?page=main&section=view&extpath='${ext_volume}/${ext_share##*/}'&extuuid=">
															<i class="bi bi-exclamation-triangle" style="font-size: 1.2rem;" title="'${txt_autopilot_autopilot_view}'"></i>
														</a>'
													# If autopilot startup file does not exist and UUID/GUID could be read then...
													elif [ ! -f "${ext_volume}/${ext_share##*/}/autopilot" ]; then
														# Is the autopilot start file on the ext. Disk does not exist, then delete the associated device entry
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
											</tr>
											<tr>
												<td>&nbsp;</td>
												<td>'${txt_volume_id}'</td>
												<td colspan="3">'${ext_uuid}'</td>
											</tr>
											<tr>
												<td>&nbsp;</td>
												<td>'${txt_autopilot_memory}'</td>
												<td style="width: auto">
													<div class="progress" role="progressbar" aria-label="Example with label" aria-valuenow="10" aria-valuemin="0" aria-valuemax="100" style="height: 25px">
														<div class="progress-bar overflow-visible text-dark bg-primary-subtle ps-2" style="width: '${ext_disk_used_percent}'%">'${ext_disk_available_hr}' '${txt_autopilot_from}' '${ext_disk_size_hr}' '${txt_autopilot_free}'</div>
													</div>
												</td>
												<td colspan="2">&nbsp;</td>
											</tr>'
											uuidfile="${usr_devices}/${ext_uuid}"
											if [ -f "${uuidfile}" ]; then
												scriptfile=$(cat "${uuidfile}" | grep scriptpath | cut -d '"' -f2)
												if [ -f "${scriptfile}" ]; then
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
												else
													echo '
													<tr>
														<td class="bg-light ps-4 me-2">
															<i class="bi bi-file-earmark text-dark me-2"></i>'${txt_autopilot_scriptfile}'
														</td>
														<td>'${txt_autopilot_scriptfile_error}'</td>
														<td colspan="3">
															<span class="text-danger">'${txt_autopilot_scriptfile_errormsg1}'</span>
															'${scriptfile}'
															<span class="text-danger">'${txt_autopilot_scriptfile_errormsg2}'</span>
														</td>
													</tr>'
												fi
											fi
											echo '
										</tbody>
									</table>'
								fi
								ext_id=$[${ext_id}+1]
							done <<< "$( find ${ext_volume}/* -maxdepth 0 -type d ! -path '*/lost\+found' ! -path '*/\@*' ! -path '*/\$RECYCLE.BIN' ! -path '*/Repair' ! -path '*/System Volume Information' )"
							unset ext_uuid extuuid
						done <<< "$( find ${1} -type d -maxdepth 0 )"
						unset ext_volume ext_share

						# Check if external disk is plugged in
						if [[ "${1}" == "/volumeUSB[[:digit:]]" ]]; then
							count_usb="${ext_id}"
						elif [[ "${1}" == "/volumeSATA" ]] || [[ "${1}" == "/volumeSATA[[:digit:]]" ]]; then
							count_sata="${ext_id}"
						fi
					}

					ext_sources "/volumeUSB[[:digit:]]"
					ext_sources "/volumeSATA[[:digit:]]"
					ext_sources "/volumeSATA"

					# If no external disk is plugged in
					if [[ "${count_usb}" -eq 0 ]] && [[ "${count_sata}" -eq 0 ]]; then
						echo '<p class="py-3">'${txt_external_disks_not_found}'</p>'
					# If external data carrier is plugged in
					elif [[ "${count_usb}" -gt 0 ]] || [[ "${count_sata}" -gt 0 ]]; then
						echo '<p>&nbsp;</p>'
					fi

					echo '
				</div>
			</div>
		</div>'

		# Basic Backup tasks
		# --------------------------------------------------------------
		if [ -d /var/packages/BasicBackup ] && [[ "${permissions}" == "true" ]]; then
			echo '
			<div class="accordion-item border-0 mt-3">
				<div class="accordion-header bg-light p-2">
					<button class="btn btn-sm text-dark py-0 collapsed" style="background-color: #e6e6e6;" type="button" data-bs-toggle="collapse" data-bs-target="#flush-collapse-02" aria-expanded="false" aria-controls="flush-collapse-02">
						<i class="bi bi-caret-down-fill pe-2" style="font-size: 0.9rem;"></i><span class="fs-5 pe-1">|</span><i class="bi bi-list py-2" style="font-size: 1.2rem;"></i>
					</button>
					<span class="ps-2">'${txt_basicbackup_header}'&nbsp;&nbsp;'
						if [[ "${basicbackup_updateinfo}" != "${app_version}" ]]; then
							echo '
							<sup class="text-danger align-middle">
								<a href="index.cgi?page=main&section=settings&switch=basicbackup_updateinfo&query='${app_version}'" class="link-success" style="text-decoration:none;">
									<i class="bi bi-info-square text-primary align-middle" style="font-size: 1.1rem;" title="'${txt_autopilot_updateinfo_disable}'"></i>
								</a>&nbsp;
								'${txt_autopilot_update_scriptcontent}'
							</sup>'
						fi
						echo '
					</span>
				</div>
				<div id="flush-collapse-02" class="accordion-collapse collapse" data-bs-parent="#accordionFlush01">
					<div class="accordion-body bg-light">
						<div class="accordion accordion-flush" id="accordionLoop02">'
							basic_backup_jobs=$(find "/var/packages/BasicBackup/target/ui/usersettings/backupjobs" -type f -name "*.config" -maxdepth 1 | sort -f )
							if [ -n "$basic_backup_jobs" ]; then
								id=0
								# Delete temporary Basic Backup files
								find "${app_home}/temp" -type f -iname "basic_backup_script_*" | xargs rm -rf
								IFS="
								"
								for basic_backup_job in ${basic_backup_jobs}; do
									IFS="${backupIFS}"
									[ -f "${basic_backup_job}" ] && source "${basic_backup_job}"
									basic_backup_job=$(echo "${basic_backup_job##*/}")
									basic_backup_job=$(echo "${basic_backup_job%.*}")
									echo '
									<div class="accordion-item bg-light pt-2 pb-3 ps-1 ms-4">
										'${basic_backup_job}'
										<div class="float-end">

											<!-- Script Button -->
											<button class="btn btn-sm text-dark py-0 collapsed" style="background-color: #e6e6e6;" type="button" data-bs-toggle="collapse" data-bs-target="#loop-collapse-02-'${id}'" aria-expanded="false" aria-controls="loop-collapse-02-'${id}'">
												<i class="bi bi-terminal-fill" style="font-size: 1.2rem;" title="'${txt_basicbackup_title_view_script}'"></i>
											</button>

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
																'${txt_basicbackup_job_name}': <span class="text-secondary">'${basic_backup_job}'</span><br /><br />'

																script_target

																echo '
															</div>
															<div class="modal-footer bg-light">
																<input type="hidden" name="jobname" value="'${basic_backup_job}'">
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
										<div id="loop-collapse-02-'${id}'" class="accordion-collapse collapse" data-bs-parent="#accordionLoop02">
											<div class="accordion-body">'
												basic_backup_script_tmp_file="${app_home}/temp/basic_backup_script_${id}.tmp"

												# Function: Generate Basic Backup Script
												basic_backup_script "${basic_backup_job}" "${basic_backup_script_tmp_file}"

												echo -n '<pre style="overflow-x:auto;"><code>'
												cat "${basic_backup_script_tmp_file}"
												echo -n '</code></pre>
											</div>
										</div>
									</div>'
									id=$((id+1))
								done
								unset basic_backup_job
							fi
							echo '
						</div>
					</div>
				</div>
			</div>'
		fi

		# Hyper Backup tasks
		# --------------------------------------------------------------
		if [ -d /var/packages/HyperBackup ] && [[ "${permissions}" == "true" ]]; then
			echo '
			<div class="accordion-item border-0 mt-3">
				<div class="accordion-header bg-light p-2">
					<button class="btn btn-sm text-dark py-0 collapsed" style="background-color: #e6e6e6;" type="button" data-bs-toggle="collapse" data-bs-target="#flush-collapse-03" aria-expanded="false" aria-controls="flush-collapse-03">
						<i class="bi bi-caret-down-fill pe-2" style="font-size: 0.9rem;"></i><span class="fs-5 pe-1">|</span><i class="bi bi-list py-2" style="font-size: 1.2rem;"></i>
					</button>
					<span class="ps-2">'${txt_hyperbackup_header}'&nbsp;&nbsp;'
						if [[ "${hyperbackup_updateinfo}" != "${app_version}" ]]; then
							echo '
							<sup class="text-danger align-middle">
								<a href="index.cgi?page=main&section=settings&switch=hyperbackup_updateinfo&query='${app_version}'" class="link-success" style="text-decoration:none;">
									<i class="bi bi-info-square text-primary align-middle" style="font-size: 1.1rem;" title="'${txt_autopilot_updateinfo_disable}'"></i>
								</a>&nbsp;
								'${txt_autopilot_update_scriptcontent}'
							</sup>'
						fi
						echo '
					</span>
				</div>
				<div id="flush-collapse-03" class="accordion-collapse collapse" data-bs-parent="#accordionFlush01">
					<div class="accordion-body bg-light">
						<div class="accordion accordion-flush" id="accordionLoop03">'
							if [ "${hyperbackup_version%%.*}" -le 3 ]; then
								echo '<p>'${txt_hyperbackup_required}'</p>'
							elif [ -f /usr/syno/etc/packages/HyperBackup/synobackup.conf ]; then
								IFS="
								"
								declare -A hyper_backup_job=()
								loop_idx=0
								idx=0
								for item in $(sed -nE '/^[task_[0-9]+]$/,/^[repo_[0-9]+]$/p' /usr/syno/etc/packages/HyperBackup/synobackup.conf \
									| grep -E "task_[0-9]+|name=" \
									| sed -E 's/\[task_([0-9]+)\]/\1/' \
									| sed -E 's/name="(.+)"/\1/'); do

									IFS="${backupIFS}"
									if ! (( "$loop_idx" % 2 )); then
										hyper_backup_job[$idx]="$item"
									else
										hyper_backup_job[$idx]="${hyper_backup_job[$idx]}""=""$item"
										idx=$((idx+1))
									fi
									loop_idx=$((loop_idx+1))
								done
								id=0

								# Delete temporary Hyper Backup files
								find "${app_home}/temp" -type f -iname "hyper_backup_script_*" | xargs rm -rf

								# Output line by line via loop over all elements
								IFS="
								"
								for ((i=0; i < ${#hyper_backup_job[@]}; i++ )); do
									IFS="${backupIFS}"
									echo '
									<div class="accordion-item bg-light pt-2 pb-3 ps-1 ms-4">
										'${hyper_backup_job[$i]#*=}'
										<div class="float-end">

											<!-- Script Button -->
											<button class="btn btn-sm text-dark py-0 collapsed" style="background-color: #e6e6e6;" type="button" data-bs-toggle="collapse" data-bs-target="#loop-collapse-03-'${id}'" aria-expanded="false" aria-controls="loop-collapse-03-'${id}'">
												<i class="bi bi-terminal-fill" style="font-size: 1.2rem;" title="'${txt_hyperbackup_title_view_script}'"></i>
											</button>

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
																'${txt_hyperbackup_job_name}': <span class="text-secondary">'${hyper_backup_job[$i]#*=}'</span><br /><br />'

																script_target

																echo '
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
										<div id="loop-collapse-03-'${id}'" class="accordion-collapse collapse" data-bs-parent="#accordionLoop03">
											<div class="accordion-body">'
												hyper_backup_script_tmp_file="${app_home}/temp/hyper_backup_script_${id}.tmp"

												# Function: Generate Hyper Backup Script
												hyper_backup_script "${hyper_backup_job[$i]%=*}" "${hyper_backup_job[$i]#*=}" "${hyper_backup_script_tmp_file}"

												echo -n '<pre style="overflow-x:auto;"><code>'
												cat "${hyper_backup_script_tmp_file}"
												echo -n '</code></pre>
											</div>
										</div>
									</div>'
									id=$((id+1))
								done
								unset scriptfiles
							else
								echo '<p>'${txt_hyperbackup_config_not_found}'</p>'
							fi
							echo '
						</div>
					</div>
				</div>
			</div>'
		fi

		# Costum Script tasks
		# --------------------------------------------------------------
		if [[ "${permissions}" == "true" ]]; then
			echo '
			<div class="accordion-item border-0 mt-3">
				<div class="accordion-header bg-light p-2">
					<button class="btn btn-sm text-dark py-0 collapsed" style="background-color: #e6e6e6;" type="button" data-bs-toggle="collapse" data-bs-target="#flush-collapse-04" aria-expanded="false" aria-controls="flush-collapse-04">
						<i class="bi bi-caret-down-fill pe-2" style="font-size: 0.9rem;"></i><span class="fs-5 pe-1">|</span><i class="bi bi-list py-2" style="font-size: 1.2rem;"></i>
					</button>
					<span class="ps-2">'${txt_customscripts_header}'&nbsp;&nbsp;'
						if [[ "${customscripts_updateinfo}" != "${app_version}" ]]; then
							echo '
							<sup class="text-danger align-middle">
								<a href="index.cgi?page=main&section=settings&switch=customscripts_updateinfo&query='${app_version}'" class="link-success" style="text-decoration:none;">
									<i class="bi bi-info-square text-primary align-middle" style="font-size: 1.1rem;" title="'${txt_autopilot_updateinfo_disable}'"></i>
								</a>&nbsp;
								'${txt_autopilot_update_custom_scriptcontent}'
							</sup>'
						fi
						echo '
					</span>
				</div>
				<div id="flush-collapse-04" class="accordion-collapse collapse" data-bs-parent="#accordionFlush01">
					<div class="accordion-body bg-light">
						<div class="accordion accordion-flush" id="accordionLoop04">'

							# Simple custom script 
							# --------------------------------------------------------------
								echo '
								<div class="accordion-item bg-light pt-2 pb-3 ps-1 ms-4">'
									if [[ "${customscripts_updateinfo}" != "${app_version}" ]]; then
										echo ''${txt_customscripts_simple}' <sup class="text-danger align-middle">Update</sup>'
									else
										echo ''${txt_customscripts_simple}''
									fi
									echo '
									<div class="float-end">

										<!-- Script Button -->
										<button class="btn btn-sm text-dark py-0 collapsed" style="background-color: #e6e6e6;" type="button" data-bs-toggle="collapse" data-bs-target="#loop-collapse-04" aria-expanded="false" aria-controls="loop-collapse-04">
											<i class="bi bi-terminal-fill" style="font-size: 1.2rem;" title="'${txt_customscripts_title_view_script}'"></i>
										</button>

										<!-- Modal Button-->
										<button type="button" class="btn btn-sm text-dark py-0" style="background-color: #e6e6e6;" data-bs-toggle="modal" data-bs-target="#CustomScriptSimple">
											<i class="bi bi-link-45deg text-success" style="font-size: 1.2rem;" title="'${txt_customscripts_create_this_script}'"></i>
										</button>

										<!-- Modal Popup-->
										<div class="modal fade" id="CustomScriptSimple" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="CustomScriptSimpleLabel" aria-hidden="true">
											<div class="modal-dialog">
												<div class="modal-content">
													<div class="modal-header bg-light">
														<h1 class="modal-title align-baseline fs-5" style="color: #FF8C00;" id="CustomScriptSimpleLabel">'${txt_autopilot_create_script}'</h1>
														<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
													</div>
													<form action="index.cgi?page=main" method="post" id="form'${id}'" autocomplete="on">
														<div class="modal-body text-start">
															'${txt_customscripts_package_name}': <span class="text-secondary">AutoPilot</span><br />
															'${txt_customscripts_script_name}': <span class="text-secondary">'${txt_customscripts_simple}'</span><br /><br />'

															script_target

															echo '
														</div>
														<div class="modal-footer bg-light">
															<input type="hidden" name="scriptname" value="'${txt_customscripts_simple}'">
															<button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">'${txt_button_Cancel}'</button><br />
															<button class="btn btn-secondary btn-sm" type="submit" name="section" value="custom_script_simple">'${txt_button_Save}'</button>
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
									<div id="loop-collapse-04" class="accordion-collapse collapse" data-bs-parent="#accordionLoop04">
										<div class="accordion-body">'
											custom_script_simple_tmp_file="${app_home}/temp/custom_script_simple.tmp"

											# Function: Generate Custom Script File
											custom_script_simple "${txt_customscripts_simple}" "${custom_script_simple_tmp_file}"

											echo -n '<pre style="overflow-x:auto;"><code>'
											cat "${custom_script_simple_tmp_file}"
											echo -n '</code></pre>
										</div>
									</div>
								</div>'
							# --------------------------------------------------------------

							echo '
						</div>
					</div>
				</div>
			</div>'
		fi

		echo '
	</div>
	<div class="accordion accordion-flush" id="accordionFlush02">'

		# AutoPilot settings
		# --------------------------------------------------
		echo '
		<div class="accordion-item border-0 mt-3">
			<div class="accordion-header bg-light p-2">
				<button class="btn btn-sm text-dark py-0 collapsed" style="background-color: #e6e6e6;" type="button" data-bs-toggle="collapse" data-bs-target="#flush-collapse-00" aria-expanded="true" aria-controls="flush-collapse-00">
					<i class="bi bi-caret-down-fill pe-2" style="font-size: 0.9rem;"></i><span class="fs-5 pe-1">|</span><i class="bi bi-gear-fill py-2" style="font-size: 1.2rem;"></i>
				</button>
				<span class="ps-2">'${txt_autopilot_options_header}'</span>
			</div>
		<div id="flush-collapse-00" class="accordion-collapse collapse show" data-bs-parent="#accordionFlush01">
			<div class="accordion-body bg-light px-3 ps-5">
				<table class="table table-borderless table-sm table-light ps-0">
					<thead></thead>
					<tbody>
						<tr>'
							# Mount on/off
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
							# After execution, the external disk...
							echo '
							<td scope="row" class="row-sm-auto align-middle">
								'${txt_autopilot_disconnect}'
							</td>
							<td class="text-end"></td>
						</tr>
						<tr>'
							# Never eject on/off
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
							# Auto eject on/off
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
							# Manual eject on/off
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
							# Visual and acoustic signal output on/off
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
		</div>
	</div><br />'
fi

# Create AutoPilot start script and script file
# --------------------------------------------------------------
if [[ "${get[page]}" == "main" && "${post[section]}" == "autopilotscript" ]]; then
	uuid="${post[extuuid]}"
	uuidfile="${usr_devices}/${uuid}"

	# Set the path and file name of the start file
	autopilotfile="${post[extpath]}/autopilot"

	# Specify the path and file name of the script file to be executed
	if [[ -z "${post[targetfolder]}" ]]; then

		# If the string begins with a slash, remove it
		if echo "${post[filename]}" | grep -q '^/' ; then
			post[filename]="${post[filename]:1}"
		fi

		scriptpath="${post[sharedfolder]}"
		scriptfile="${post[sharedfolder]}/${post[filename]}.sh"
	else
		# If the string begins with a slash, remove it
		if echo "${post[targetfolder]}" | grep -q '^/' ; then
			post[targetfolder]="${post[targetfolder]:1}"
		fi

		# If the string begins with a slash, remove it
		if echo "${post[filename]}" | grep -q '^/' ; then
			post[filename]="${post[filename]:1}"
		fi

		# If the string ends with a slash, remove it
		if echo "${post[targetfolder]}" | grep -q '/$' ; then
			post[targetfolder]="${post[targetfolder]::1}"
		fi

		scriptpath="${post[sharedfolder]}/${post[targetfolder]}"
		scriptfile="${post[sharedfolder]}/${post[targetfolder]}/${post[filename]}.sh"
	fi

	# Store the associated UUID in the AutoPilot app directory structure
	if [ ! -f "${uuidfile}" ]; then
		touch "${uuidfile}"
		chmod 777 "${uuidfile}"
	fi
	if [ -f "${uuidfile}" ]; then
		> "${uuidfile}"
		echo "scriptpath=\"${scriptfile}\"" > "${uuidfile}"
	fi

	# Empty AutoPilot start file on the ext. Create disk
	if [ ! -f "${autopilotfile}" ]; then
		touch "${autopilotfile}"
		chmod 777 "${autopilotfile}"
	fi
	if [ -f "${autopilotfile}" ]; then
		> "${autopilotfile}"
	fi

	# Create AutoPilot script file
	if [ ! -d "${scriptpath}" ]; then
		mkdir -p -m 777 "${scriptpath}"
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

# View script file
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

# Connection between the ext. Delete disk and the AutoPilot script
# --------------------------------------------------------------
if [[ "${get[page]}" == "main" && "${get[section]}" == "delete" ]]; then
	uuid="${get[extuuid]}"
	uuidfile="${usr_devices}/${uuid}"
	autopilotfile="${get[extpath]}/autopilot"

	# AutoPilot script file from ext. Delete disk
	if [ -f "${autopilotfile}" ]; then
		rm "${autopilotfile}"
	fi

	# Delete UUID file
	if [ -f "${uuidfile}" ]; then
		rm /volume*/@appstore/AutoPilot/ui/usersettings/devices/${uuid}
	fi

	[ -f "${get_request}" ] && rm "${get_request}"
	echo '<meta http-equiv="refresh" content="0; url=index.cgi?page=main&section=start">'
fi

# Create Basic Backup script
# --------------------------------------------------------------
if [[ "${get[page]}" == "main" && "${post[section]}" == "basicbackup" ]]; then

	jobname="${post[jobname]}"
	scriptfile="${post[filename]}"

	# Create AutoPilot script file
	if [ -f "${scriptfile}" ]; then
		# Generate script file from template by replacing language specific keywords.
		# Function: Generate Basic Backup Script
		basic_backup_script "${jobname}" "${scriptfile}"

		[ -f "${get_request}" ] && rm "${get_request}"
		[ -f "${post_request}" ] && rm "${post_request}"
		echo '<meta http-equiv="refresh" content="0; url=index.cgi?page=main&section=start">'
	fi
fi

# Create Hyper Backup Script
# --------------------------------------------------------------
if [[ "${get[page]}" == "main" && "${post[section]}" == "hyperbackup" ]]; then

	jobname="${post[jobname]}"
	taskid="${post[taskid]}"
	scriptfile="${post[filename]}"

	if [ -f "${scriptfile}" ]; then
		# Generate script file from template by replacing language specific keywords.
		# Function: Generate Hyper Backup Script
		hyper_backup_script "${taskid}" "${jobname}" "${scriptfile}"

		[ -f "${get_request}" ] && rm "${get_request}"
		[ -f "${post_request}" ] && rm "${post_request}"
		echo '<meta http-equiv="refresh" content="0; url=index.cgi?page=main&section=start">'
	fi
fi

# Create Custom Script
# --------------------------------------------------------------
if [[ "${get[page]}" == "main" && "${post[section]}" == "custom_script_simple" ]]; then

	scriptname="${post[scriptname]}"
	scriptfile="${post[filename]}"

	if [ -f "${scriptfile}" ]; then
		# Generate script file from template by replacing language specific keywords.
		# Function: Generate Hyper Backup Script
		custom_script_simple "${scriptname}" "${scriptfile}"

		[ -f "${get_request}" ] && rm "${get_request}"
		[ -f "${post_request}" ] && rm "${post_request}"
		echo '<meta http-equiv="refresh" content="0; url=index.cgi?page=main&section=start">'
	fi
fi

# Save AutoPilot configuration
# --------------------------------------------------------------
if [[ "${get[page]}" == "main" && "${get[section]}" == "settings" ]]; then
	[ -f "${get_request}" ] && rm "${get_request}"

	# Save settings to ${app_home}/settings/user_settings.txt
	[[ "${get[switch]}" == "connect" ]] && "${set_keyvalue}" "${usr_autoconfig}" "connect" "${get[query]}"
	[[ "${get[switch]}" == "disconnect" ]] && "${set_keyvalue}" "${usr_autoconfig}" "disconnect" "${get[query]}"
	[[ "${get[switch]}" == "signal" ]] && "${set_keyvalue}" "${usr_autoconfig}" "signal" "${get[query]}"
	[[ "${get[switch]}" == "basicbackup_updateinfo" ]] && "${set_keyvalue}" "${usr_autoconfig}" "basicbackup_updateinfo" "${get[query]}"
	[[ "${get[switch]}" == "hyperbackup_updateinfo" ]] && "${set_keyvalue}" "${usr_autoconfig}" "hyperbackup_updateinfo" "${get[query]}"
	[[ "${get[switch]}" == "customscripts_updateinfo" ]] && "${set_keyvalue}" "${usr_autoconfig}" "customscripts_updateinfo" "${get[query]}"
	echo '<meta http-equiv="refresh" content="0; url=index.cgi?page=main&section=start">'
fi