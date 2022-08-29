#!/bin/bash
# Add -x to above line for more verbose output
#
# TriEmbed ESP32/Dialog FPGA Project
#
# Tool chain installation script
# The expectation is that much of this will be put under
# ../common and sourced by the remainder of this script that
# specializes it with arguments to the common script but 
# discussion is needed as the WSL version takes shape and the
# Windows version is thought through (by Windows developers).

# See https://github.com/TriEmbed/quercus/issues for bugs/enhancements

# Todo (not baked well enough for an issue):
#  1) Should be able to detect and elide redundant clones and npm 
#     operations (use hidden files for latter). Repo issue #1 should enable this.
#  2) OK to delete que_ant/ant and corresponding Cmake stuff after these 
#     changes with help from Nick (Pete can't make it work and it isn't a
#     priority)
#  3) Add a function to handle the tmp log and operation result idiom
#  4) Use getopt(1). This page may be sufficient to understand how to
#     do it: https://www.tutorialspoint.com/unix_commands/getopt.html
#  5) Check cmake version and update as needed. CMake version 3.16 or newer is 
#     required for use with ESP-IDF. Run “tools/idf_tools.py install cmake” to 
#     install a suitable version if your OS version doesn’t have one.
#  6) In getyes use a signal handler to ensure exit 1 with ctrl-C if we
#     don't get this for free
#  7) Use a signal handler to avoid getting hosed by a random ^C.
#  8) Add support for other Linux distros when needed. See here:
# https://docs.espressif.com/projects/esp-idf/en/latest/esp32/get-started/index.html
#  9) Validate -targetbranch argument against git branch -a to make sure
#     the branch exists
#

# Bump this per push

version="0.33"

# capture the tools directory

temp=`dirname $0`
rootpath=`readlink -f $temp`

# Authors and maintainers

# Add your email here and append your name to the copyright list with commas

# pete@soper.us
# rob.mackie@gmail.com
# nickedgington@gmail.com

# Note: there should be discussion about the fact that the users's WIFI
# password is passed in plain text and held in plain text in source files and
# the ESP32 binary.

# The default target ESP32 device

targetdevice="ESP32C3"

# The default version of que_purple board. Currently 60 and 70 are identical:
# no need to use -c3board option.

c3board=70

# The directory pathname for the user's Quercus repositories

idfdir=~/.quercus

targetdir=$idfdir

# The directory pathname for the Espressif IDF directory
# Note this cannot be currently changed from the command line. 
# Be careful about having multiple instances of esp-idf because the most
# recent invocation of install.sh governs which is used, NOT which one contained
# the export.sh file that was sourced. (Is this completely correct? It is for
# sure partially correct because install.sh mutates ~/.expressif but export.sh
# does not).


# The git branch labels for the exact version of tools to install. If this 
# variable does not match the branch of an  existing esp-idf the script must
# be aborted because there is the likelihood that the submodules are not right.
# The required order is 1) clone, 2) checkout branch, 3) load submodules
# The remotes/origin/release/v4.4 branch is the latest Espressif stable branch.
# the remotes/origin/release/v5.0 branch is the bleeding edge development 
# branch. 

# Git is weird with respect to git branch -a output vs actual branch names
# The correct branch name is $targetbranchprefix$targetbranch

targetbranchprefix="remotes/"

# The base part of the branch name shown by git branch -a
targetbranch="origin/release/v4.4"

#### Do not change lines below here

# The nvm version
nodeversion="14"

# Ubuntu dependencies

packages="git wget flex bison gperf python3 python3-venv cmake ninja-build ccache libffi-dev libssl-dev dfu-util libusb-1.0-0 direnv curl libnss-mdns"


# Flags to put out additional info at end
neednewterminal=0
needtologout=0

# Detail proper usage of the script command and error exit

usage() {
  local name=$(basename "$0")
  echo $1
  echo "usage: $name WIFISSID WIFIpassword [ -targetdevice <ESP32 | ESP32C3 | ESP32S2> ] [ -targetdir <path> ] [ -branch <branch id> ] [ -c3board <60 | 70> ] [ -version ] [ -help ]"
  echo "default targetdir: $targetdir"
  echo "default branch: $targetbranch"
  echo "default device: $targetdevice"
  exit 1
}

help() {
  echo "ESP32, ESP32S3 and ESPC3 supported"
  echo "I2C pins as follows:"
  echo "ESP32: SDA 18 SCL 19"
  echo "ESP32S2: SDA 1 SCL 0"
  echo "ESP32C3: SDA 18 SCL 19 (m80 60 rev) SDA 1 SCL 0 (m80 70 rev)"
  usage ""
}

# Put out a prompt, then ask for a Y, y, N or n response.
# Return true if Y or y, false if N or n. Cannot escape until an acceptable 
# answer is input. Use ctrl-C to break out.

getyes() {
  while [ 1 -eq 1 ] ; do
    echo "$1"
    echo "enter Y, y, N, or n"
    read ans
    if [ $ans = "Y" ] || [ $ans = "y" ] ; then
      return 0
    elif [ $ans = "N" ] || [ $ans = "n" ] ; then
      return 1
    else
      echo "Answer MUST be Y, y, N, or n"
    fi
  done
}

# Output a fatal error message and error exit

fatal() {
  echo $1
  rm -f /tmp/log.$$
  rm -f /tmp/tmp.$$
  exit 1
}

# Brute force handling of option switches

if [ $# -lt 2 ] ; then
  # Take care of a dangling single option switch
  if [ $# -gt 0 ] ; then
    if [ $1 = "-version" ] ; then
      echo "version: $version"
      exit 0
    elif [ $1 = "-help" ] ; then
      help
    else
      usage "unknown command line option: $1"
    fi
  fi
else
  targetSSID=$1
  shift
  targetpassword=$1
  shift
fi

while [ $# -ge 2 ] ; do
  switch=$1
  shift
  
  case $switch in
    -targetbranch)
        targetbranch=$1
        shift
        ;;
    -targetdir)
        targetdir=$1
 	shift
        ;;
    -targetdevice)
        targetdevice=$1
        shift
        esp_types=("ESP32" "ESP32S2" "ESP32C3")
        if [[ "${esp_types[*]}" != *"$targetdevice"* ]] ; then
          usage "unrecognized target device: $targetdevice"
        fi
        ;;
    -c3board)
        c3board=$1
        shift
        if [ $c3board -ne 70 ] && [ $c3board -ne 60 ] ; then
          fatal "-c3board value must be either 60 or 70"
        fi
        ;;
    -version)
        echo "version: $version"
        exit 0
        ;;
    -help)
        help
        ;;
    *)
        usage "unknown option switch: $switch"
        exit 1
        ;;
  esac
done

# Take care of a dangling single option switch
if [ $# -gt 0 ] ; then
  if [ $1 = "-version" ] ; then
    echo "version: $version"
    exit 0
  elif [ $1 = "-help" ] ; then
    help
  else
    usage "unknown command line option: $@"
  fi
fi

case $targetdevice in
  ESP32C3) if [ $c3board -eq 60 ] ; then
             targetsda=18
             targetscl=19
           elif [ $c3board -eq 70 ] ; then
             targetsda=1
             targetscl=0
           else
             fatal "unknown ESP32C3 board version number"
           fi;
           ;;
  ESP32)  targetsda=18
          targetscl=19
          ;;
  ESP32S2) targetsda=1
           targetscl=0
           ;;
  *) fatal "unknown targetdevice: $targetdevice";;
esac

echo "targetdir: $targetdir"
echo "targetdevice: $targetdevice"
echo "targetbranch: $targetbranch"
echo "node version: $nodeversion"
echo "targetsda: $targetsda"
echo "targetscl: $targetscl"
echo "targetSSID: $targetSSID"
echo "targetpassword: $targetpassword"

# Create $targetdir and $HOME/.quercus if they do not exist
dir_array=($targetdir $idfdir)
for d in "${dir_array[@]}"; do
  if [ ! -d $d ] ; then
    if getyes "$d does not exist: create it?" ; then
      mkdir $d
      if [ $? -ne 0 ] ; then
	fatal "could not create $d" 
      fi
    fi
  fi
done
unset dir_array

# Get the user into dialout group if not already in it

groups | grep dialout >/dev/null
if [ $? -ne 0 ] ; then
  echo "Adding user to dialout group for USB device access: logout/login needed"
  sudo usermod -a -G dialout $USER # BE CAREFUL TO DO THIS RIGHT!
  needtologout=1 
fi  

echo "Installing required Linux packages"

apt list --installed >/tmp/tmp.$$ 2>&1
for package in $packages ; do
  grep "^$package" /tmp/tmp.$$ >/dev/null 2>&1
  if [ $? -ne 0 ] ; then
    sudo apt-get install -y $package >/tmp/log.$$ 2>&1
    if [ $? -eq 0 ] ; then
      echo "installed Linux package $package"
    else
      cat /tmp/log.$$
      fatal "Could not install Linux package $package"
    fi
  fi
done

# Add direnv hook to .bashrc if not already there
grep "direnv hook bash" ~/.bashrc  >/dev/null 2>&1
if [ $? -ne 0 ] ; then
  echo "" >>~/.bashrc
  echo 'eval "$(direnv hook bash)"' >>~/.bashrc
  if [ $? -ne 0 ] ; then
    fail "could not edit ~/.bashrc"
  fi
  neednewterminal=1
  echo "direnv has been set up but a new terminal is required"
fi

# Determine if Espressif IDF already present and ready to use. If present but
# not usable, offer to recreate it.

if [ -d $idfdir/esp-idf ] ; then
  cd $idfdir/esp-idf
  git branch -a | grep '^\*' | grep $targetbranch >/dev/null
  if [ $? -eq 0 ] && [ -e .cloned ] && [ -e .submodules ] && [ -e .installed ] ; then
      present=1
  else
    if getyes "$idfdir/esp-idf is present but not usable: recreate it?" ; then
      rm -rf $idfdir/esp-idf
      if [ $? -ne 0 ] ; then
	fatal "Could not erase $idfdir/esp-idf"
      else
	present=0
      fi
    else
      fatal "stash or correct esp-idf and run the script again"
    fi
  fi  
fi

if [ ! $present ] ; then
  cd $idfdir
  echo "cloning esp-idf"
  git clone https://github.com/espressif/esp-idf.git >/tmp/log.$$ 2>&1
  if [ $? -ne 0 ] ; then
    cat /tmp/log.$$
    fatal "Could not clone espressif esp-idf repository"
  else
    cd esp-idf
    touch .cloned
    git checkout $targetbranchprefix$targetbranch >/tmp/log.$$ 2>&1
    if [ $? -ne 0 ] ; then
      cat /tmp/log.$$
      fatal "git checkout $targetbranchprefix$targetbranch failed"
    fi
    echo "loading submodules: this takes longer than the repo clone, be patient"
    git submodule update --init --recursive >/tmp/log.$$ 2>&1
    if [ $? -ne 0 ] ; then
      cat /tmp/log.$$
      fatal "git submodule update --init --recursive failed"
    else
      touch .submodules
    fi

    # install source of export.sh in esp-idf/examples so power users can have 
    # multiple esp-idf dirs with different branches

    cd $idfdir/esp-idf/examples
    echo ". $idfdir/esp-idf/export.sh" >.envrc
    direnv allow
  fi
fi

# Do a fresh install of the idf because we cannot know whether or not another
# instance has been installed by the user. 

cd $idfdir/esp-idf
./install.sh >/tmp/log.$$
if [ $? -ne 0 ] ; then
  cat /tmp/log.$$
  fatal "esp-idf/install.sh failed"
fi
touch .installed

echo "valid esp-idf repo"

# It's become too error prone to determine whether que_ant and/or que_aardvark
# have been mutated by a previous run of the script. Just always clone fresh
# copies for now.


# For a future otimization can seaarch for "[up to date]" in output of
# git fetch -v --dry-run to determine if an already present is up to date
# with its remote copy. If we can figure out how to answer the question
# "has an npm install been done already?" and "has an npm run build?" been
# done already then the script can be further optimized.

echo "clone que_aardvark and que_ant"
cd $targetdir
for repo in aardvark ant ; do
  if [ -d que_$repo ] && [ -e que_$repo/.copied ] ; then
    echo "" # hack
  else
    rm -rf que_$repo
    cp -r $rootpath/../../$repo que_$repo
    touch que_$repo/.copied
  fi
done

# setting up direnv to automatically run IDF export.sh and steer node version
# when que_ant is cd'd to.

if [ ! -f $targetdir/que_ant/.envrc ] ; then
  echo ". $idfdir/esp-idf/export.sh >/dev/null 2>&1" >$targetdir/que_ant/.envrc
  echo ". $HOME/.nvm/nvm.sh use $nodeversion" >>$targetdir/que_ant/.envrc
  cd $targetdir/que_ant
  direnv allow
fi


# source .bashrc again in case direnv was installed to get the competion enabled
. $HOME/.bashrc >/dev/null 2>&1

if [ ! -d $HOME/.nvm ] ; then
  echo "installing nvm"
  curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh 2>/dev/null | bash >/tmp/log.$$ 2>&1
  if [ $? -ne 0 ] ; then
    cat /tmp/log.$$
    fatal "nvm could not be installed"
  fi
fi

# Make nvm visible to this script

export NVM_DIR=$HOME/.nvm
source $NVM_DIR/nvm.sh >/dev/null 2>&1

echo "install node version $nodeversion"
nvm install $nodeversion >/tmp/log.$$ 2>&1
if [ $? -ne 0 ] ; then
  cat /tmp/log.$$
  fatal "could not install nvm version $nodeversion"
fi

# Creating mdns-findable URL for Aardvark

cd $targetdir/que_aardvark/src

. $idfdir/esp-idf/export.sh >/dev/null 2>&1
f1=`esptool.py chip_id | grep MAC: | head -1 | cut -d: -f 6`
f2=`esptool.py chip_id | grep MAC: | head -1 | cut -d: -f 7`
if [ $? -ne 0 ] ; then
  echo "dev board not connected: using 0000 as MAC address low order digits"
  f1="00"
  f2="00"
fi
echo "export default {" >autoconfiguration.js
#echo "  localurl:  'http://ant_$f1$f2.local'" >>autoconfiguration.js
echo "  localurl:  'http://ant_0000.local'" >>autoconfiguration.js
echo "}" >>autoconfiguration.js
#echo "micro DNS url for ant: http://ant_$f1$f2.local"
echo "micro DNS url for ant: http://ant_0000.local"

echo "preparing node in que_aardvark"

cd $targetdir/que_aardvark
if [ ! -e .installed ] ; then
  echo "installing npm in que_aardvark"
  npm install >/tmp/log.$$ 2>&1
  if [ $? -ne 0 ] ; then
    cat /tmp/log.$$
    fatal "could not install npm in que_aardvark"
  fi
  touch .installed
fi

npm run build >/tmp/log.$$ 2>&1
if [ $? -ne 0 ] ; then
  cat /tmp/log.$$
  fatal "could not npm run build in que_aardvark"
fi

echo "preparing node in que_ant"

cd $targetdir/que_ant/ant
echo "installing npm in que_ant"
npm install >/tmp/log.$$ 2>&1
if [ $? -ne 0 ] ; then
  cat /tmp/log.$$
  fatal "could not install npm in que_ant/ant"
fi
  
npm run build >/tmp/log.$$ 2>&1
if [ $? -ne 0 ] ; then
  cat /tmp/log.$$
  fatal "could not npm run build in que_ant"
fi

echo "Kconfig.projbuild edits in que_ant"

# Edit main/Kconfig.projbuild for SSID, password, SDA and SCL pins

cd $targetdir/que_ant/components/apsta
sed -e"s+.*ROUTERSSID.*$+               default $targetSSID   # ROUTERSSID+" Kconfig.projbuild >/tmp/tmp.$$
sed -e"s+.*ROUTERPASSWORD.*$+               default $targetpassword   # ROUTERPASSWORD+" /tmp/tmp.$$ >Kconfig.projbuild

# What is this doing? Probably superstious. Ask Nick.
touch $targetdir/que_ant/sdkconfig

cd $targetdir/que_ant/main
sed -e"s+.*TARGETSDA.*$+		default $targetsda   # TARGETSDA+" Kconfig.projbuild >/tmp/tmp.$$
sed -e"s+.*TARGETSCL.*$+		default $targetscl   # TARGETSCL+" /tmp/tmp.$$ >Kconfig.projbuild

. $idfdir/esp-idf/export.sh >/dev/null 2>&1

cd $targetdir/que_ant
rm -rf build
idf.py set-target $targetdevice >/tmp/log.$$ 2>&1
if [ $? -ne 0 ] ; then
  cat /tmp/log.$$
  fatal "could not do idf.py set-target"
fi

cd $targetdir/que_ant

# Remove this when Nick confirms it is no longer needed. Can't remember if his
# fix is in the repos or not
rm -rf ant/dist/js/*.map

echo "idf build of que_ant"
cd $targetdir/que_ant
rm -rf build
idf.py build >/tmp/log.$$ 2>&1
if [ $? -ne 0 ] ; then
  cat /tmp/log.$$
  fatal "could not do idf.py build in que_ant"
fi

if [ $neednewterminal -eq 1 ] || [ $needtologout -eq 1 ] ; then
  echo "installation almost complete"
  if [ $needtologout -eq 1 ] ; then
    echo "In order to be able to access USB hardware you must log out of"
    echo "your Linux session and log back in with your user id/password before"
    echo "proceeding with the next steps."
  elif [ $neednewterminal ] ; then
    echo "Before proceeding with the next steps below open a new terminal"
    echo "and use it for for the steps or else exit this terminal session and"
    echo "begin a new one."
  fi
else
  echo "installation complete"
fi

echo "To use the IDF in arbitrary places add this line to ~/.bashrc:"
echo ". $idfdir/esp-idf/export.sh >/dev/null 2>&1"
echo "Now cd to $targetdir/que_ant and enter 'idf.py flash'"
echo "Then enter 'idf.py monitor' and copy the IP address into your clipboard."
echo "The IP address will look something like this:"
echo "esp_netif_handlers: sta ip: 192.168.12.196, mask: 255.255.255.0, gw: 192.168.12.1"
echo "Use cntrl ] to break out of monitor when you no longer need it."
echo "Then edit file $targetdir/que_aardvark/src/api/project.js and replace"
echo "192.168.100.150 on line 56 with the IP copied to your clipboard."
echo "Then cd to $targetdir/que_aardvark and enter 'npm run build'."
echo "Then 'npm run serve'."
echo "Then point your browser to http://localhost:8080"

rm -f /tmp/log.$$ /tmp/tmp.$$

exit 0
