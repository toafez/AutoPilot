#!/bin/bash
# Filename: html.function.sh - coded in utf-8

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


# Popupbox Ausgabe
# --------------------------------------------------------------
function popup_box () {
	echo '
	<div class="container">
		<div class="row">
			<div class="col">
			</div>
			<div class="col">
				<p>&nbsp;</p><p>&nbsp;</p>
				<div class="card" style="width: '${1}'rem;">
					<div class="card-header text-secondary">'${2}'</div>
					<div class="card-body">
						<p class="card-text text-center text-secondary">'${3}'</p>
						<p class="card-text text-center text-secondary">'${4}'</p>
					</div>
				</div>
			</div>
			<div class="col">
			</div>
			<!-- col -->
		</div>
		<!-- row -->
	</div>
	<!-- container -->'
	exit
}

# Funktion: Popup Box - jobedit
# --------------------------------------------------------------
function popup_modal()
{
	# Syntax popupbox "Title" "Content" "expand-content false/true"
	echo '
	<!-- Modal -->
	<div class="modal fade" id="popup-validation" tabindex="-1" aria-labelledby="label-validation" aria-hidden="true">
	  <div class="modal-dialog">
		<div class="modal-content">
		  <div class="modal-header bg-light">
			<h5 class="modal-title align-baseline" style="color: #FF8C00;">'${2}'</h5>
			<a href="index.cgi" onclick="history.go(-1); event.preventDefault();" class="btn-close" aria-label="Close"></a>
		  </div>
		  <div class="modal-body text-center">'${3}'</div>
		  <div class="modal-footer bg-light">'
			if [[ "${1}" == "view" ]]; then
				echo '
				<a href="index.cgi?page=view&section='${5}'&query=delete&delete=true&file='${get[file]}'" class="btn btn-secondary btn-sm">Löschen</a>
				<input type="hidden" name="expand-content" value="'${4}'">'
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
