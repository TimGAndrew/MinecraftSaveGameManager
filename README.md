# MinecraftSaveGameManager
A PowerShell GUI to manage Minecraft (Java Edition) Save Games.

This program will manage your default Minecraft save games at "%Appdata%\.Minecraft\Saves\".



-It will back up any game in the above folder to "%Appdata%\.Minecraft\Saves\.MCSGMBackupFolder\<GAMENAME> - MM-dd-yyyy.HH-mm-ss.fff"

eg:

  "%Appdata%\.Minecraft\Saves\My New World"
  
  Will save to:
  
  "%Appdata%\.Minecraft\Saves\.MCSGMBackupFolder\My New World - 06-09-2019.11-26-55.013"
  
-It will also restore any game you have backed up back to its original name, leaving the backup in the backup folder.

-You can have as many game backups as you need.  Each backup creates a new time-stamped instance.

-Feel free to modify/use as you see fit.
