#!/bin/bash
# Filename: create_script_file.sh - coded in utf-8

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

# Function: Generate Basic Backup Script
# --------------------------------------------------------------
function basic_backup_script ()
{
	basic_backup_job="$1"
	basic_backup_script_tmp_file="$2"

	sed -e "s/___JOB_NAME___/${basic_backup_job}/g" \
		-e "s/___TXT_BASICBACKUP_EXECUTE___/${txt_basicbackup_execute}/g" \
		-e "s/___TXT_BASICBACKUP_TASKNAME___/${txt_basicbackup_taskname}${1}/g" \
		-e "s/___TXT_BASICBACKUP_IN_PROGRESS___/${txt_basicbackup_in_progress}/g" \
		-e "s/___TXT_BASICBACKUP_FINISHED___/${txt_basicbackup_finished}/g" \
		-e "s/___TXT_BASICBACKUP_DURATION___/${txt_basicbackup_duration}/g" \
		"${app_home}"/modules/basic_backup_script.template > "${basic_backup_script_tmp_file}"
}

# Function: Generate Hyper Backup Script
# --------------------------------------------------------------
function hyper_backup_script ()
{
	hyper_backup_job_id="$1"
	hyper_backup_job_name="$2"
	hyper_backup_script_tmp_file="$3"

	sed -e "s/___TASK_ID___/${hyper_backup_job_id}/g" \
		-e "s/___JOB_NAME___/${hyper_backup_job_name}/g" \
		-e "s/___TXT_HYPERBACKUP_EXECUTE___/${txt_hyperbackup_execute}/g" \
		-e "s/___TXT_HYPERBACKUP_TASKNAME___/${txt_hyperbackup_taskname}${2}/g" \
		-e "s/___TXT_HYPERBACKUP_WAIT_FOR_START___/${txt_hyperbackup_wait_for_start}/g" \
		-e "s/___TXT_HYPERBACKUP_IN_PROGRESS___/${txt_hyperbackup_in_progress}/g" \
		-e "s/___TXT_HYPERBACKUP_PID_SEARCH___/${txt_hyperbackup_pid_search}/g" \
		-e "s/___TXT_HYPERBACKUP_PID___/${txt_hyperbackup_pid}/g" \
		-e "s/___TXT_HYPERBACKUP_FINISHED___/${txt_hyperbackup_finished}/g" \
		-e "s/___TXT_HYPERBACKUP_DURATION___/${txt_hyperbackup_duration}/g" \
		-e "s/___TXT_HYPERBACKUP_PID_NOT_FOUND___/${txt_hyperbackup_pid_not_found}/g" \
		-e "s/___TXT_HYPERBACKUP_PURGE_PID_SEARCH___/${txt_hyperbackup_purge_pid_search}/g" \
		-e "s/___TXT_HYPERBACKUP_PURGE_PID___/${txt_hyperbackup_purge_pid}/g" \
		-e "s/___TXT_HYPERBACKUP_PURGE_IN_PROGRESS___/${txt_hyperbackup_purge_in_progress}/g" \
		-e "s/___TXT_HYPERBACKUP_PURGE_FINISHED___/${txt_hyperbackup_purge_finished}/g" \
		-e "s/___TXT_HYPERBACKUP_PURGE_DURATION___/${txt_hyperbackup_purge_duration}/g" \
		-e "s/___TXT_HYPERBACKUP_PURGE_PID_NOT_FOUND___/${txt_hyperbackup_purge_pid_not_found}/g" \
		"${app_home}"/modules/hyper_backup_script.template > "${hyper_backup_script_tmp_file}"
}