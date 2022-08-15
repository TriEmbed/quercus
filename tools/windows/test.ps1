#!/usr/bin/env pwsh
# TriEmbed ESP32/Dialog FPGA Project
#
# Tool chain installation script

# This is the Windows port of the linux installit.sh script
# Based on version="0.32"

# See https://github.com/TriEmbed/que_tools/issues for bugs/enhancements

# Authors and maintainers
# Add your email here and append your name to the copyright list with commas

# pete@soper.us
# rob.mackie@gmail.com
# nickedgington@gmail.com
# paulmacd@acm.org

# MIT License
#
# Copyright 2022 Dawn Annette Trembath, Peter James Soper, Robert Andrew Mackie, Nicholas John Edgington, Paul Duncan MacDougal
#
# Permission is hereby granted, free of charge, to any person 
# obtaining a copy of this software and associated 
# documentation files (the "Software"), to deal in the
# Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, 
# distribute, sublicense, and/or sell copies of the
# Software, and to permit persons to whom the Software is 
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall
# be included in all copies or substantial portions of the 
# Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY 
# KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE 
# WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
# PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
# OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Param (
    [Parameter(Position = 0)][ValidateNotNullOrEmpty()][string] $WIFISSID,
    [Parameter(Position = 1)][ValidateNotNullOrEmpty()][string] $WIFIpassword,
    # The default target ESP32 device
    [ValidateSet('ESP32', 'ESP32C3', 'ESP32S2')][string] $targetdevice = 'ESP32C3',
    # The directory pathname for the user's Quercus repositories
    [string]$targetdir = "$env:userprofile\AppData\Local\quercus",
    # The base part of the branch name shown by git branch -a
    [string]$targetbranch = 'origin/release/v4.4',
    # The default version of que_purple board.
    [ValidateSet('60', '70')][string]$c3board = '70',
    [string]$branch,
    [switch]$version,
    [switch]$help
)

# Bump this per push
$versionId = '0.1'

# capture the tools directory (Assumes that this script has not been moved since cloned)
#temp=`dirname $0`
#rootpath=`readlink -f $temp`

# The directory pathname for the Espressif IDF directory
# Note this cannot be currently changed from the command line. 
# Be careful about having multiple instances of esp-idf because the most
# recent invocation of install.sh governs which is used, NOT which one contained
# the export.sh file that was sourced. (Is this completely correct? It is for
# sure partially correct 'cuase install.sh mutates ~/.expressif but export.sh
# does not).
$idfdir = "$env:SystemDrive\Espressif"

# The git branch labels for the exact version of tools to install. If this 
# variable does not match the branch of an existing esp-idf the script must
# be aborted because there is the likelihood that the submodules are not right.
# The required order is 1) clone, 2) checkout branch, 3) load submodules
# The remotes/origin/release/v4.4 branch is the latest Espressif stable branch.
# the remotes/origin/release/v5.0 branch is the bleeding edge development 
# branch. 

# Git is weird with respect to git branch -a output vs actual branch names
# The correct branch name is $targetbranchprefix$targetbranch
$targetbranchprefix = 'remotes/'

# The nvm version
$nodeversion = '14.20.0'
$npmversion = '6.14.17'

# $MyInvocation.MyCommand.Path
# $MyInvocation.MyCommand.Name

function usage {
    #echo $1
    Write-Output 'usage: installit WIFISSID WIFIpassword [ -targetdevice <ESP32 | ESP32C3 | ESP32S2> ] [ -targetdir <path> ] [ -branch <branch id> ] [ -c3board <60 | 70> ] [ -version ] [ -help ]'
    Write-Output "default targetdir: $targetdir"
    Write-Output "default branch: $targetbranch"
    Write-Output "default device: $targetdevice"
    Exit 1
}

function myhelp {
    Write-Output 'ESP32, ESP32S3 and ESP32C3 supported'
    Write-Output 'I2C pins as follows:'
    Write-Output 'ESP32: SDA 18 SCL 19'
    Write-Output 'ESP32S2: SDA 1 SCL 0'
    Write-Output 'ESP32C3: SDA 18 SCL 19 (m80 60 rev) SDA 1 SCL 0 (m80 70 rev)'
    usage
}

# Put out a prompt, then ask for a Y, y, N or n response.
# Return true if Y or y, false if N or n. Cannot escape until an acceptable 
# answer is input. Use ctrl-C to break out.

function getyes {
    Param($prompt)
    while ($True) {
        $answer = Read-Host -Prompt $prompt
        if ($answer -eq 'y' -Or $answer -eq 'Y') {
            RETURN $True
        }
        if ($answer -eq 'n' -Or $answer -eq 'N') {
            RETURN $False
        }
        Write-Host 'Answer MUST be Y, y, N, or n'
    }
}

function Test-CommandExists {
    Param($command)
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = 'stop'
    try {
        if (Get-Command $command) {
            # may cause non-terminating error
            # command is installed
            # Write-Output "$command is installed"
            return $True
        }
    }
    Catch {
        # Write-Output "$command is not installed"
        return $False
    }
    Finally { $ErrorActionPreference = $oldPreference }
}

function makeDirectory {
    Param($dirname)

    if (!(Test-Path $dirname)) {
        # offer to create the directory
        if (getyes "Would you like me to create $dirname for you?") {
            $oldPreference = $ErrorActionPreference
            $ErrorActionPreference = 'stop'
            try {
                New-Item $dirname -ItemType Directory | Out-Null # suppress directory creation spew
            }
            Catch [System.UnauthorizedAccessException] {
                Write-Error -Category PermissionDenied -ErrorId 'E04' -Message "Permission to create $dirname is denied"
                Exit 4
            }
            Catch {
                # This is an interesting case that we would like to include in our testing.  At the moment, we do not have an example of hitting this.
                Write-Error -Category PermissionDenied -ErrorId 'E05' -Message "Failed to create $dirname `r`n${_.Exception.Message}`r`n"
                Exit 5
            }
            Finally { $ErrorActionPreference = $oldPreference }
        }
        else {
            # Do we want to write out any message here?
            Exit 5
        }
    }
    elseif (Test-Path $dirname -PathType Leaf) {
        # a file by that name exists.  What to do?
        Write-Error -Category ResourceExists -ErrorId 'E06' -Message `
            "This script would like to create a directory at $dirname `
    A file by that name is already present.  Either change `
    the -targetdir parameter or remove the existing file `
    and rerun this script"
        Exit 6
    }
}

function gitCloneRepo
{
    Param($repo)

    if ((Test-Path $repo -PathType Container) -And (Test-Path "$repo\.cloned" -PathType Leaf)) {
        Push-Location $repo
        Write-Output "git pull in $repo"
        git pull
        # check that this worked ...
        Write-Output "Git pull status: $lastexitcode"
    } else {
        if (Test-Path $repo) {
            # Need a try/Catch here
            try {
                Remove-Item -Recurse -Force $repo
            }
            catch [ItemNotFoundException] {
                Write-Output "Caught ItemNotFoundException"
            }
            catch {
                # This is an interesting case that we would like to include in our testing.  At the moment, we do not have an example of hitting this.
                Write-Error -Category PermissionDenied -ErrorId 'E07' -Message "Failed to remove $repo `r`n${_.Exception.Message}`r`n"
                Exit 7
            }
        }
        Write-Output "cloning $repo"
        git clone "https://github.com/triembed/$repo.git"
        New-Item "$repo\.cloned"
    }
}


# Switch parameter processing
if ($version) {
    Write-Output "version: $versionId"
    Exit 0
}

if ($help) {
    myhelp # this calls usage, which exits
    Exit 1 # we never get here
}

# Additional parameter checking
$exit = $False
if ($WIFISSID -eq '') {
    Write-Error -Category InvalidArgument -ErrorId 'E01' -Message 'The WiFi SSID parameter must be present.'
    # exit the script after doing parameter error checking
    $exit = $True
}

if ($WIFIpassword -eq '') {
    Write-Error -Category InvalidArgument -ErrorId 'E02' -Message 'The WiFi passphrase parameter must be present.'
    # exit the script after doing parameter error checking
    $exit = $True
}

if ($exit) {
    Exit 2 # available in the invoking shell in $lastexitcode
}

# Configure I2C pins based on processor selected
if ($targetdevice -eq 'ESP32C3' -And $c3board -eq '60') {
    $targetsda = 1
    $targetscl = 0
}
elseif ($targetdevice -eq 'ESP32C3' -And $c3board -eq '70') {
    $targetsda = 18
    $targetscl = 19
}
elseif ($targetdevice -eq 'ESP32') {
    $targetsda = 18
    $targetscl = 19
}
elseif ($targetdevice -eq 'ESP32S2') {
    $targetsda = 1
    $targetscl = 0
}
else {
    Write-Error -Category NotImplemented -ErrorId 'E03' -Message "Write code to handle $targetdevice with $c3board"
    Exit 3
}

# install ESP-IDF
if ((Test-Path "$idfdir\frameworks\esp-idf-v4.4" -PathType Container) `
 -And (Test-Path "$idfdir\tools\espressif-ide\2.5.0\espressif-ide.exe" -PathType Leaf) `
 -And (Test-Path "$idfdir\Initialize-Idf.ps1" -PathType Leaf)) {
        # All is good
} else {
    # Reinstall ESP-IDF

    # The easiest way to install ESP-IDF’s prerequisites is to download one of ESP-IDF Tools Installers
    # from this URL: https://dl.espressif.com/dl/esp-idf/?idf=4.4
    # https://dl.espressif.com/dl/idf-installer/espressif-ide-setup-espressif-ide-2.5.0-with-esp-idf-4.4.exe
    # https://dl.espressif.com/dl/idf-installer/esp-idf-tools-setup-online-2.15.exe
    if (!(Test-Path -PathType Leaf -Path "$env:userprofile\Downloads\espressif-ide-setup-espressif-ide-2.5.0-with-esp-idf-4.4.exe")) {
        $source = 'https://dl.espressif.com/dl/idf-installer/espressif-ide-setup-espressif-ide-2.5.0-with-esp-idf-4.4.exe'
        $destination = "$env:userprofile\Downloads"
        Invoke-RestMethod -Uri $source -OutFile $destination
        # check that this worked ...
        Write-Output "Download ESP-IDF installer status: $lastexitcode"
        # 9009 System.UnauthorizedAccessException
    }

    . "$env:userprofile\Downloads\espressif-ide-setup-espressif-ide-2.5.0-with-esp-idf-4.4.exe"
    # check that this worked ...
    Write-Output "espressif-ide-setup-espressif-ide-2.5.0-with-esp-idf-4.4.exe status: $lastexitcode"

    if ((Test-Path "$idfdir\frameworks\esp-idf-v4.4" -PathType Container) `
    -And (Test-Path "$idfdir\tools\espressif-ide\2.5.0\espressif-ide.exe" -PathType Leaf) `
    -And (Test-Path "$idfdir\Initialize-Idf.ps1" -PathType Leaf)) {
        Write-Output "ESP-IDF installation worked"
        # do we want to touch a DOTfile?
     } else {
        # Failure of some sort
        Write-Error -Category NotInstalled -ErrorId 'E08' "espressif-ide-setup-espressif-ide-2.5.0-with-esp-idf-4.4.exe did not create the expected files:
            $idfdir\frameworks\esp-idf-v4.4
            $idfdir\tools\espressif-ide\2.5.0\espressif-ide.exe
            $idfdir\Initialize-Idf.ps1
            "
        Exit 8
    }
}

# Create directories if they do not already exist
makeDirectory $targetdir
Push-Location $targetdir

# It's become too error prone to determine whether que_ant and/or que_aardvark
# have been mutated by a previous run of the script. Just always clone fresh
# copies for now.

# For a future otimization can seaarch for "[up to date]" in output of
# git fetch -v --dry-run to determine if an already present is up to date
# with its remote copy. If we can figure out how to answer the question
# "has an npm install been done already?" and "has an npm run build?" been
# done already then the script can be further optimized.

gitCloneRepo('que_aardvark')
gitCloneRepo('que_ant')

# install nvm
# C:\Users\Paul\AppData\Roaming\nvm
# C:\Program Files\nodejs
if (!(Test-Path -PathType Container -Path "$env:userprofile\AppData\Roaming\nvm")) {
    # remove existing %ProgramFiles%\nodejs
    # Check with user that this is OK to do here
    if (Test-Path "$env:ProgramFiles\nodejs" -PathType Container) {
        # Need a try/Catch here
        Remove-Item -Recurse -Force "$env:ProgramFiles\nodejs"
    }

    # backup %AppData%\npm\etc\npmrc
    if (Test-Path "$env:AppData\npm\etc\npmrc" -PathType Leaf) {
        # Need a try/Catch here
        Copy-Item "$env:AppData\npm\etc\npmrc" "$targetdir\npmrc_backup"
    }

    # remove %AppData%\npm
    if (Test-Path "$env:AppData\npm" -PathType Container) {
        # Need a try/Catch here
        Remove-Item -Recurse -Force "$env:AppData\npm"
    }

    # download: nvm-setup.zip
    $Url = 'https://github.com/coreybutler/nvm-windows/releases/download/1.1.9/nvm-setup.zip'
    $DownloadZipFile = "$targetdir\" + $(Split-Path -Path $Url -Leaf)
    if (!(Test-Path $DownloadZipFile -PathType Leaf)) {
        Invoke-WebRequest -Uri $Url -OutFile $DownloadZipFile
    }

    # Extract setup file from the zip file
    $ExtractPath = "$targetdir\nvm_zip\"
    if (!(Test-Path $ExtractPath -PathType Container)) {
        makeDirectory($ExtractPath)
        $ExtractShell = New-Object -ComObject Shell.Application
        $zipPackage = $ExtractShell.NameSpace($DownloadZipFile)
        $listOfItems = $zipPackage.Items()
        $ExtractShell.NameSpace($ExtractPath).CopyHere($listOfItems)
        Start-Process $ExtractShell -Wait
    }

    # run $targetdir\nvm_zip\nvm-setup.exe
    Start-Process -FilePath "$targetdir\nvm_zip\nvm-setup.exe" -Wait # -WorkingDirectory 'foo'

    if (!(Test-Path "$env:userprofile\AppData\Roaming\nvm\nvm.exe" -PathType Leaf)) {
        # installation failure ...
        Write-Error -Category NotInstalled -ErrorId 'E09' "$targetdir\nvm_zip\nvm-setup.exe did not create the expected files:
            $env:userprofile\AppData\Roaming\nvm\nvm.exe
            "
        Exit 9
    }
}

if (. "$env:userprofile\AppData\Roaming\nvm\nvm.exe" list | Select-String -SimpleMatch -Pattern "$nodeversion") {
    Write-Output "Node.js version $nodeversion is currently installed"
} else {
    Write-Output "install node.js version $nodeversion"
    #Start-Process -FilePath "$env:userprofile\AppData\Roaming\nvm\nvm.exe" -ArgumentList "install $nodeversion" -Wait -PassThru

    # $env:NVM_HOME = "$env:userprofile\AppData\Roaming\nvm"
    . "$env:userprofile\AppData\Roaming\nvm\nvm.exe" install $nodeversion

    # This is what we are expecting to happen
    #PS C:\Users\Paul\AppData\Roaming\nvm> nvm install 14
    #Downloading node.js version 14.20.0 (64-bit)...
    #Complete
    #Creating C:\Users\Paul\AppData\Roaming\nvm\temp
    #
    #Downloading npm version 6.14.17... Complete
    #Installing npm v6.14.17...
    #
    #Installation complete. If you want to use this version, type
    #
    #nvm use 14.20.0    
}

$current = & $env:userprofile\AppData\Roaming\nvm\nvm.exe current
if ($current  | Select-String -SimpleMatch -Pattern "$nodeversion") {
    # all is good
} elseif ($current | Select-String -SimpleMatch -Pattern 'No current version.') {
    # need to do a "use"
    # this may require running as Administrator
    $output = & "$env:userprofile\AppData\Roaming\nvm\nvm.exe" use $nodeversion 2>&1
    # check that this worked ...
    if ($output | Select-String -SimpleMatch -Pattern 'exit status 32') {
        # not sure what the issue is with this, but it is what I am currently getting
    } else {
        Write-Error -ErrorId 'E10' -Category NotImplemented "Need code to handle `"nvm.exe current`" output: $output"
        Exit 10
    }
    Write-Output "nvm install status: $lastexitcode"
} else {
    Write-Error -ErrorId 'E11' -Category NotImplemented "Need code to handle `"nvm.exe current`" output: $current"
    Exit 11
}

$version = & $env:userprofile\AppData\Roaming\nvm\v14.20.0\npm.cmd --version
if ($version | Select-String -SimpleMatch -Pattern $npmversion) {
    # all is good
} else {
    Write-Error -ErrorId 'E12' -Category NotImplemented "Need code to handle `"npm.cmd --version`" output: $version"
    Exit 12
}

# go to que_and and build


# May not have these env variables, though
# NVM_HOME                       C:\Users\Paul\AppData\Roaming\nvm
# NVM_SYMLINK                    C:\Program Files\nodejs


$date = Get-Date -format 'yyyy-MM-dd'
#Clear-Host
Write-Output '\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/'
Write-Output "Welcome $Env:USERNAME"
Write-Output $date
Write-Output 'Quercus installation script'

#Write-Output "$MyInvocation.MyCommand.Path" # useless when run in the debugger
#Write-Output "$MyInvocation.MyCommand.Name" # useless when run in the debugger
Write-Output "$PSScriptRoot" # C:\Users\Paul\Dropbox\Quercus\que_tools\windows
Write-Output "$PSCommandPath" # C:\Users\Paul\Dropbox\Quercus\que_tools\windows\test.ps1
Write-Output $(Split-Path -Path $PSCommandPath -Leaf) # test.ps1

Write-Output "targetdir: $targetdir"
Write-Output "idfdir: $idfdir"
Write-Output "targetdevice: $targetdevice"
Write-Output "targetbranch: $targetbranch"#
Write-Output "nvm version: $nodeversion"
Write-Output "npm version: $npmversion"
Write-Output "targetsda: $targetsda"
Write-Output "targetscl: $targetscl"
Write-Output "targetSSID: $WIFISSID"
Write-Output "targetpassword: $WIFIpassword"

# List PowerShell's Environmental Variables
#Get-Childitem -Path Env:* | Sort-Object Name


