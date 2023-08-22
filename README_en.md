English | [Deutsch](README.md)

# ![Package icon](/ui/images/icon_24.png) AutoPilot for external USB/SATA drives
AutoPilot allows executing shell script instructions that run automatically after connecting an external USB/SATA disk to a Synology DiskStation. After execution, the external data medium can be automatically ejected again if desired.

# System requirements
**AutoPilot for external USB/SATA drives** is specially designed for use on **Synology NAS systems** running **DiskStation Mangager 7** or later operating system.

# Installation instructions
Download the **latest version** of AutoPilot from the [Releases](https://github.com/toafez/AutoPilot/releases) section. Then open the **Package Center** in the **DiskStation Manager (DSM)**, select the **Manual Installation** button at the top right and follow the **Wizard** to install the new **Package** or upload and install the corresponding **.spk file**. This process is identical for both an initial installation and for performing an update.

**After starting** AutoPilot, the locally **installed version** is compared to the version **available** on GitHub. If an update is available, the user will be **informed** about it via the app and a corresponding **link** to the corresponding release will be displayed. The download and the subsequent update process have already been explained above.

- ## (De)-activate device driver for detection of external USB/SATA data carriers
     - ### Activate device driver via console
         - Log in to your DiskStation's console as root user and run the following command

             - Command to activate the device driver via the console

                 `/usr/syno/synoman/webman/3rdparty/AutoPilot/init.sh "autopilot enable"`

             - Command to disable the device driver from the console

                 `/usr/syno/synoman/webman/3rdparty/AutoPilot/init.sh "autopilot disable"`

     - ### (De)-activate device drivers via the DSM task scheduler
         - Open Task Scheduler in DSM under Main Menu > Control Panel.
         - In the task scheduler, select Create > Scheduled Task > Custom Script button.
         - In the pop-up window that opens, give the task an individual name in the General > General settings tab and select root as the user. Then uncheck the Enabled box.
         - In the Task settings tab > Run command > Custom script, paste the following command into the text field...

             - Command to activate the device driver via the task scheduler

                 `/usr/syno/synoman/webman/3rdparty/AutoPilot/init.sh "autopilot enable"`

             - Disable command to disable device driver via task scheduler

                 `/usr/syno/synoman/webman/3rdparty/AutoPilot/init.sh "autopilot disable"`

         - Confirm your entries with the OK button and also accept the subsequent warning message with OK.
         - In order for the task to be added to the task scheduler, you must finally enter the password of the user who is currently logged in to the DSM and confirm the process using the Send button.
         - In the overview of the task planner, you must now mark the task you have just created with the mouse (the line should have a blue background after marking), but do not tick the checkbox to activate the task permanently.
         - Execute the task once by pressing the Execute button.
         - Close and re-enter AutoPilot for the changes to take effect.

- ## Set up AutoPilot for an external USB/SATA data carrier
         - In the AutoPilot app, under the **Help** menu item, you will find detailed instructions on how to set up an external USB/SATA data carrier either via the console or via the DSM task scheduler.

# History
- You can find details on the version history in the [CHANGELOG](CHANGELOG) file.

# Developer information
- Backend details: [Synology DSM 7.0 Developer Guide](https://help.synology.com/developer-guide/)
- Frontend details: [Bootstrap Framework](https://getbootstrap.com/)
- Details about jQuery: [jQuery API](https://api.jquery.com/)

# Help and Discussion
- Help and discussion are welcome via [The German Synology Support Forum](https://www.synology-forum.de) or via [heimnetz.de](https://forum.heimnetz.de)

# License
This program is free software. You can redistribute it and/or modify it under the terms of the **GNU General Public License** as published by the Free Software Foundation, either **Version 3** of the License or (at your option) any later version

This program is released in the hope that you will find it useful, but **WITHOUT ANY WARRANTY**, even **without the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE**. See the [GNU General Public License](LICENSE) file for details.