#!/bin/bash
# Filename: autopilot_status.sh - coded in utf-8

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

#lang="enu"

# Deutsche Sprachausgabe
# --------------------------------------------------------------
echo '
<div class="row">
	<div class="col">'
		if [[ "${udev_rule}" == "true" ]]; then
			if [[ "${rewrite_udev}" == "true" ]]; then
				echo '<h5>'${txt_help_status_aktivate_terminal}'</h5>'
			else
				echo '<h5>'${txt_help_status_deaktivate_terminal}'</h5>'
			fi
		else
			echo '<h5>'${txt_help_status_aktivate_terminal}'</h5>'
		fi
		echo '
		<ul class="list-unstyled ps-4">
			<ol>
				<li>'${txt_help_status_step_1}'</li>
					<ul class="list-unstyled ps-3 pt-2">
						<li>
							<small>'
								if [[ "${udev_rule}" == "true" ]]; then
									if [[ "${rewrite_udev}" == "true" ]]; then
										echo '<pre class="text-dark p-1 border border-1 rounded bg-light">/usr/syno/synoman/webman/3rdparty/'${app_name}'/init.sh "autopilot enable"</pre>'
									else
										echo '<pre class="text-dark p-1 border border-1 rounded bg-light">/usr/syno/synoman/webman/3rdparty/'${app_name}'/init.sh "autopilot disable"</pre>'
									fi
								else
									echo '<pre class="text-dark p-1 border border-1 rounded bg-light">/usr/syno/synoman/webman/3rdparty/'${app_name}'/init.sh "autopilot enable"</pre>'
								fi							
								echo '
							</small>
						</li>
					</ul>
			</ol>
		</ul>
		<br />'
		if [[ "${udev_rule}" == "true" ]]; then
			if [[ "${rewrite_udev}" == "true" ]]; then
				echo '<h5>'${txt_help_status_aktivate_dsm}'</h5>'
			else
				echo '<h5>'${txt_help_status_deaktivate_dsm}'</h5>'
			fi
		else
			echo '<h5>'${txt_help_status_aktivate_dsm}'</h5>'
		fi
		echo '	
		<ul class="list-unstyled ps-4">
			<ol>
				<li>'${txt_help_status_step_2}'</li>
				<li>'${txt_help_status_step_3}'</li>
				<li>'${txt_help_status_step_4}'</li>
				<li>'${txt_help_status_step_5}'</li>
					<ul class="list-unstyled ps-3 pt-2">
						<li>
							<small>'
								if [[ "${udev_rule}" == "true" ]]; then
									if [[ "${rewrite_udev}" == "true" ]]; then
										echo '<pre class="text-dark p-1 border border-1 rounded bg-light">/usr/syno/synoman/webman/3rdparty/'${app_name}'/init.sh "autopilot enable"</pre>'
									else
										echo '<pre class="text-dark p-1 border border-1 rounded bg-light">/usr/syno/synoman/webman/3rdparty/'${app_name}'/init.sh "autopilot disable"</pre>'
									fi
								else
									echo '<pre class="text-dark p-1 border border-1 rounded bg-light">/usr/syno/synoman/webman/3rdparty/'${app_name}'/init.sh "autopilot enable"</pre>'
								fi							
								echo '
							</small>
						</li>
					</ul>
				<li>'${txt_help_status_step_6}'</li>
				<li>'${txt_help_status_step_7}'</li>
				<li>'${txt_help_status_step_8}'</li>
				<li>'${txt_help_status_step_9}'</li>
				<li>'${txt_help_status_step_10}'</li>
			</ol>
		</ul>
		<p class="text-end"><br />
			<button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">'${txt_button_Close}'</button>
		</p>
	</div>
</div>'
