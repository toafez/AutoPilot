[English](README_en.md) | Deutsch

# ![Package icon](/ui/images/icon_24.png) AutoPilot für externe USB/SATA-Datenträger
AutoPilot ermöglicht das Ausführen von Shell-Script Anweisungen, die nach dem Anschluss eines externen USB/SATA-Datenträgers an eine Synology DiskStation automatisch ausgeführt werden. Nach der Ausführung kann der externe Datenträger auf Wunsch wieder automatisch ausgeworfen werden.

# Systemvoraussetzungen
**AutoPilot für externe USB/SATA-Datenträger** wurde speziell für die Verwendung auf **Synology NAS Systemen** entwickelt die das Betriebsystem **DiskStation Mangager 7** oder höher verwenden.

# Installationshinweise
Lade dir die **jeweils aktuellste Version** von AutoPilot aus dem Bereich [Releases](https://github.com/toafez/AutoPilot/releases) herunter. Öffne anschließend im **DiskStation Manager (DSM)** das **Paket-Zentrum**, wähle oben rechts die Schaltfläche **Manuelle Installation** aus und folge dem **Assistenten**, um das neue **Paket** bzw. die entsprechende **.spk-Datei** hochzuladen und zu installieren. Dieser Vorgang ist sowohl für eine Erstinstallation als auch für die Durchführung eines Updates identisch.

**Nach dem Start** von AutoPilot wird die lokal **installierte Version** mit der auf GitHub **verfügbaren Version** verglichen. Steht ein Update zur Verfügung, wird der Benutzer über die App darüber **informiert** und es wird ein entsprechender **Link** zu dem ensprechenden Release eingeblendet. Der Download sowie der anschließende Updatevorgang wurde bereits weiter oben erläutert.

- ## Gerätetreiber für die Erkennung externer USB/SATA-Datenträger (de)-aktivieren
    - ### Gerätetreiber über die Konsole aktivieren
        - Melde dich als Benutzer root auf der Konsole deiner DiskStation an und führe folgenden Befehl aus

            - Befehl um den Gerätetreiber über die Konsole zu aktivieren

                `/usr/syno/synoman/webman/3rdparty/AutoPilot/init.sh "autopilot enable"`

            - Befehl um den Gerätetreiber über die Konsole zu deaktivieren

                `/usr/syno/synoman/webman/3rdparty/AutoPilot/init.sh "autopilot disable"`

    - ### Gerätetreiber über den DSM Aufgabenplaner (de)-aktivieren
        - Öffne im DSM unter Hauptmenü > Systemsteuerung den Aufgabenplaner.
        - Wähle im Aufgabenplaner über die Schaltfläche Erstellen > Geplante Aufgabe > Benutzerdefiniertes Script aus.
        - In dem sich nun öffnenden Pop-up-Fenster gibst du im Reiter Allgemein > Allgemeine Einstellungen der Aufgabe einen individuellen Namen und wählst als Benutzer root aus. Anschließend entfernst du noch den Haken bei Aktiviert.
        - Füge im Reiter Aufgabeneinstellungen > Befehl ausführen > Benutzerdefiniertes Script den nachfolgenden Befehl in das Textfeld ein...

            - Befehl um den Gerätetreiber über den Aufgabenplaner zu aktivieren

                `/usr/syno/synoman/webman/3rdparty/AutoPilot/init.sh "autopilot enable"`

            - Befehl um den Gerätetreiber über den Aufgabenplaner deaktivieren

                `/usr/syno/synoman/webman/3rdparty/AutoPilot/init.sh "autopilot disable"`

        - Bestätige deine Eingaben mit die Schaltfläche OK und akzeptiere die anschließende Warnmeldung ebenfalls mit OK.
        - Damit die Aufgabe dem Aufgabenplaner hinzugefügt wird, musst du abschließend das Passwort deines aktuell am DSM angemeldeten Benutzers eingeben und den Vorgang über die Schaltfläche Senden bestätigen.
        - In der Übersicht des Aufgabenplaners musst du nun die grade erstellte Aufgabe mit der Maus markieren die Zeile sollte nach dem markieren blau hinterlegt sein), jedoch keinen Haken in der Checkbox setzen, um die Aufgabe dauerhaft zu aktivieren.
        - Führe die Aufgabe nun durch betätigen der Schaltfläche Ausführen einmalig aus.
        - Schließe die AutoPilot und rufe sie erneut auf, damit die Änderungen wirksam werden.

- ## AutoPilot für einen externen USB/SATA-Datenträger einrichten
  In der AutoPilot App findest du unter dem Menüpunkt **Hilfe** detailierte Anleitungen, wie du einen externen USB/SATA-Datenträger entweder über die Konsole oder aber über den DSM-Aufgabenplaner einrichten kannst.

# Versionsgeschichte
- Details zur Versionsgeschichte finest du in der Datei [CHANGELOG](CHANGELOG).

# Entwickler-Information
- Details zum Backend: [Synology DSM 7.0 Developer Guide](https://help.synology.com/developer-guide/)
- Details zum Frontend: [Bootstrap Framework](https://getbootstrap.com/)
- Details zu jQuery: [jQuery API](https://api.jquery.com/)

# Hilfe und Diskussion
- Hilfe und Diskussion gerne über [Das deutsche Synology Support Forum](https://www.synology-forum.de) oder über [heimnetz.de](https://forum.heimnetz.de)

# Lizenz
Dieses Programm ist freie Software. Sie können es unter den Bedingungen der **GNU General Public License**, wie von der Free Software Foundation veröffentlicht, weitergeben und/oder modifizieren, entweder gemäß **Version 3** der Lizenz oder (nach Ihrer Option) jeder späteren Version.

Die Veröffentlichung dieses Programms erfolgt in der Hoffnung, daß es Ihnen von Nutzen sein wird, aber **OHNE IRGENDEINE GARANTIE**, sogar **ohne die implizite Garantie der MARKTREIFE oder der VERWENDBARKEIT FÜR EINEN BESTIMMTEN ZWECK**. Details finden Sie in der Datei [GNU General Public License](LICENSE).
