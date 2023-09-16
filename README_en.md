English | [Deutsch](README.md)

# ![Package icon](/ui/images/icon_24.png) AutoPilot for external drives
AutoPilot allows executing shell script instructions that run automatically after connecting an external disk to a Synology DiskStation. After execution, the external data medium can be automatically ejected again if desired.

# System requirements
**AutoPilot for external drives** is specially designed for use on **Synology NAS systems** running **DiskStation Mangager 7** or later operating system.

# Installation instructions
Download the **latest version** of AutoPilot from the [Releases](https://github.com/toafez/AutoPilot/releases) section. Then open the **Package Center** in the **DiskStation Manager (DSM)**, select the **Manual Installation** button at the top right and follow the **Wizard** to install the new **Package** or upload and install the corresponding **.spk file**. This process is identical for both an initial installation and for performing an update.

**After starting** AutoPilot, the locally **installed version** is compared to the version **available** on GitHub. If an update is available, the user will be **informed** about it via the app and a corresponding **link** to the corresponding release will be displayed. The download and the subsequent update process have already been explained above.

- ## Extend App Permission
    Under DSM 7, a 3rd_Party application such as AutoPilot (referred to as App in the following) is provided with highly restricted user and group rights. Among other things, this means that system-related commands cannot be executed. For the smooth operation of AutoPilot, however, extended system rights are required, e.g. to be able to access the system folder structure. To extend the app permissions, AutoPilot must be added to the administrators' group, but this can only be done by the user himself. The following instructions describe this process.

    - #### Extending or restricting app permissions via the console

      - Log in to the console of your Synology NAS as user **root**.
      - Command to extend app permissions

        `/usr/syno/synoman/webman/3rdparty/AutoPilot/permissions.sh "adduser"`

      - Command to restrict app permissions

        `/usr/syno/synoman/webman/3rdparty/AutoPilot/permissions.sh "deluser"`
 
    - #### Extend or restrict app permissions via the task planner

      - Open the **Task Scheduler** in **DSM** under **Main Menu** > **Control Panel**.
      - In the **Task Scheduler**, select **Create** > **Scheduled Task** > **Custom Script** via the button.
      - In the pop-up window that now opens in the **General** > **General Settings** tab, give the task a name and select **root** as the user: **root** as the user. Also remove the tick from Activated.
      - In the **Task Settings** tab > **Execute Command** > **Custom Script**, insert the following command into the text field...
      - Command to extend the app permissions

        `/usr/syno/synoman/webman/3rdparty/AutoPilot/permissions.sh "adduser"`

      - Command to restrict app permissions

        `/usr/syno/synoman/webman/3rdparty/AutoPilot/permissions.sh "deluser"`

      - Save the entries with **OK** and confirm the subsequent warning message with **OK**.
      - Mark the task you have just created in the overview of the task planner, but **do not** activate it (the line should be highlighted in blue after marking).
      - Execute the task once by pressing the **Execute** button.

- ## (De)-activate udev device driver for detection of external data carriers
     - ### Activate udev device driver via console
         - Log in to your DiskStation's console as root user and run the following command

             - Command to activate the udev device driver via the console

                 `/usr/syno/synoman/webman/3rdparty/AutoPilot/driver.sh "install"`

             - Command to disable the udev device driver from the console

                 `/usr/syno/synoman/webman/3rdparty/AutoPilot/driver.sh "uninstall"`

     - ### (De)-activate udev device drivers via the DSM task scheduler
         - Open Task Scheduler in DSM under Main Menu > Control Panel.
         - In the task scheduler, select Create > Scheduled Task > Custom Script button.
         - In the pop-up window that opens, give the task an individual name in the General > General settings tab and select root as the user. Then uncheck the Enabled box.
         - In the Task settings tab > Run command > Custom script, paste the following command into the text field...

             - Command to activate the udev device driver via the task scheduler

                 `/usr/syno/synoman/webman/3rdparty/AutoPilot/driver.sh "install"`

             - Disable command to disable udev device driver via task scheduler

                 `/usr/syno/synoman/webman/3rdparty/AutoPilot/driver.sh "uninstall"`

         - Confirm your entries with the OK button and also accept the subsequent warning message with OK.
         - In order for the task to be added to the task scheduler, you must finally enter the password of the user who is currently logged in to the DSM and confirm the process using the Send button.
         - In the overview of the task planner, you must now mark the task you have just created with the mouse (the line should have a blue background after marking), but do not tick the checkbox to activate the task permanently.
         - Execute the task once by pressing the Execute button.
         - Close and re-enter AutoPilot for the changes to take effect.

- ## Set up AutoPilot for an external data carrier
  In the AutoPilot app, under the **Help** menu item, you will find detailed instructions on how to set up an external data carrier either via the console or via the DSM task scheduler.

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
