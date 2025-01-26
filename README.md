[English](README_en.md) | Deutsch

# ![Package icon](/ui/images/icon_24.png) AutoPilot für externe Datenträger
![GitHub Release](https://img.shields.io/github/v/release/toafez/AutoPilot?link=https%3A%2F%2Fgithub.com%2Ftoafez%2FAutoPilot%2Freleases)
[![Hits](https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2Ftoafez%2FAutoPilot&count_bg=%2379C83D&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=hits&edge_flat=false)](https://hits.seeyoufarm.com)

AutoPilot ermöglicht das Ausführen von beliebigen Shellscript Anweisungen, die nach dem Anschluss eines externen Datenträgers an deine Synology DiskStation automatisch ausgeführt werden. Vorhandene Basic Backup Aufträge sowie Hyper Backup Aufgaben (ab Version 4) werden dabei in AutoPilot übersichtlich angezeigt und lassen sich mit bereits vorkonfigurierten Shellscripts verbinden und somit ebenfalls ausführen. Nach der Ausführung kann der externe Datenträger auf Wunsch wieder automatisch ausgeworfen werden.

## Einen externen Datenträger einrichten
Zur späteren Identifizierung eines externen Datenträgers wird in einer Ersteinrichtung die UUID (Universally Unique Identifier) der ausgewählten Partition bzw. des sich darauf befindlichen Dateisystems ausgelesen. Anschließend wird eine leere Datei mit dem Namen autopilot (ohne Dateiendung) im Wurzelverzeichnis der zuvor ausgewählten Partition abgelegt. Im nächsten Schritt muss der Name und der Speicherort des auszuführenden Shellscripts angegeben werden, welches sich idealerweise in einem gemeinsamen Ordner der DiskStation befinden sollte. Abschließend wird die so ermittelte UUID mit den Angaben zum Shellscript fest miteinander verknüpft und intern gespeichert. Damit ist die Ersteinrichtung abgeschlossen.

## So funktioniert AutoPilot genau
AutoPilot nutzt, wie weiter oben bereits beschrieben, die UUID der ausgewählten Partition bzw. des sich darauf befindlichen Dateisystems eines externen Datenträgers zur eindeutigen Identifikation. Die so ermittelte UUID wird im dem, von Synology bereitgestellten AutoPilot Paketordner in Form eines Dateinamens abgespeichert und ist somit vor fremden Zugriff weitestgehend geschützt. In dieser Datei wird im Anschluss der Pfad und der Dateiname des eigentlich auszuführenden Shellscripts als Variable hinterlegt. Das Shellscript selbst sollte sich dabei innerhalb der Ordnerstruktur eines gemeinsamen Ordners der DiskStation befinden um diese ebenfalls vor fremden Zugriff zu schützen. Es besteht zwar die Möglichkeit, das Shellscript auf dem externen Datenträger selbst zu hinterlegen, jedoch wird aus Sicherheitsgründen davon abgeraten.
Der so präparierte externe Datenträger wird zukünftig beim anschließen an deine Synology DiskStation durch AutoPilot eindeutig identifiziert. Dabei durchsucht eine sogenannte UDEV-Regel in allen vorhandenen Partitionen des externen Datenträger nach der leeren Datei autopilot. War die Suche erfolgreich, wird die ermittelte UUID des extern angeschlossenen Datenträgers mit der intern gespeicherten UUID verglichen und bei Übereinstimmung mit dem damit verknüpften Shellscript verbundenen und ausgeführt. Durch dieses Vorgehen ist sichergestellt, das über den externen Datenträger kein Schadcode in Verbindung mit AutoPilot ausgeführt werden kann.

# Systemvoraussetzungen
**AutoPilot für externe Datenträger** wurde speziell für die Verwendung auf **Synology NAS Systemen** entwickelt die das Betriebsystem **DiskStation Mangager 7.0** oder höher verwenden. Für die Anzeige und Weiterverarbeitung von **Hyper Backup Aufgaben wird die Version 4** von Hyper Backup **benötigt**, die zusammen mit dem **DiskStation Manager 7.2** veröffentlicht wurde.

# Installationshinweise
[HowTo: AutoPilot - Herunterladen. Installieren. Einrichten.](https://github.com/toafez/HowTo_Syno.AutoPilot)

**Nach dem Start** von AutoPilot wird die lokal **installierte Version** mit der auf GitHub **verfügbaren Version** verglichen. Steht ein Update zur Verfügung, wird der Benutzer über die App darüber **informiert** und es wird ein entsprechender **Link** zu dem ensprechenden Release eingeblendet. Der Download sowie der anschließende Updatevorgang wurde bereits in dem verlinkten HowTo erläutert.

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
