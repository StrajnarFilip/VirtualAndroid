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
# Speed up download:
$ProgressPreference = 'SilentlyContinue'

# Download Java 8
$java_zip = "java8.zip"
$jdk_version_name = "jdk8u322-b06"
Invoke-WebRequest -OutFile $java_zip -Uri "https://github.com/adoptium/temurin8-binaries/releases/download/${jdk_version_name}/OpenJDK8U-jdk_x64_windows_hotspot_8u322b06.zip"

# Unzip / Extract
Expand-Archive -Path $java_zip -DestinationPath "java8"
$jdk_full_path = "$(Get-Location)\java8\${jdk_version_name}"

# Set java home
[Environment]::SetEnvironmentVariable("JAVA_HOME", "${jdk_full_path}", [System.EnvironmentVariableTarget]::User)
$env:JAVA_HOME = $jdk_full_path

# Set path to include java
$old_user_path = [Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)
[Environment]::SetEnvironmentVariable("Path", "${old_user_path};${jdk_full_path}\bin", [System.EnvironmentVariableTarget]::User)
$env:Path = [Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)

# Download official CLI tools from google
$cli_tools = "cli_tools.zip"
Invoke-WebRequest -OutFile $cli_tools -Uri "https://dl.google.com/android/repository/commandlinetools-win-8092744_latest.zip"
# Extract .zip archive
Expand-Archive -Path $cli_tools -DestinationPath ".\android\cmdline-tools"
# Set environmental variable
$env:ANDROID_SDK_ROOT = "$(Get-Location)\android"
Set-Location .\android
New-Item -Type "directory" -Path .\platforms
Set-Location .\cmdline-tools
Rename-Item -Path .\cmdline-tools -NewName "latest"
'y', 'y', 'y', 'y' | .\latest\bin\sdkmanager.bat --install "build-tools;32.0.0"
'y', 'y', 'y', 'y' | .\latest\bin\sdkmanager.bat --install "system-images;android-32;google_apis_playstore;x86_64"
.\latest\bin\avdmanager.bat create avd --name "Machine1" --device "28" --package "system-images;android-32;google_apis_playstore;x86_64"

# Shortcut creation
Set-Location ..\emulator
Set-Content -Path "Start.bat" -Value "powershell -Command `"& '$(Get-Location)\emulator.exe' -avd Machine1`""

# Copy shortcut to Desktop
Copy-Item -Path "Start.bat" -Destination "~\Desktop"

# Done