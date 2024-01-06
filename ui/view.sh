#!/bin/bash
# Filename: view.sh - coded in utf-8

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


# Header of the log
# --------------------------------------------------------------
if [[ "${get[page]}" == "view" ]]; then
	[ -f "${get_request}" ] && rm "${get_request}"

	echo '
	<!-- Modal -->
	<div class="modal fade" id="view" tabindex="-1" aria-labelledby="view-label" aria-hidden="true">
		<div class="modal-dialog modal-fullscreen">
			<div class="modal-content">
				<div class="modal-header bg-light">
					<h5 class="modal-title" style="color: #FF8C00;">'${txt_view_logfile}'</h5>
					<a href="index.cgi?page=main&section=start" class="btn-close" aria-label="Close" title="'${txt_button_Close}'"></a>
				</div>
				<div class="modal-body">
					<div class="row">
						<div class="col">'

							# Show protocol
							# --------------------------------------------------------------
							get[file]=$(urldecode ${get[file]})

							if [ -z "${get[process]}" ] || [[ "${get[process]}" == "stopped" ]]; then
								if [ -s "${get[file]}" ]; then
									# Output file contents
									echo '
									<div class="text-monospace text-nowrap" style="font-size: 87.5%;">'
										while read line; do
											echo ''${line}'<br>'
										done < "${get[file]}"
										unset line
										echo '
									</div>'
								else
									echo ''${txt_view_logfile_not_found}''
								fi
							fi
							echo '
						</div>
					</div>

				<!-- Modal -->
				</div>
				<div class="modal-footer bg-light">'
					if [[ "${get[section]}" == "autopilot" ]]; then
						if [ -s "${usr_logfiles}"/autopilot.log ]; then
							echo '
							<a href="'${app_link}'/usersettings/logfiles/'${get[file]##*/}'" class="btn btn-secondary btn-sm" download>'${txt_button_download_logfile}'</a>'
						fi
						echo '&nbsp;<a href="index.cgi?page=view&section=autopilot&query=delete&file='${get[file]}'" class="btn btn-secondary btn-sm">'${txt_button_delete_logfile}'</a>'
					fi
					echo '
					<a href="index.cgi?page=main&section=start&expand=true" class="btn btn-secondary btn-sm" aria-label="Close">'${txt_button_Close}'</a>
				</div>
			</div>
		</div>
	</div>
	<script type="text/javascript">
		$(window).on("load", function() {
			$("#view").modal("show");
		});
	</script>'

	# Clear log
	# --------------------------------------------------------------
	if [[ "${get[query]}" == "delete" ]] && [ -z "${get[delete]}" ]; then
		[[ "${get[section]}" == "autopilot" ]] && popup_modal "protocolview" "${txt_popup_delete}" "${txt_popup_delete_logfile}" "autopilot" ""
	elif [[ "${get[query]}" == "delete" ]]  && [[ "${get[delete]}" == "true" ]]; then
		[ -f "${get_request}" ] && rm "${get_request}"
		[ -f "${get[file]}" ] && :> "${get[file]}"
		if [[ "${get[section]}" == "autopilot" ]]; then
			echo '<meta http-equiv="refresh" content="0; url=index.cgi?page=view&section=autopilot&file='${usr_logfiles}'/autopilot.log&query=&delete=">'
		fi
	fi
fi
