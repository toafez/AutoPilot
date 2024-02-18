#!/bin/bash
# Filename: html.function.sh - coded in utf-8

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


# Funktion: Popup Box - jobedit
# --------------------------------------------------------------
function popup_modal()
{
	# Syntax popupbox "Call" "Title" "Content" "Section" "modal-fullscreen"
	#                  ${1}   ${2}     ${3}      ${4}          ${5}
	echo '
	<!-- Modal -->
	<div class="modal fade" id="popup-validation" tabindex="-1" aria-labelledby="label-validation" aria-hidden="true">
	  <div class="modal-dialog '${5}'">
		<div class="modal-content">
		  <div class="modal-header bg-light">
			<h5 class="modal-title align-baseline" style="color: #FF8C00;">'${2}'</h5>
			<a href="index.cgi" onclick="history.go(-1); event.preventDefault();" class="btn-close" aria-label="Close"></a>
		  </div>
		  <div class="modal-body bg-light">'
			if [[ "${1}" == "scriptview" ]]; then
				if [ -f "${3}" ]; then
					echo '
					<i class="bi bi-hdd-fill text-secondary"></i>&nbsp;&nbsp;<strong>'${txt_autopilot_script_target}': </strong>'${3}'<br />
						<pre style="overflow-x:auto;"><code>'
							IFS”
							”
							while read line; do
								echo "${line}"
							done < "${3}"
							unset line
							echo '
						</code></pre>'
				else
					echo '
					<i class="bi bi-hdd-fill text-secondary"></i>&nbsp;&nbsp;<strong class="text-danger">'${txt_autopilot_scriptfile_error}'</strong><br /><br />
					<div class="card card-body text-center ps-1">
						<span class="text-danger">'${txt_autopilot_scriptfile_errormsg1}'</span><br />
						'${scriptfile}'
						<span class="text-danger">'${txt_autopilot_scriptfile_errormsg2}'</span><br />
					</div>'
				fi
				unset line
				if [[ "${4}" == "autopilot" ]]; then
					echo '
					<div class="px-3">
						<br />
						'${txt_autopilot_change_note_step_1}'<br /><br />
						<ol>
							<li>'${txt_autopilot_change_note_step_2}'</li>
							<br />
							<li>'${txt_help_setup_dsm_step_4}'</li>
							<br />
								<ul class="ps-3">
									<li>'${txt_help_setup_dsm_step_5}'</li>
									<br />
									<li>'${txt_help_setup_dsm_step_6}'</li>
									<br />
								</ul>
							<li>'${txt_help_setup_dsm_step_7}'</li>
							<br />
							<li>'${txt_help_setup_dsm_step_8}'</li>
					</div>'
				fi
			fi
			if [[ "${1}" == "protocolview" ]]; then
				echo '<p class="card-text text-center text-secondary">'${3}'</p>'
			fi
			echo '
		  </div>
		  <div class="modal-footer bg-light">
			<a class="btn btn-sm text-dark" style="background-color: #e6e6e6;" href="index.cgi" onclick="history.go(-1); event.preventDefault();" aria-label="Close">'${txt_button_Close}'</a>'
			if [[ "${1}" == "protocolview" ]]; then
				echo '
				<a class="btn btn-sm text-dark" style="background-color: #e6e6e6;" href="index.cgi?page=view&section='${4}'&query=delete&delete=true&file='${get[file]}'"  style="background-color: #e6e6e6;">Löschen</a>'
			fi
			echo '
		  </div>
		</div>
	  </div>
	</div>
	<script type="text/javascript">
		$(window).on("load", function() {
			$("#popup-validation").modal("show");
		});
	</script>'
}
