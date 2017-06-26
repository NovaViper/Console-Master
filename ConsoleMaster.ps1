﻿#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# VARIABLE DECLARATION #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
$currentLocation = Split-Path -parent $PSCommandPath
$ui = (Get-Host).UI.RawUI
$consoleName = "Console Master"
$consoleVersion = '1.5.0'
$prefix = "$consoleName $consoleVersion"
$QuitConsole = $false
$configFileName = "config.json"
$SleepTime = 3
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# POWERSHELL CUSTOMIZATION #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
$ui.WindowTitle = "$prefix"
Set-Location $currentLocation
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# FUNCTION DECLARATION #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

function Set-Up-Console() {
    Clear-Host
    $ui.WindowTitle = $prefix+": Server Running (Jar: , MC )"
    Write-Host "Welcome To $prefix!!"
    Write-Host ''

    $jarFile = Test-Jar "Please enter the name of the server's .jar file (w/o the extension)"
    $mcVersion = Test-Version "Please enter the Minecraft version your server is using"
    $ramDataType = Test-RAM-Type
    $maxRAM = Test-Integer "Please enter your maximum amount of RAM (Random Access Memory) to use"

    $fullRAM = -Join ($maxRAM, $ramDataType)
    $basicInfo = @{
        Jar_File          = "$jarFile"
        Minecraft_Version = "$mcVersion"
        Java_Flags        = "-Xmx$fullRAM"
        Server_Options    = "-o true"

    }

    New-Item $configFileName -ItemType "file" | Out-Null
    $basicInfo | ConvertTo-Json | Set-Content $configFileName

    Write-Host ""
    Write-Host "Moving to Main Menu..." -BackgroundColor Red
    Start-Sleep -Seconds $SleepTime
    Invoke-Main-Menu
}


function Invoke-Main-Menu() {
    Update-Variables
    Clear-Host
    Write-Host @"
---------------------------------- Main Menu ----------------------------------

                    1. Start Server and Ngrok
                    2. Configurations Menu

                    3. Exit the Console

-------------------------------------------------------------------------------
"@

    $answer = Read-Host "Please Make a Selection"
    switch ($answer) {
        '1' {
            Clear-Host
            Start-Server
        }
        '2' {
            Clear-Host
            Invoke-Settings-Menu
        }
        '3' {
            Exit-Script
        }
        default {
            Invaild-Choice "INVALID CHOICE! PLEASE ENTER ONE OF THE CHOICES LISTED!"
            Invoke-Main-Menu
        }
    }
}

function Start-Server() {
    $consoleServerPrefix = "[" + $consoleName + "]:"
    $ui.WindowTitle = $prefix+": Server Running (Jar: " + $Script:INFO.Jar_File + ", MC " + $Script:INFO.Minecraft_Version + ")"
    Write-Host @"
------------------------------- SERVER LOG START -------------------------------
$consoleServerPrefix Starting Server...
"@
    Write-Host "$consoleServerPrefix Checking for Ngrok process..."
    if (-not(Get-Process -Name ngrok -ErrorAction SilentlyContinue)) {
        Write-Host "$consoleServerPrefix Ngrok Not Running! Starting Ngrok..."
        Start-Process ngrok -argumentlist "tcp 25565" -passthru | Out-Null
        Write-Host "$consoleServerPrefix Ngrok Started!"
    }
    else {
        Write-Host "$consoleServerPrefix Ngrok is Already Running! Skipping Ngrok Startup..."
    }
    Write-Host "$consoleServerPrefix Starting .jar File Now.."
    java $INFO.Java_Flags -jar $INFO.Jar_File $INFO.Server_Options

    $ui.WindowTitle = "$consoleServerPrefixServer Stopped (Jar: " + $Script:INFO.Jar_File + ", MC " + $Script:INFO.Minecraft_Version + ")"
    Write-Host "$consoleServerPrefixServer Server Stopped! Check Above For Details!"
    Invoke-Ask-Restart
}

function Invoke-Ask-Restart(){
    $answer = Read-Host -Prompt "Would you like to restart the server? (Y)es/(N)o"
    switch ($answer.ToUpper()) {
        'Y' {
            Write-Host $prefix+:"Restarting Server..." -BackgroundColor Red
            Start-Sleep $SleepTime
            Clear-Host
            Start-Server
        }
        'N' {
            Clear-Host
            Confirm-Console-Close
        }
        default {
            Invaild-Choice "INVALID CHOICE! PLEASE ENTER ONE OF THE CHOICES LISTED!"
            Invoke-Ask-Restart
        }
    }
}

function Confirm-Console-Close () {
    $ui.WindowTitle = $prefix + ': Confirm Exit'
    $answer = Read-Host "Ok, would you to close"$consoleName"? (Y)es/(N)o"
    switch ($answer.ToUpper()) {

        'Y' {
            Write-Host ""
            Confirm-Ngrok-Close $true
        }
        'N' {
            Write-Host ""
            Confirm-Ngrok-Close $false
        }
        default {
            Invaild-Choice "INVALID CHOICE! PLEASE ENTER ONE OF THE CHOICES LISTED!"
            Confirm-Console-Close
        }
    }
}


function Confirm-Ngrok-Close([bool]$closeConsole) {
    $answer = Read-Host 'Ok, would you to close Ngrok? (Y)es/(N)o'
    switch ($answer.ToUpper()) {

        'Y' {
            Write-Host ""
            Exit-Console-Ngrok $closeConsole $true
        }
        'N' {
            Write-Host ""
            Exit-Console-Ngrok $closeConsole $false
        }
        default {
            Invaild-Choice "INVALID CHOICE! PLEASE ENTER ONE OF THE CHOICES LISTED!"
            Confirm-Ngrok-Close
        }
    }
}

function Exit-Console-Ngrok([bool]$closeConsole, [bool]$closeNgrok) {

    if (($closeConsole -eq $true) -and ($closeNgrok -eq $true)) {
        Stop-Process -Name ngrok
        Exit-Script
    }
    elseif (($closeConsole -eq $false) -and ($closeNgrok -eq $true)) {
        Stop-Process -Name ngrok
        Resume-Main-Menu
    }
    elseif (($closeConsole -eq $true) -and ($closeNgrok -eq $false)) {
        Exit-Script
    }
    else {
        Resume-Main-Menu
    }
}

function Invoke-Settings-Menu() {
    Clear-Host
    Write-Host @"
-------------------------------- Settings Menu --------------------------------

    1. Change Jar - Change the saved jar file name that the script
                    executes
    2. Change Version - Change the saved Minecraft version to match
                        what the jar file uses
    3. RAM Allocation - Set the amount of RAM (Random Access Memory)
                        to reserve to the server [!]
    4. Custom Arguments - Set custom arguments besides the RAM [!!]
    5. Factory Reset - Erase all user defined settings and boot to
                       first-time setup [!!!]

    6. Return To Main Menu

-------------------------------------------------------------------------------
"@

    $answer = Read-Host "Please Make a Selection"
    switch ($answer) {
        '1' {
            Clear-Host
            Edit-Jar-File
        }
        '2' {
            Clear-Host
            Edit-Minecraft-Version
        }
        '3' {
            Clear-Host
            Edit-RAM
        }
        '4' {
            Clear-Host
            Confirm-Change-Args
        }
        '5' {
            Clear-Host
            Confirm-Factory-Reset
        }
        '6' {Resume-Main-Menu}
        default {
            Invaild-Choice "INVALID CHOICE! PLEASE ENTER ONE OF THE CHOICES LISTED!"
            Invoke-Settings-Menu
        }
    }
}

function Edit-Jar-File() {
    $newJar = Test-Jar "Please enter the new name of the server's .jar file (w/o the extension)"
    Save-Variable "Jar_File" $newJar
    Resume-Settings-Menu
}

function Edit-Minecraft-Version() {
    $newVersion = Test-Version "Please enter the new Minecraft version your server is using"
    Save-Variable "Minecraft_Version" $newVersion
    Resume-Settings-Menu
}

function Edit-RAM() {
    $newRamDataType = Test-RAM-Type
    $newMaxRAM = Test-Integer "Please enter your maximum amount of RAM (Random Access Memory) to use"
    $newFullRAM = -Join ($newMaxRAM, $newRamDataType)
    Save-Variable "Java_Flags" "-Xmx$newFullRAM"
    Resume-Settings-Menu
}

function Confirm-Change-Args() {
    Write-Host "Here are your original arguments:" $Script:INFO.Server_Options
    $answer = Read-Host "Are you SURE you want to modify these arguments? (Y)es/(N)o" -ForegroundColor Red
    switch ($answer.ToUpper()) {

        'Y' {
            Clear-Host
            Edit-Args
        }
        'N' {
            Clear-Host
            Resume-Settings-Menu
        }
        default {
            Invaild-Choice "INVALID CHOICE! PLEASE ENTER ONE OF THE CHOICES LISTED!"
            Confirm-Factory-Reset
        }
    }
}

function Edit-Args() {
    Write-Host "As a refresher, here are your original arguments:" $Script:INFO.Server_Options
    $data = ''
    While (($null -eq $data) -or ($data -eq '')) {
        [string]$data = Read-Host -Prompt "Please enter new arguments for your server"

        if (($null -eq $data) -or ($data -eq '')) {
            Write-Output ''
            $data = ''
            Invaild-Choice "You cannot enter a null/empty name!"
        }
        else {
            Save-Variable "Server_Options" $data
            Resume-Settings-Menu
        }
    }
}

function Confirm-Factory-Reset() {
    Write-Host "Are you sure you want to reset back to factory default? This process CANNOT be reversed!!" -ForegroundColor Red
    $answer = Read-Host "(Y)es or (N)o"
    switch ($answer.ToUpper()) {

        'Y' {
            Clear-Host
            Initialize-Factory-Reset
        }
        'N' {
            Clear-Host
            Resume-Settings-Menu
        }
        default {
            Invaild-Choice "INVALID CHOICE! PLEASE ENTER ONE OF THE CHOICES LISTED!"
            Confirm-Factory-Reset
        }
    }
}

function Initialize-Factory-Reset() {
    Write-Host "Deleting Preferences..." -BackgroundColor Red
    Remove-Item $configFileName
    Clear-Variable -name INFO
    Write-Host "Factory Reset Completed!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Returning to First-Time Setup..." -BackgroundColor Red
    Start-Sleep -Seconds $SleepTime
    Set-Up-Console
}


function Exit-Script() {
    Write-Host ""
    Write-Host 'Exiting Script...' -BackgroundColor Red
    Start-Sleep -Seconds $SleepTime
    $QuitConsole = $true
}

function Resume-Main-Menu() {
    Write-Host ""
    Write-Host 'Returning to Main Menu...' -BackgroundColor Red
    Start-Sleep -Seconds $SleepTime
    Invoke-Main-Menu
}

function Resume-Settings-Menu() {
    Write-Host ""
    Write-Host "Returning to Settings Menu..." -BackgroundColor Red
    Start-Sleep -Seconds $SleepTime
    Invoke-Settings-Menu
}

function Invaild-Choice([string]$message) {
    [Console]::Beep(1000, 100)
    Write-Host $message -ForegroundColor Red
    Start-Sleep -Seconds $SleepTime
}

function Update-Variables() {
    $Script:INFO = Get-Content -Path $configFileName -Raw | ConvertFrom-Json
}

function Save-Variable($keyName, $data) {
    $Script:INFO.$keyName = $data
    $Script:INFO | ConvertTo-Json | Set-Content $configFileName
}

function Test-Jar([string]$promptMessage) {
    $data = ''
    While (($null -eq $data) -or ($data -eq '')) {
        [string]$data = Read-Host -Prompt $promptMessage

        if (($null -eq $data) -or ($data -eq '')) {
            Write-Output ''
            $data = ''
            Invaild-Choice "You cannot enter a null/empty name!"
        }
        else {
            return $data + '.jar'
        }
    }
}

function Test-Version([string]$promptMessage) {
    $data = ''
    While ($data -eq '') {
        $data = Read-Host -Prompt $promptMessage
        $minVer = [version]'1.0.0'
        $maxVer = [version]'999.999.999'

        # not matching NOT 0-9 & '.' [ie - only 0-9 & '.']
        #    must contain at least one '.'
        #    must START with a digit
        #    must END with a digit
        if (($data -notmatch '[^0-9.]') -and ($data -match '\.') -and ($data[0] -match '[0-9]') -and ($data[-1] -match '[0-9]') -and ($data -ge $minVer) -and ($data -le $maxVer)) {
            return $data
        }
        else {
            $data = ''
            Invaild-Choice "The value [$data] MUST be a version (major, minor, build) ranging between $minVer to $maxVer!"
        }
    }
}

function Test-Integer([string]$promptMessage) {
    $data = ''
    While (($null -eq $data) -or ($data -eq '') -or ($data -eq '0') -or (-not ($data -notmatch '[^\d]'))) {

        [int]$data = Read-Host -Prompt $promptMessage
        if (($null -eq $data) -or ($data -eq '') -or ($data -eq '0')) {
            Write-Host ''
            $data = ''
            Invaild-Choice "The value [$data] cannot be null, empty or 0!"
        }
        elseif (-not ($data -notmatch '[^\d]')) {
            Write-Output ''
            $data = ''
            Invaild-Choice "The value [$data] MUST be an integer!"
        }
        else {
            return $data
        }

    }
}

function Test-RAM-Type() {
    $ramType = ''
    $ValidChoices = ('M', 'G')
    While ($ramType -notin $ValidChoices) {
        $ramType = (Read-Host -Prompt 'Would you like to use [M]egabytes or [G]igabytes?').ToUpper()

        if ($ramType -notin $ValidChoices) {
            $ramType = ''
            Invaild-Choice "INVALID CHOICE! PLEASE ENTER ONE OF THE CHOICES LISTED!"
        }
        else {
            return $ramType
        }
    }
}

#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#   BEGIN FUNCTION CALLS   #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

Do {

    Clear-Host
    If (!(Test-Path $configFileName)) {
        Set-Up-Console
    }
    else {
        Invoke-Main-Menu
    }

} Until ($QuitConsole = $true)