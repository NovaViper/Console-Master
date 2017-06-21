#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# VARIABLE DECLARATION #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
#Get 
$currentLocation = Split-Path -parent $PSCommandPath
$ui = (Get-Host).UI.RawUI
$consoleName = "Console Master"
$consoleVersion = '1.0'
$prefix = "$consoleName $consoleVersion"
$quitConsole = $false
$configFileName = "config.json"
$sleepTime = 4
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# POWERSHELL CUSTOMIZATION #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
$ui.WindowTitle = "$prefix"
Set-Location $currentLocation
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-# FUNCTION DECLARATION #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

function Setup-Console(){
    Clear-Host
    $ui.WindowTitle = "$prefix+: Server Running (Jar: , MC )"
    Write-Host "Welcome To $consoleName!!"
    Write-Host ''
    
    $jarFile = Check-Jar "Please enter the name of the server's .jar file (w/o the extension)"
    $mcVersion = Check-Version "Please enter the Minecraft version your server is using"
    $ramDataType = Check-RAM-Type
    $maxRAM = Check-Integer "Please enter your maximum amount of RAM (Random Access Memory) to use"

    $fullRAM = -Join ($maxRAM, $ramDataType)
    $basicInfo = @{
        Jar_File = "$jarFile"
        Minecraft_Version = "$mcVersion"
        Java_Flags = "-Xmx$fullRAM"
        Server_Options = "-o true"
    
    }

    New-Item $configFileName -ItemType "file" | Out-Null
    $basicInfo | ConvertTo-Json | Set-Content $configFileName

    Write-Host ""
    Write-Host "Moving to Main Menu..." -BackgroundColor Red
    Sleep -Seconds $sleepTime
    Main-Menu
}


function Main-Menu() {
    Load-Variables
    Clear-Host
    Write-Host @"
---------------------------------- Main Menu ----------------------------------

                    1. Start Server and Ngrok
                    2. Configurations Menu
                        
                    3. Exit the Console

-------------------------------------------------------------------------------
"@

    $answer = Read-Host "Please Make a Selection"
    switch($answer){
        '1' {
            Clear-Host
            Start-Server
        }
        '2' {
            Clear-Host
            Settings-Menu
        }
        '3' {
            Exit-Script
        }
        default {
            Invaild-Choice "INVALID CHOICE! PLEASE ENTER ONE OF THE CHOICES LISTED!"
            Main-Menu
        }
    }
}

function Start-Server(){
    $consoleServerPrefix = "["+$consoleName+"]:"
    $ui.WindowTitle = "$prefix+: Server Running (Jar: "+$Script:INFO.Jar_File+", MC "+$Script:INFO.Minecraft_Version+")"
    Write-Host @"
------------------------------- SERVER LOG START -------------------------------
$consoleServerPrefix Server Starting!
"@
    #-#-#-#-# Ngrok Checking here #-#-#-#-#
    #Write-Host "$consoleServerPrefix Checking for Ngrok process..."
 
    ##Already Started
    #Write-Host "$consoleServerPrefix Ngrok is Already Running! Skipping Ngrok Startup..."
 
    #Not Started
    #Write-Host "$consoleServerPrefix Ngrok Not Running! Starting Ngrok..."
    #start powershell {ngrok tcp 25565}
    #Write-Host "$consoleServerPrefix Ngrok Started!"
    #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
 
    Write-Host "$consoleServerPrefix Loading Java Arguments..."
    #start-process java -ArgumentList '-Xms1G -Xmx1G -jar C:\Users\novag\Documents\Powershell\forge.jar' -Wait -NoNewWindow

    java $INFO.Java_Flags -jar $INFO.Jar_File $INFO.Server_Options


}


function Settings-Menu() {
    Clear-Host
    Write-Host @"
-------------------------------- Settings Menu --------------------------------

    1. Change Version - Change the saved Minecraft version to match
                        what the jar file uses
    2. RAM Allocation - Set the amount of RAM (Random Access Memory) 
                        to reserve to the server [!]
    3. Custom Arguments - Set custom arguments besides the RAM [!!]
    4. Factory Reset - Erase all user defined settings and boot to 
                        first-time setup [!!!]

    5. Return To Main Menu

-------------------------------------------------------------------------------
"@

    $answer = Read-Host "Please Make a Selection"
    switch($answer){
        '1' {
            Clear-Host
            Change-Minecraft-Version
        }
        '2' {
            Clear-Host
            Change-RAM
        }
        '3' {
            Clear-Host
            Confirm-Change-Args
        }
        '4' {
            Clear-Host
            Confirm-Factory-Reset
        }
        '5' {Return-Main-Menu}
        default {
            Invaild-Choice "INVALID CHOICE! PLEASE ENTER ONE OF THE CHOICES LISTED!"
            Settings-Menu
        }
    }
}

function Change-Minecraft-Version(){
    $newVersion = Check-Version "Please enter the new Minecraft version your server is using"
    Save-Variable "Minecraft_Version" $newVersion
    Return-Settings-Menu
}

function Change-RAM(){
    $newRamDataType = Check-RAM-Type
    $newMaxRAM = Check-Integer "Please enter your maximum amount of RAM (Random Access Memory) to use"
    $newFullRAM = -Join ($newMaxRAM, $newRamDataType)
    Save-Variable "Java_Flags" "-Xmx$newFullRAM"
    Return-Settings-Menu
}

function Confirm-Change-Args(){
    Write-Host "Here are your original arguments:" $Script:INFO.Server_Options
    Write-Host "Are you SURE you want to modify these arguments?" -ForegroundColor Red
    $answer = Read-Host "(Y)es or (N)o"
    switch($answer.ToUpper()){

        'Y' {
            Clear-Host
            Perform-Change-Args
        }
        'N' {
            Clear-Host
            Return-Settings-Menu
        }
        default {
            Invaild-Choice "INVALID CHOICE! PLEASE ENTER ONE OF THE CHOICES LISTED!"
            Confirm-Factory-Reset
        }
    }
}

function Perform-Change-Args(){
    Write-Host "As a refresher, here are your original arguments:" $Script:INFO.Server_Options
    $data = ''
    While(($null -eq $data) -or ($data -eq '')){
        [string]$data = Read-Host -Prompt "Please enter new arguments for your server"
		
        if (($null -eq $data) -or ($data -eq '')){
			Write-Output ''
            $data = ''
			Invaild-Choice "You cannot enter a null/empty name!"
		}else{
            Save-Variable "Server_Options" $data
            Return-Settings-Menu
		}		
    }
}

function Confirm-Factory-Reset(){
    Write-Host "Are you sure you want to reset back to factory default? This process CANNOT be reversed!!" -ForegroundColor Red
    $answer = Read-Host "(Y)es or (N)o"
    switch($answer.ToUpper()){

        'Y' {
            Clear-Host
            Perform-Factory-Reset
        }
        'N' {
            Clear-Host
            Return-Settings-Menu
        }
        default {
            Invaild-Choice "INVALID CHOICE! PLEASE ENTER ONE OF THE CHOICES LISTED!"
            Confirm-Factory-Reset
        }
    }
}

function Perform-Factory-Reset(){
    Write-Host "Deleting Preferences..." -BackgroundColor Red
    Remove-Item $configFileName
    Clear-Variable -name INFO
    Write-Host "Factory Reset Completed!"
    Write-Host ""
    Write-Host "Returning to First-Time Setup..." -BackgroundColor Red
    Sleep -Seconds $sleepTime
    Setup-Console
}


function Exit-Script(){
    Write-Host ""
    Write-Host 'Exiting Script...' -BackgroundColor Red
    Start-Sleep -Seconds $sleepTime
    $quitConsole = $true
}

function Return-Main-Menu(){
    Write-Host ""
    Write-Host 'Returning to Main Menu...' -BackgroundColor Red
    Sleep -Seconds $sleepTime
    Main-Menu
}

function Return-Settings-Menu(){
    Write-Host ""
    Write-Host "Returning to Settings Menu..." -BackgroundColor Red
    Sleep -Seconds $sleepTime
    Settings-Menu
}

function Invaild-Choice([string]$message){
    [Console]::Beep(1000, 100)
    Write-Host $message -ForegroundColor Red
    Sleep -Seconds $sleepTime
}

function Load-Variables(){
    $Script:INFO = Get-Content -Path $configFileName -Raw | ConvertFrom-Json
}

function Save-Variable($keyName, $data){
    $Script:INFO.$keyName = $data
    $Script:INFO | ConvertTo-Json | Set-Content $configFileName
}

function Check-Jar([string]$promptMessage){
    $data = ''
    While(($null -eq $data) -or ($data -eq '')){
        [string]$data = Read-Host -Prompt $promptMessage
		
        if (($null -eq $data) -or ($data -eq '')){
			Write-Output ''
            $data = ''
			Invaild-Choice "You cannot enter a null/empty name!"
		}else{
            return $data+'.jar'
		}		
    }
}

function Check-Version([string]$promptMessage){
	$data = ''
	While ($data -eq '')
	{
		$data = Read-Host -Prompt $promptMessage
		$minVer = [version]'1.0.0'
		$maxVer = [version]'999.999.999'

		# not matching NOT 0-9 & '.' [ie - only 0-9 & '.']
		#    must contain at least one '.'
		#    must START with a digit
		#    must END with a digit
		if (($data -notmatch '[^0-9.]') -and ($data -match '\.') -and ($data[0] -match '[0-9]') -and ($data[-1] -match '[0-9]') -and ($data -ge $minVer) -and ($data -le $maxVer)){
			return $data
		}else{
            $data = ''
			Invaild-Choice "The value [$data] MUST be a version (major, minor, build) ranging between $minVer to $maxVer!"
		}
	}
}

function Check-Integer([string]$promptMessage){
    $data = ''
    $min = 1
    $max = [int]::MaxValue
    While(($null -eq $data) -or ($data -eq '') -or ($data -eq '0') -or (-not ($data -notmatch '[^\d]'))){
       
        [int]$data = Read-Host -Prompt $promptMessage
        if(($null -eq $data) -or ($data -eq '') -or ($data -eq '0')){
			Write-Host ''
            $data = ''
			Invaild-Choice "The value [$data] cannot be null, empty or 0!"
		}elseif(-not ($data -notmatch '[^\d]')){
			Write-Output ''
            $data = ''
			Invaild-Choice "The value [$data] MUST be an integer!"
		}else{
		    return $data
        }
    
    }
}

function Check-RAM-Type(){
    $ramType = ''
	$ValidChoices = ('M', 'G')
	While ($ramType -notin $ValidChoices){
		$ramType = (Read-Host -Prompt 'Would you like to use [M]egabytes or [G]igabytes?').ToUpper()
		
        if ($ramType -notin $ValidChoices){
            $ramType = ''
			Invaild-Choice "INVALID CHOICE! PLEASE ENTER ONE OF THE CHOICES LISTED!"
		}else{
            return $ramType
	    }
    }
}

#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#   BEGIN FUNCTION CALLS   #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

Do{

    Clear-Host
    #-#-#-#-# Setup Checking here #-#-#-#-#
    If (!(Test-Path $configFileName)) {
        Setup-Console
    }else{
        #Load data from JSON
        Main-Menu
    }

    
    #If there are no basic files

    #If there are basic files
    #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
} Until ($quitConsole = $true)