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

	echo '
	<div class="row">
		<div class="col">
			<div class="card border-0">
				<div class="card-header ps-0 pb-0 bg-body border-0">
					<h5>'${txt_autopilot_status}'</h5>
				</div>
			</div>
			<div class="card-body">
				<div class="row">
					<div class="col-sm-12">
						<table class="table table-borderless table-hover table-sm">
							<thead></thead>
							<tbody>
								<tr>
									<td scope="row" class="row-sm-auto">'
										if [[ "${udev_rule}" == "true" ]]; then
											if [[ "${rewrite_udev}" == "true" ]]; then
												echo '
												'${txt_autopilot_service}' <span class="text-danger">'${txt_autopilot_is_inactive}'</span>
												<td class="text-end">
													<button type="button" class="btn btn-light btn-sm text-success text-decoration-none" data-bs-toggle="modal" data-bs-target="#help-autopilot_status">'${txt_button_activate}'</button>
												</td>'
											else
												echo '
												'${txt_autopilot_service}' <span class="text-success">'${txt_autopilot_is_active}'</span>
												<td class="text-end">
													<button type="button" class="btn btn-light btn-sm text-danger text-decoration-none" data-bs-toggle="modal" data-bs-target="#help-autopilot_status">'${txt_button_deactivate}'</button>
												</td>'
											fi
										else
											echo '
											'${txt_autopilot_service}' <span class="text-danger">'${txt_autopilot_is_inactive}'</span>
											<td class="text-end">
												<button type="button" class="btn btn-light btn-sm text-success text-decoration-none" data-bs-toggle="modal" data-bs-target="#help-autopilot_status">'${txt_button_activate}'</button>
											</td>'
										fi
										echo '
									</td>
								</tr>'
								# Überprüfen des App-Versionsstandes
								# --------------------------------------------------------------
								local_version=$(cat "/var/packages/${app_name}/INFO" | grep ^version | cut -d '"' -f2)
								git_version=$(wget --no-check-certificate --timeout=60 --tries=1 -q -O- "https://raw.githubusercontent.com/toafez/${app_name}/main/INFO.sh" | grep ^version | cut -d '"' -f2)		
								if [ -n "${git_version}" ] && [ -n "${local_version}" ]; then
									if dpkg --compare-versions ${git_version} gt ${local_version}; then
										echo '
										<tr>
											<td scope="row" class="row-sm-auto">
												'${txt_update_available}' '${git_version}'
												<td class="text-end"> 
													<a href="https://github.com/toafez/'${app_name}'/releases" class="btn btn-light btn-sm text-success text-decoration-none" target="_blank">Update</a>
												</td>
											</td>
										</tr>'
									fi
								fi
								echo '
							</tbody>
						</table>
					</div>
				</div>
			</div>'	

			# USB/SATA-AutoPilot Einstellungen
			# --------------------------------------------------
			echo '
			<div class="card border-0">
				<div class="card-header ps-0 pb-0 bg-body border-0">
					<h5>'${txt_autopilot_settings}'</h5>
				</div>
			</div>
			<div class="card-body">
				<div class="row">
					<div class="col-sm-12">
						<table class="table table-borderless table-hover table-sm">
							<thead></thead>
							<tbody>
								<tr>'
									# Einhängen ein/aus
									echo -n '
									<td scope="row" class="row-sm-auto">
										'${txt_autopilot_connect}'
									</td>
									<td class="text-end">'
										echo -n '
										<a class="material-icons text-success" href="index.cgi?page=main&section=save&option=connect&'; \
											if [[ "${connect}" == "true" ]]; then
												echo -n 'query=false">
												<i style="font-size: 1.1rem;" class="bi bi-check-square text-secondary"></i>'
											else
												echo -n 'query=true">
												<i style="font-size: 1.1rem;" class="bi bi-square text-secondary"></i>'
											fi
											echo -n '
										</a>
									</td>
								</tr>
								<tr>'
									# Auswerfen ein/aus
									echo -n '
									<td scope="row" class="row-sm-auto">
										'${txt_autopilot_disconnect}'
									</td>
									<td class="text-end">&nbsp;</td>
								</tr>
								<tr>'
									# Niemals auswerfen ein/aus
									echo '
									<td scope="row" class="row-sm-auto">
										<span class="ps-3">
											<i class="bi bi-dot"></i> '${txt_autopilot_disconnect_never}'
										</span>
									</td>
									<td class="text-end">'
										echo -n '
										<a class="material-icons text-success" href="index.cgi?page=main&section=save&option=disconnect&'; \
											if [[ "${disconnect}" == "false" ]]; then
												echo -n 'query=">
												<i style="font-size: 1.1rem;" class="bi bi-check-square text-secondary"></i>'
											else
												echo -n 'query=false">
												<i style="font-size: 1.1rem;" class="bi bi-square text-secondary"></i>'
											fi
											echo -n '
										</a>
									</td>
								</tr>
								<tr>'
									# Automatisch auswerfen ein/aus
									echo '
									<td scope="row" class="row-sm-auto">
										<span class="ps-3">
											<i class="bi bi-dot"></i> '${txt_autopilot_disconnect_auto}'
										</span>
									</td>
									<td class="text-end">'
										echo -n '
										<a class="material-icons text-success" href="index.cgi?page=main&section=save&option=disconnect&'; \
											if [[ "${disconnect}" == "auto" ]]; then
												echo -n 'query=">
												<i style="font-size: 1.1rem;" class="bi bi-check-square text-secondary"></i>'
											else
												echo -n 'query=auto">
												<i style="font-size: 1.1rem;" class="bi bi-square text-secondary"></i>'
											fi
											echo -n '
										</a>
									</td>
								</tr>
								<tr>'
									# Manuell auswerfen ein/aus
									echo '
									<td scope="row" class="row-sm-auto">
										<span class="ps-3">
											<i class="bi bi-dot"></i> '${txt_autopilot_disconnect_manual}'
										</span>
									</td>
									<td class="text-end">'
										echo -n '
										<a class="material-icons text-success" href="index.cgi?page=main&section=save&option=disconnect&'; \
											if [[ "${disconnect}" == "manual" ]]; then
												echo -n 'query=">
												<i style="font-size: 1.1rem;" class="bi bi-check-square text-secondary"></i>'
											else
												echo -n 'query=manual">
												<i style="font-size: 1.1rem;" class="bi bi-square text-secondary"></i>'
											fi
											echo -n '
										</a>
									</td>
								</tr>
								<tr>'
									# Optische und akustische Signalausgabe ein/aus
									echo '
									<td scope="row" class="row-sm-auto">
										'${txt_autopilot_signal}'
									</td>
									<td class="text-end">'
										echo -n '
										<a class="material-icons text-success" href="index.cgi?page=main&section=save&option=signal&'; \
											if [[ "${signal}" == "true" ]]; then
												echo -n 'query=">
												<i style="font-size: 1.1rem;" class="bi bi-check-square text-secondary"></i>'
											else
												echo -n 'query=true">
												<i style="font-size: 1.1rem;" class="bi bi-square text-secondary"></i>'
											fi
											echo -n '
										</a>
									</td>
								</tr>
							</tbody>
						</table>
					</div>
				</div>
			</div>
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

