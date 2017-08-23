# What is Console Master?
Console Master is a **Powershell Script** for managing java based servers (**tested** with Minecraft, Minecraft Forge, and Bukkit)

# Download
You can get it from the [Releases](https://github.com/NovaViper/Console-Master/releases) or from [Powershell Gallery](https://www.powershellgallery.com/packages/ConsoleMaster/DisplayScript)

# Virus Note
I can assure you that the ConsoleMaster.ps1 file is 100% safe! The entire zip package (with the script and the README) has been tested at [Virus Total](https://www.virustotal.com/#/file/138b82c1d250767ace9dd1e177ea7b8337e7a172ab490118a2f07ac101d125fc/detection). Any detections are false positives and should be ignored

# Installation Instructions
 1. Ensure you have **Powershell 5.1 (This version came with my PC, thus it was made for it. I'm unsure older versions will cope)**
 2. Open an instance of Powershell in **administrative** mode and **[Ngrok](https://ngrok.com)** (you visit [this video](https://www.youtube.com/watch?v=ar-9Ku0vBeo&feature=youtu.be) to see the full process of setting up Ngrok to work with your Minecraft server) installed on your machine
 3. Set PowerShell's Execution Policy to either `RemoteSigned` or `Unrestricted` by running `Set-ExecutionPolicy "PolicyNameHere"`
 4. Then run the command `Install-Script -Name ConsoleMaster` to save the script
 5. The script should be downloaded, now locate it within your installation dictionary and place it somewhere useful and that **does not** require administrative permissions
 6. Run the script and set up the basic information
 7. The script is completely set up and ready!

# More Information
 Visit the [Wiki page](https://github.com/NovaViper/Console-Master/wiki) if you'd like to download and see what the script has to offer!

# Screenshots

Main Menu
<img src="https://github.com/NovaViper/Console-Master/blob/master/.github/images/MainMenu.png">

Settings Menu
<img src="https://github.com/NovaViper/Console-Master/blob/master/.github/images/SettingsMenu.png">
