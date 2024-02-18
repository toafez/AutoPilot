#!/bin/bash
# Filename: index.cgi - coded in utf-8

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


# Initiate system
# --------------------------------------------------------------
	PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/syno/bin:/usr/syno/sbin

	app_name="AutoPilot"
	app_home=$(echo /volume*/@appstore/${app_name}/ui)
	app_link=$(echo /webman/3rdparty/${app_name})
	[ ! -d "${app_home}" ] && exit

	# Read the version of the AutoPilot app from the INFO.sh file
	app_version=$(cat "/var/packages/${app_name}/INFO" | grep ^version | cut -d '"' -f2)

# Evaluate app authentication
# --------------------------------------------------------------
    # To evaluate the login.cgi, change REQUEST_METHOD to GET
	if [[ "${REQUEST_METHOD}" == "POST" ]]; then
		REQUEST_METHOD="GET"
		OLD_REQUEST_METHOD="POST"
	fi

	# Read and check the login authorization ( login.cgi )
	syno_login=$(/usr/syno/synoman/webman/login.cgi)

	# Login permission ( result=success )
	if echo ${syno_login} | grep -q result ; then
		login_result=$(echo "${syno_login}" | grep result | cut -d ":" -f2 | cut -d '"' -f2)
	fi
	[[ ${login_result} != "success" ]] && { echo 'Access denied'; exit; }

	# Login successful ( success=true )
	if echo ${syno_login} | grep -q success ; then
		login_success=$(echo "${syno_login}" | grep success | cut -d "," -f3 | grep success | cut -d ":" -f2 | cut -d " " -f2 )
	fi
	[[ ${login_success} != "true" ]] && { echo 'Access denied'; exit; }

	# Set REQUEST_METHOD back to POST again
	if [[ "${OLD_REQUEST_METHOD}" == "POST" ]]; then
		REQUEST_METHOD="POST"
		unset OLD_REQUEST_METHOD
	fi

# Evaluate app permissions
# --------------------------------------------------------------
if cat /etc/group | grep ^administrators | grep -q ${app_name} ; then
	permissions="true"
else
	permissions="false"
fi

# Set environment variables
# --------------------------------------------------------------
	# Set up folder for temporary data
	app_temp="${app_home}/temp"
	[ ! -d "${app_temp}" ] && mkdir -p -m 755 "${app_temp}"
	result="${app_temp}/result.txt"

	# Set up folder for user data
	usr_settings="${app_home}/usersettings"
	[ ! -d "${usr_settings}" ] && mkdir -p -m 755 "${usr_settings}"

	# Set up folder for custom settings
	usr_systemconfig="${usr_settings}/system"
	[ ! -d "${usr_systemconfig}" ] && mkdir -p -m 755 "${usr_systemconfig}"

	# Set up folder for device id's
	usr_devices="${usr_settings}/devices"
	[ ! -d "${usr_devices}" ] && mkdir -p -m 755 "${usr_devices}"

	# Set up configuration file for AutoPilot
	usr_autoconfig="${usr_systemconfig}/autopilot.config"
	if [ ! -f "${usr_autoconfig}" ]; then
		touch "${usr_autoconfig}"
		chmod 777 "${usr_autoconfig}"
	fi
	[ -f "${usr_autoconfig}" ] && source "${usr_autoconfig}"

	# Set up folder for log files
	usr_logfiles="${usr_settings}/logfiles"
	[ ! -d "${usr_logfiles}" ] && mkdir -p -m 755 "${usr_logfiles}"

	# Check if AutoPilot UDEV rule is located at /usr/lib/udev/rules.d
	[ -f /usr/lib/udev/rules.d/99-autopilot.rules ] && udev_rule="true"

	# Check if AutoPilot UDEV rule points to Basic Backup
	udev_appcheck=$(grep -w /usr/lib/udev/rules.d/99-autopilot.rules -e "BasicBackup")
	[ -n "${udev_appcheck}" ] && rewrite_udev="true"

	# Evaluate POST and GET requests and cache them in files
	set_keyvalue="/usr/syno/bin/synosetkeyvalue"
	get_keyvalue="/bin/get_key_value"
	get_request="$app_temp/get_request.txt"
	post_request="$app_temp/post_request.txt"

	# If no page set, then show home page
	if [ -z "${get[page]}" ]; then
		"${set_keyvalue}" "${get_request}" "get[page]" "main"
		"${set_keyvalue}" "${get_request}" "get[section]" "start"
	fi


# Processing GET/POST request variables
# --------------------------------------------------------------
	# Load urlencode and urldecode function from ../modules/parse_url.sh
	[ -f "${app_home}/modules/parse_url.sh" ] && source "${app_home}/modules/parse_url.sh" || exit

	[ -z "${POST_STRING}" -a "${REQUEST_METHOD}" = "POST" -a ! -z "${CONTENT_LENGTH}" ] && read -n ${CONTENT_LENGTH} POST_STRING

	# Securing the Internal Field Separator (IFS) as well as the separation
	# of the GET/POST key/value requests, by locating the separator "&"
	if [ -z "${backupIFS}" ]; then
		backupIFS="${IFS}"
		IFS='=&'
		GET_vars=(${QUERY_STRING})
		POST_vars=(${POST_STRING})
		readonly backupIFS
		IFS="${backupIFS}"
	fi

	# Analyze incoming GET requests and process them to ${get[key]}="$value" variables
	declare -A get
	for ((i=0; i<${#GET_vars[@]}; i+=2)); do
		GET_key=get[${GET_vars[i]}]
		GET_value=${GET_vars[i+1]}
		#GET_value=$(urldecode ${GET_vars[i+1]})

		# Reset saved GET/POST requests if main is set
		if [[ "${get[page]}" == "main" ]] && [ -z "${get[section]}" ]; then
			[ -f "${get_request}" ] && rm "${get_request}"
			[ -f "${post_request}" ] && rm "${post_request}"
		fi

		# Saving GET requests for later processing
		"${set_keyvalue}" "${get_request}" "$GET_key" "$GET_value"
	done

	# Analyze incoming POST requests and process to ${var[key]}="$value" variables
	declare -A post
	for ((i=0; i<${#POST_vars[@]}; i+=2)); do
		POST_key=post[${POST_vars[i]}]
		#POST_value=${POST_vars[i+1]}
		POST_value=$(urldecode ${POST_vars[i+1]})

		# Saving POST requests for later processing
		"${set_keyvalue}" "${post_request}" "$POST_key" "$POST_value"
	done

	# Inclusion of the temporarily stored GET/POST requests ( key="value" ) as well as the user settings
	[ -f "${get_request}" ] && source "${get_request}"
	[ -f "${post_request}" ] && source "${post_request}"

# Layout output
# --------------------------------------------------------------
if [ $(synogetkeyvalue /etc.defaults/VERSION majorversion) -ge 7 ]; then

	# Load language settings from ../modules/parse_language.sh
	[ -f "${app_home}/modules/parse_language.sh" ] && source "${app_home}/modules/parse_language.sh" || exit
	language "GUI"

	# Load Website features from ../modules/html.function.sh
	[ -f "${app_home}/template/html_functions.sh" ] && source "${app_home}/template/html_functions.sh" || exit

	echo "Content-type: text/html"
	echo
	echo '
	<!doctype html>
	<html lang="en">
		<head>
			<meta charset="utf-8" />
			<title>'${app_title}'</title>
			<link rel="shortcut icon" href="images/icon_32.png" type="image/x-icon" />
			<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />

			<!-- Integrating my own CSS formatting -->
			<link rel="stylesheet" href="template/css/stylesheet.css" />

			<!-- Integrating bootstrap framework 5.3.2 -->
			<link rel="stylesheet" href="template/bootstrap/css/bootstrap.min.css" />

			<!-- Integrating bootstrap Icons 1.11.3 -->
			<link rel="stylesheet" href="template/bootstrap/font/bootstrap-icons.css" />

			<!-- Integrating jQuery 3.7.1 -->
			<script src="template/jquery/jquery-3.7.1.min.js"></script>

			<!-- Integrating highlight.js 11.9.0 (https://highlightjs.org/) -->
			<link rel="stylesheet" href="template/js/highlight/styles/atom-one-light.min.css">
			<script src="template/js/highlight/highlight.min.js"></script>
			<script>hljs.highlightAll();</script>

			<!-- Integrating JavaScript bzw. jQuery functions in the HTML header  -->
			<script src="template/js/head-functions.js"></script>
		</head>
		<body>
			<header></header>
			<article>
				<!-- container -->
				<div class="container-lg">'

					# Function: Show main navigation
					# --------------------------------------------------------------
					function mainnav()
					{
						echo '
						<nav class="navbar fixed-top navbar-expand-sm navbar-light bg-light">
							<div class="container-fluid">
								<a class="btn btn-sm text-dark text-decoration-none py-0" role="button" style="background-color: #e6e6e6;" href="index.cgi?page=main&section=reset" title="'${txt_button_refresh}'">
									<i class="bi bi-arrow-repeat text-dark" style="font-size: 1.2rem;"></i>
								</a>
								<div class="float-end">
									<ul class="navbar-nav">
										<li class="nav-item pt-1">
											<a class="btn btn-sm text-dark text-decoration-none" aria-current="page" style="background-color: #e6e6e6;" href="index.cgi?page=view&section=autopilot&file='${usr_logfiles}'/autopilot.log">'${txt_label_logfile}'</a>
										</li>&nbsp;&nbsp;
										<li class="nav-item dropdown pt-1">
											<a class="dropdown-toggle btn btn-sm text-dark text-decoration-none" style="background-color: #e6e6e6;" href="#" id="navDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
												'${txt_link_settings}'
											</a>
											<ul class="dropdown-menu dropdown-menu-sm-end" aria-labelledby="navDropdown">'
												if [[ "${permissions}" == "true" ]]; then
													echo '<li><button type="button" class="dropdown-item" data-bs-toggle="modal" data-bs-target="#help-app_permissions">'${txt_link_revoke_permissions}'</button></li>'
												else
													echo '<li><button type="button" class="dropdown-item" data-bs-toggle="modal" data-bs-target="#help-app_permissions">'${txt_link_expand_permissions}'</button></li>'
												fi
												if [[ "${udev_rule}" == "true" ]]; then
													if [[ "${rewrite_udev}" == "true" ]]; then
														echo '<li><button type="button" class="dropdown-item" data-bs-toggle="modal" data-bs-target="#help-udev_device_driver">'${txt_button_install_driver}'</button></li>'
													else
														echo '<li><button type="button" class="dropdown-item" data-bs-toggle="modal" data-bs-target="#help-udev_device_driver">'${txt_button_uninstall_driver}'</button></li>'
													fi
								else
									echo '<li><button type="button" class="dropdown-item" data-bs-toggle="modal" data-bs-target="#help-udev_device_driver">'${txt_button_install_driver}'</button></li>'
								fi
												echo '
											</ul>
										</li>&nbsp;&nbsp;
										<li class="nav-item dropdown pt-1">
											<a class="dropdown-toggle btn btn-sm text-dark text-decoration-none" style="background-color: #e6e6e6; href="#" id="navDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
												'${txt_link_help}'
											</a>
											<ul class="dropdown-menu dropdown-menu-sm-end" aria-labelledby="navDropdown">
												<li><button type="button" class="dropdown-item" data-bs-toggle="modal" data-bs-target="#help-autopilot_setup_via_dsm">'${txt_link_help_dsm}'</button></li>
												<li><button type="button" class="dropdown-item" data-bs-toggle="modal" data-bs-target="#help-autopilot_setup_via_terminal">'${txt_link_help_terminal}'</button></li>
											</ul>
										</li>
									</ul>
								</div>
							</div>
						</nav>
						<p>&nbsp;</p>
						<br />'
					}

					# Function: Show help articles in the pop-up window
					# --------------------------------------------------------------
					function help_modal ()
					{
						echo '
						<!-- Modal -->
						<div class="modal fade" id="help-'${1}'" tabindex="-1" aria-labelledby="help-'${1}'-label" aria-hidden="true">
							<div class="modal-dialog modal-fullscreen">
								<div class="modal-content">
									<div class="modal-header bg-light">
										<h5 class="modal-title" style="color: #FF8C00;" id="help-'${1}'-label"><span class="navbar-brand">'${2}'</span></h5>
										<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" title="'${txt_button_Close}'"></button>
									</div>
									<div class="modal-body">'
										[ -f "${app_home}/help/${1}.sh" ] && source "${app_home}/help/${1}.sh" || echo "Page not found"
										echo '
									</div>
								</div>
							</div>
						</div>'
					}

					# Load help article
					# --------------------------------------------------------------
					help_modal "autopilot" "${txt_link_help_autopilot}"
					help_modal "autopilot_setup_via_dsm" "${txt_link_help_dsm}"
					help_modal "autopilot_setup_via_terminal" "${txt_link_help_terminal}"
					if [[ "${udev_rule}" == "true" ]] ;then
						if [[ "${rewrite_udev}" == "true" ]]; then
							help_modal "udev_device_driver" "${txt_link_help_install}"
						else
							help_modal "udev_device_driver" "${txt_link_help_uninstall}"
						fi
					else
						help_modal "udev_device_driver" "${txt_link_help_install}"
					fi
					if [[ "${permissions}" == "true" ]]; then
						help_modal "app_permissions" "${txt_link_revoke_permissions}"
					else
						help_modal "app_permissions" "${txt_link_expand_permissions}"
					fi

					# Note Badges
					# --------------------------------------------------------------
					note="<span class=\"text-primary text-uppercase ms-1\" style=\"border: solid #e6e6e6; border-width: 2px 4px; border-radius: 3px; background-color: #e6e6e6;\" title=\"${txt_link_note}\"><i class=\"bi bi-info-square\"></i><i class=\"bi bi-caret-down-fill text-dark align-middle pb-1 ps-1\" style=\"font-size: 0.4rem;\"></i></span>"

				# Function: Include header
				# --------------------------------------------------------------
				function header()
				{
					echo '<h2>'${txtAppTitle}'</h2>'
				}

				# Load page content
				# --------------------------------------------------------------

					# Dynamic page output
					if [ -f "${post[page]}.sh" ]; then
						. ./"${post[page]}.sh"
					elif [ -f "${get[page]}.sh" ]; then
						. ./"${get[page]}.sh"
					else
						echo 'Page '${get[page]}'.sh not found!'
					fi


					echo '
				</div>
				<!-- container -->
			</article>

			<!-- Integrating bootstrap JavaScript 5.3.2 -->
			<script src="template/bootstrap/js/bootstrap.bundle.min.js"></script>

			<!-- Integrating JavaScript bzw. jQuery functions in the HTML body  -->
			<script src="template/js/body-functions.js"></script>
		</body>
	</html>'
fi
exit
