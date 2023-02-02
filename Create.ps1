<#
   Copyright 2022 Filip Strajnar
   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at
       http://www.apache.org/licenses/LICENSE-2.0
   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
#>

# Speed up download by silencing:
$ProgressPreference = 'SilentlyContinue'

# Go to home directory:
Set-Location ~

# Check if android container was already made
if (Test-Path -Path "android-container") {
    # Delete the old one for clean install
    Remove-Item -Recurse -Force .\android-container\
}

# Create directory that will contain everything
New-Item -ItemType "directory" -Name "android-container"

# Go inside the created directory
Set-Location .\android-container

# Set required environmental variables
$env:ANDROIDCONTAINER= $(Get-Location)
[System.Environment]::SetEnvironmentVariable("ANDROIDCONTAINER", $env:ANDROIDCONTAINER, [System.EnvironmentVariableTarget]::User)
$env:ANDROID_HOME = "$env:ANDROIDCONTAINER\.android"
$env:ANDROID_SDK_ROOT = "$env:ANDROIDCONTAINER\.android"
$env:ANDROID_SDK_HOME = "$env:ANDROIDCONTAINER"
$env:ANDROID_USER_HOME = "$env:ANDROIDCONTAINER\.android"
$env:ANDROID_EMULATOR_HOME = "$env:ANDROIDCONTAINER\.android"
$env:ANDROID_AVD_HOME = "$env:ANDROIDCONTAINER\avd\"

#[System.Environment]::SetEnvironmentVariable("ANDROID_HOME", $env:ANDROID_HOME, [System.EnvironmentVariableTarget]::User)
#[System.Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", $env:ANDROID_SDK_ROOT, [System.EnvironmentVariableTarget]::User)
#[System.Environment]::SetEnvironmentVariable("ANDROID_SDK_HOME", $env:ANDROID_SDK_HOME, [System.EnvironmentVariableTarget]::User)
#[System.Environment]::SetEnvironmentVariable("ANDROID_USER_HOME", $env:ANDROID_USER_HOME, [System.EnvironmentVariableTarget]::User)
#[System.Environment]::SetEnvironmentVariable("ANDROID_EMULATOR_HOME", $env:ANDROID_EMULATOR_HOME, [System.EnvironmentVariableTarget]::User)
#[System.Environment]::SetEnvironmentVariable("ANDROID_AVD_HOME", $env:ANDROID_AVD_HOME, [System.EnvironmentVariableTarget]::User)

# Download and extract CLI tools
$cli_tools = "cli_tools.zip"
Invoke-WebRequest -OutFile $cli_tools -Uri "https://dl.google.com/android/repository/commandlinetools-win-9477386_latest.zip"
Expand-Archive -Path $cli_tools -DestinationPath ".\.android\cmdline-tools"
Remove-Item $cli_tools

Set-Location .\.android

# Create required directories
New-Item -Type "directory" -Path .\platforms
New-Item -Type "directory" -Path .\platform-tools

# Add CLI tools to path
$BaseAndroidPath = $(Get-Location)
[System.Environment]::SetEnvironmentVariable(
    "Path",
    "${BaseAndroidPath}\platform-tools;${BaseAndroidPath}\emulator;${BaseAndroidPath}\cmdline-tools\latest\bin;$([System.Environment]::GetEnvironmentVariable("Path",[System.EnvironmentVariableTarget]::User))",
    [System.EnvironmentVariableTarget]::User)

# Fix the name to latest
Set-Location .\cmdline-tools
Rename-Item -Path .\cmdline-tools -NewName "latest"

# Install basic tools
'y', 'y', 'y', 'y' | .\latest\bin\sdkmanager.bat --install "platform-tools"
'y', 'y', 'y', 'y' | .\latest\bin\sdkmanager.bat --install "build-tools;32.0.0"
'y', 'y', 'y', 'y' | .\latest\bin\sdkmanager.bat --install "system-images;android-32;google_apis_playstore;x86_64"
.\latest\bin\avdmanager.bat create avd --name "Machine1" --device "28" --package "system-images;android-32;google_apis_playstore;x86_64"

# Shortcut creation
Set-Location ..\emulator
Set-Content -Path "Start.ps1" -Value '
$env:ANDROID_HOME = "$env:ANDROIDCONTAINER\.android"
$env:ANDROID_SDK_ROOT = "$env:ANDROIDCONTAINER\.android"
$env:ANDROID_SDK_HOME = "$env:ANDROIDCONTAINER"
$env:ANDROID_USER_HOME = "$env:ANDROIDCONTAINER\.android"
$env:ANDROID_EMULATOR_HOME = "$env:ANDROIDCONTAINER\.android"
$env:ANDROID_AVD_HOME = "$env:ANDROIDCONTAINER\avd\"
emulator.exe -avd Machine1'

# Copy shortcut to Desktop
Copy-Item -Path "Start.ps1" -Destination "~\Desktop"

# Done