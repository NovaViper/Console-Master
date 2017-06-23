@echo off
set consolename=Console Master
set consoleVersion=1.0
set prefix=%consoleName% %consoleVersion%

:::::::: Description ::::::::
:: Based on Airbornz's Better Console program, just reimagined and made to fit the needs of ANY Minecraft Server, and even added Ngrok support!
:: This is an open source program, feel free to copy but you must leave proper credit!
:: Tested on Windows 10

::First thing to start up, checks for any files created by Console Master
:boot
title %prefix%
if not exist cmJar.txt goto setup
if not exist cmMCVersion.txt goto setup
if exist cmColor.txt set /p color=<cmColor.txt
set /p jarfile=<cmJar.txt
set /p mcversion=<cmMCVersion.txt
goto core

::First time setup menu, the user enters the server basic information here
:setup
title %prefix%: Setup (Jar: N/A, MC N/A)
cls
echo Welcome To %consoleName%!!
echo.
echo Let me ask get to know your server better
echo.
set /p jarfile="Your Server's .jar File w/o the Extension: "
echo %jarfile%>>cmJar.txt
title %prefix%: Setup (Jar: %jarfile%, MC N/A)
set /p mcversion="Your Server's Minecraft Version: "
echo %mcversion%>>cmMCVersion.txt
title %prefix%: Setup (Jar: %jarfile%, MC %mcversion%)
echo java -Xms1G -Xmx1G -jar %jarfile%.jar -o true>>cmRam.txt
echo.
goto setupColorSelection

::The user is asked if they want to add in custom colors
:setupColorSelection
echo Would you like to use custom coloring?
set /p cmd="Y or N: "
if %cmd%==Y goto colorSetup
if %cmd%==y goto colorSetup
if %cmd%==N goto promptFinishCore
if %cmd%==n goto promptFinishCore
cls
echo Invaild Option (%cmd%)
pause
goto setupColorSelection

::Tells the user that they are done and that they will move on to the main menu after 5 seconds (or they can skip the wait by pressing any key)
:promptFinishCore
echo.
echo You're done with the basic setup!
echo.
echo Moving to main menu...
TIMEOUT 5
goto core

::The console's main menu
:core
title %prefix% : Main Menu (Jar: %jarfile%, MC %mcversion%)
cls
echo Welcome to %prefix%!!
echo.
echo Options:
echo.
echo 1. Start The Server
echo 2. Settings
echo 3. Exit
echo.
echo Enter The Number Of Your Choice.
echo.
set /p cmd="Command ID: "
if %cmd%==1 goto start
if %cmd%==2 goto set
if %cmd%==3 exit
cls
echo Invaild Option (%cmd%)
pause
goto core

::First phase of the server startup sequence, sepeated so Ngrok can be checked
:start
title %prefix% : Minecraft Server Running
cls
echo ------------------ START OF SERVER LOG ------------------
echo [%consolename%]: Server Starting!
goto checkForNGrok

::Second and final phase of the server startup sequence, begins to log the server output here
:start2
echo [%consolename%]: Loading Java Arguments To Use!
set /p arg=<cmRam.txt
echo [%consolename%]: Done Loading! Starting Server Now!
%arg%

::Server stop sequence, intial phase
:stop
title %prefix%: Minecraft Server Stopped
echo [%consolename%]: Server Stopped Check Above For Details!
echo ------------------ END OF SERVER LOG ------------------
goto promptExit

::Checks to see if Ngrok is opened or not
:checkForNGrok
echo [%consolename%]: Checking for Ngrok process...
tasklist /FI "imagename eq cmd.exe" /FI "WINDOWTITLE eq %prefix% - ngrok  tcp 25565" |find "cmd.exe" > nul
if %ERRORLEVEL% == 0 goto runningNgrokAlready
if %ERRORLEVEL% == 1 goto startNGrok
goto error

::Starts up Ngrok if checkForNGrok is 0 (meaning that the cmd is NOT open) then moves on to the final server startup sequence
:startNGrok
echo [%consolename%]: Ngrok not active! Starting Ngrok...
start "%prefix%" cmd /k "ngrok tcp 25565"
echo [%consolename%]: Ngrok Started!
goto start2

::Skips startup for Ngrok if checkForNGrok is 1 (meaning that the cmd IS open) then moves on to the final server startup sequence
:runningNgrokAlready
echo [%consolename%]: Ngrok is Already Running! Skipping Ngrok Startup..
goto start2

::Asks if the user wants to restart the server after the server stops
:promptExit
echo [%consolename%]: Would you like to restart the server?
set /p cmd="Y or N: "
if %cmd%==Y goto start
if %cmd%==y goto start
if %cmd%==N goto endServer
if %cmd%==n goto endServer
cls
echo Invaild Option (%cmd%)
pause
goto promptExit

::If the user said 'n' for promptExit, begin to exit out of the server sequence, asking rather to close the console or keep it open
:endServer
title %prefix%: Confirm Exit
cls
echo Ok, would you like to exit out of %consoleName%?
set /p cmd="Y or N: "
if %cmd%==Y goto endConsolePrompt
if %cmd%==y goto endConsolePrompt
if %cmd%==N goto endNgrokPrompt
if %cmd%==n goto endNgrokPrompt
cls
echo Invaild Option (%cmd%)
pause
goto endServer

::If the user said 'y' for endServer, asks to close Ngrok along with the console or keep Ngrok open and just close the console
:endConsolePrompt
echo Ok, would you like to exit Ngrok aswell?
set /p cmd="Y or N: "
if %cmd%==Y goto killNgrok
if %cmd%==y goto killNgrok
if %cmd%==N goto killConsole
if %cmd%==n goto killConsole
cls
echo Invaild Option (%cmd%)
pause
goto endConsolePrompt

::If the user said 'n' for endServer, asks to ONLY close Ngrok or keep it open
:endNgrokPrompt
echo Ok, would you like to exit Ngrok?
set /p cmd="Y or N: "
if %cmd%==Y goto killNgrok2
if %cmd%==y goto killNgrok2
if %cmd%==N goto returnToCore
if %cmd%==n goto returnToCore
cls
echo Invaild Option (%cmd%)
pause
goto endNgrokPrompt

::Kills Ngrok THEN prompts to close the console
:killNgrok
echo Exiting Ngrok...
@echo off
taskkill /IM cmd.exe /FI "WINDOWTITLE eq %prefix% - ngrok  tcp 25565"
echo Ngrok closed!
goto killConsole

::Kills Ngrok but keeps the console open, making the console return to the main menu
:killNgrok2
echo Exiting Ngrok...
@echo off
@echo off
taskkill /IM cmd.exe /FI "WINDOWTITLE eq %prefix% - ngrok  tcp 25565"
echo Ngrok closed!
goto exitThenReturnToCoreNgrok

::Tells user to press any button to close the console
:killConsole
echo Ok, Press Any Key To Exit!
pause > nul
exit

::Returns the user back to the main menu after server sequence is ended
:returnToCore
echo.
echo Ok, returning back to main menu...
TIMEOUT 5
goto core

::Returns the user back to the main menu after ONLY Ngrok is closed
:exitThenReturnToCoreNgrok
echo.
echo Returning back to main menu...
TIMEOUT 5
goto core

::The settings menu for the console
:set
title %prefix% : Settings
cls
echo Welcome to the Settings Menu!
echo.
echo Settings:
echo.
echo 1. Coloring - Set The Color Scheme
echo 2. Change Minecraft Version - Change What Version of Minecraft the Server is Using
echo 3. RAM Allocation - Set RAM Allocation (Advanced)
echo 4. Custom Arguments - Set custom arguments besides the RAM! (Advanced)
echo 5. Factory Reset [!!]
echo 6. Back To Main Menu
echo.
set /p cmd="Command: "
if %cmd%==1 goto colorSettings
if %cmd%==2 goto newMCVersion
if %cmd%==3 goto ram
if %cmd%==4 goto args
if %cmd%==5 goto reset
if %cmd%==6 goto core
cls
echo Invaild Option (%cmd%)
pause
goto set

::Color selection menu for first-time setup 
:colorSetup
cls
echo Enter the color code of your choice.
echo The color codes go as the following format: 0C - where 0 is the background color and A is the text color
echo.
echo The avilable color codes are the following:
echo 0 = Black       8 = Gray
echo 1 = Blue        9 = Light Blue
echo 2 = Green       A = Light Green
echo 3 = Aqua        B = Light Aqua
echo 4 = Red         C = Light Red
echo 5 = Purple      D = Light Purple
echo 6 = Yellow      E = Light Yellow
echo 7 = White       F = Bright White
echo.
echo Please Note: If you some how screw up delete your cmColor.txt file located in the server folder.
echo.
set /p cmd="Color Code: "
del "cmColor.txt"
echo %cmd%>>cmColor.txt
goto concolorSetup

::Saves the color scheme and then goes to main menu (for first time setup)
:concolorSetup
set /p color=<cmColor.txt
cls
echo Color Scheme Set!
echo.
echo Moving to main menu...
TIMEOUT 5
color %color%
goto core

::Color selection menu (Settings Menu Version)
:colorSettings
cls
echo Enter the color code of your choice.
echo The color codes go as the following format: 0C - where 0 is the background color and A is the text color
echo.
echo The avilable color codes are the following:
echo 0 = Black       8 = Gray
echo 1 = Blue        9 = Light Blue
echo 2 = Green       A = Light Green
echo 3 = Aqua        B = Light Aqua
echo 4 = Red         C = Light Red
echo 5 = Purple      D = Light Purple
echo 6 = Yellow      E = Light Yellow
echo 7 = White       F = Bright White
echo.
echo Please Note: If you some how screw up delete your cmColor.txt file located in the server folder.
echo.
set /p cmd="Color Code: "
del "cmColor.txt"
echo %cmd%>>cmColor.txt
goto concolorSettings

::Saves the color scheme and then returns to the settings menu
:concolorSettings
set /p color=<cmColor.txt
cls
echo Color Scheme Set!
goto exitThenReturnToSettingsColor

::Prompts for user to enter new Minecraft Version
:newMCVersion
cls
echo Please enter the new Minecraft Version your server will use
set /p mcversion="Version: "
del "cmMCVersion.txt"
echo %mcversion%>>cmMCVersion.txt
echo.
echo New Minecraft Version Set!
goto exitThenReturnToSettings

::Prompts user to change the amount of RAM allocation
:ram
cls
echo Please Enter Your Minimum Amount Of RAM To Use Followed By 'M' For Megabytes Or  'G' For Gigabytes:
set /p min="Minimum Amount: "
echo.
echo Please Enter Your Maximum Amount Of RAM To Use Followed By 'M' For Megabytes Or  'G' For Gigabytes:
set /p max="Maximum Amount: "
del "cmRam.txt"
echo java -Xms%min% -Xmx%max% -jar %jarfile%.jar -o true>>cmRam.txt
cls
echo RAM Amounts Set!
goto exitThenReturnToSettings

::Asks user to confirm if they want to change the java arguments and shows them their current ones
:args
cls
echo.
echo This where you can change your java args without opening the file.
echo.
echo [!] This Is For Advanced Users Only! If You Do Not Know How To Use Arguments Do Not Use This!
echo.
set /p args=<cmRam.txt
echo These are your current args:
echo %args%
echo.
echo Would you like to change it?
set /p cmd="Y or N: "
if %cmd%==Y goto cargs
if %cmd%==y goto cargs
if %cmd%==N goto exitThenReturnToSettings
if %cmd%==n goto exitThenReturnToSettings
echo.
echo Invaild Choice! (%cmd%)
pause
goto args

::Prompts user to change java arguments and shows them their original ones
:cargs
cls
echo Ok Please Enter Your New Arguments.
echo For Reference Here Is Your Arguments:
echo.
echo %args%
echo.
echo [!] Make sure to launch the server's jar file in your arguments!!
echo.
set /p nargs="New Arguments: "
cls
echo.
echo Are you sure you want to save these as your new arguments?
echo %args%
echo.
set /p cmd="Y or N: "
if %cmd%==Y then goto sargs
if %cmd%==y then goto sargs
if %cmd%==N then goto cargs
if %cmd%==n then goto cargs
cls
echo.
echo Invaild Choice!
pause
goto cargs

::Saves the new java arguments
:sargs
cls
echo Saving Arguments…
del "cmRam.txt"
echo %nargs%>>cmRam.txt
echo Done!
echo Changing Cached Arguments...
%args% = %nargs%
echo Done!
echo Complete!
echo.
echo Your New Arguments Are Saved And Ready For Use!
goto exitThenReturnToSettings

::Confirm factory reset
:reset
cls
echo Are you SURE you want to reset back to factory default? This process CANNOT be reversed!!
set /p cmd="Y or N: "
if %cmd%==Y then goto confirmReset
if %cmd%==y then goto confirmReset
if %cmd%==N then goto exitThenReturnToSettings
if %cmd%==n then goto exitThenReturnToSettings

::Deletes the settings then returns to first-time setup
:confirmReset
cls
echo Deleting all settings...
if exist cmJar.txt del "cmJar.txt"
if exist cmMCVersion.txt del "cmMCVersion.txt"
if exist cmRam.txt del "cmRam.txt"
if exist cmColor.txt del "cmColor.txt"
echo Factory Reset Completed!
cls.
echo Returning to first-time setup...
TIMEOUT 5
color 07
goto boot

::Applies color then returns to settings menu
:exitThenReturnToSettingsColor
cls
echo Returning back to settings menu...
TIMEOUT 5
color %color%
goto set

::Returns to settings menu WITHOUT applying color
:exitThenReturnToSettings
echo.
echo Returning back to settings menu...
TIMEOUT 5
goto set

::Tells user of error if one occurs
:error
cls
echo An error has occured!!
echo %ERRORLEVEL%
echo %ERROR%
echo Please contact the developer!
pause
