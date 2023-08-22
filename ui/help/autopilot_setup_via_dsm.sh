#!/bin/bash
# Filename: setup_via_dsm.sh - coded in utf-8

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

echo '
<div class="row">
	<div class="col">
		<ol>
			<li>'${txt_help_setup_dsm_step_1}'</li>
			<li>'${txt_help_setup_dsm_step_2}'</li>
			<li>'${txt_help_setup_step_1}'
			<br /><br />
				<ul class="list-unstyled ps-3">
					<li>
						<small>
							<pre class="text-dark p-1 border border-1 rounded bg-light">#!/bin/bash</pre>
						</small>
					</li>
				</ul>
				'${txt_help_setup_step_2}'
				<br /><br />
				<ul class="list-unstyled ps-3">
					<li>
						<small>
							<pre class="text-dark p-1 border border-1 rounded bg-light">rsync -av /volume1/public/ /volumeUSB1/usbshare/backup</pre>
						</small>
					</li>
				</ul>
				'${txt_help_setup_step_3}'
				<br /><br />
				<ul class="list-unstyled ps-3">
					<li>
						<small>
							<pre class="text-dark p-1 border border-1 rounded bg-light">exit ${?}</pre>
						</small>
					</li>
				</ul>
				'${txt_help_setup_step_4}'
				<br /><br />
				<ul class="list-unstyled ps-3">
					<li>
						<small>
							<pre class="text-dark p-1 border border-1 rounded bg-light">exit 100</pre>
						</small>
					</li>
				</ul>
				'${txt_help_setup_step_5}'
				<br /><br />
				<ul class="list-unstyled ps-3">
					<li>
						<small>
							<pre class="text-dark p-1 border border-1 rounded bg-light">#!/bin/bash<br />rsync -av /volume1/public/ /volumeUSB1/usbshare/backup"<br />exit ${?}</pre>
						</small>
					</li>
				</ul>
			</li>
			<li>'${txt_help_setup_dsm_step_3}'</li>
			<li>'${txt_help_setup_dsm_step_4}'</li>
				<br />
				<ul>
					<li>'${txt_help_setup_dsm_step_5}'</li>
					<br />
					<li>'${txt_help_setup_dsm_step_6}'</li>
				</ul>
				<br />
			<li>'${txt_help_setup_dsm_step_7}'</li>
		</ol>
		<p class="text-end"><br />
			<button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">'${txt_button_Close}'</button>
		</p>
	</div>
</div>'