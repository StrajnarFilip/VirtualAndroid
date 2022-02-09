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

# Download official CLI tools from google
Invoke-WebRequest -OutFile "cli_tools.zip" -Uri "https://dl.google.com/android/repository/commandlinetools-win-8092744_latest.zip"
# Extract .zip archive
Expand-Archive -Path ".\cli_tools.zip" -DestinationPath ".\android\cmdline-tools"
# Set environmental variable
$env:ANDROID_SDK_ROOT="$(Get-Location)\android"
Set-Location .\android
New-Item -Type "directory" -Path .\platforms
Set-Location .\cmdline-tools
Rename-Item -Path .\cmdline-tools -NewName "latest"
.\latest\bin\sdkmanager.bat --install "build-tools;32.0.0"
.\latest\bin\sdkmanager.bat --install "system-images;android-32;google_apis_playstore;x86_64"
.\latest\bin\avdmanager.bat create avd --name "Machine1" --device "28" --package "system-images;android-32;google_apis_playstore;x86_64"

# Shortcut creation
Set-Location ..\emulator
Set-Content -Path "Start.ps1" -Value "Set-Location $(Get-Location) ; .\emulator.exe -avd Machine1"

# Copy shortcut to Desktop
Copy-Item -Path "Start.ps1" -Destination "~\Desktop"

# Done