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
#     operations (use hidden files for latter). Repo issue #1 should enable
#     this.
#  2) Add a function to handle the tmp log and operation result idiom
#  3) Check cmake version and update as needed. CMake version 3.16 or newer is
#     required for use with ESP-IDF. Run “tools/idf_tools.py install cmake” to
#     install a suitable version if your OS version doesn’t have one.
#  4) Use a signal handler to avoid getting hosed by a random ^C.
#  5) Add support for other Linux distros when needed. See here:
# https://docs.espressif.com/projects/esp-idf/en/latest/esp32/get-started/index.html
#  6) Validate -d|--target-branch argument against git branch -a to make sure
#     the branch exists
#

# Bump this per push

version="0.34"

# Authors and maintainers

# Add your email here and append your name to the copyright list with commas

# pete@soper.us
# rob.mackie@gmail.com
# nickedgington@gmail.com
# carl.nobile@gmail.com

# Note: there should be discussion about the fact that the users's WIFI
# password is passed in plain text and held in plain text in config,
# source files, and the ESP32 binary.

# Concerning the directory pathname for the Espressif IDF directory.
# Be careful about having multiple instances of esp-idf because the most
# recent invocation of install.sh governs which is used, NOT which one contained
# the export.sh file that was sourced. (Is this completely correct? It is for
# sure partially correct because install.sh mutates ~/.expressif but export.sh
# does not).

# The git branch labels for the exact version of tools to install. If this
# variable does not match the branch of an existing esp-idf the script must
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

##########################################################################
# Do not change any lines below or you will find all the furure projects #
# you work on for the rest of your life will fail. Just saying.          #
##########################################################################

# Internal variables
LOG_PATH=""

# Arguments from the command line
WIFI_SSID=$1
WIFI_PASSWD=$2
DEVICE=$3
TARGET_DIR=$4
IDF_DIR=$5
TARGET_BRANCH=$6
DEBUG=$7
C3BOARD=$8

# Internal variables
TMP=$(dirname "$0")
ROOT_PATH=$(readlink -f "$TMP")

# The nvm version
nodeversion="14"

# Ubuntu dependencies

packages="git wget flex bison gperf python3 python3-venv cmake ninja-build ccache libffi-dev libssl-dev dfu-util libusb-1.0-0 direnv curl libnss-mdns"

# Flags to put out additional info at end
neednewterminal=0
needtologout=0

# Detail proper usage of the script command and error exit

# Output a fatal error message and error exit

#
# Debug
#
# Arguments can be a list of strings or variables. All variable name cannot
# be proceeded by a $ in order for the debug function to work properly.
#
# $1 -- Printed message before list.
# $@ -- Any variables to print.
#
function debug() {
    if [ "$DEBUG" != "0" ]; then
        local dashes="--------------------------------------------------"
        printf "%s\n%s\n" "$1" "$dashes"
        shift

        for val in "$@"; do
            eval tmp="\$$val"
            printf "%15s: %s\n" "$val" "$tmp"
        done

        printf "\n"
    fi
}


#
# getyes
#
# Display a prompt, then ask for a Y, y, N or n response.
# Return true if Y or y, else return false if N or n.
# Will loop until either a yes or no response. Use ctrl-C to break out.
#
# $1 -- Prompt
#
getyes() {
    while true; do
        read -p "$1 [YyNn]: " ans

        if [ $ans = "Y" ] || [ $ans = "y" ] ; then
            return 0
        elif [ $ans = "N" ] || [ $ans = "n" ] ; then
            return 1
        else
            printf "Answer MUST be Y, y, N, or n\n"
        fi

    done
}


#
# create_log_dir
#
# Creates a log directory in /tmp
#
function create_log_dir() {
    local username=$(whoami)
    LOG_PATH=$(printf "/tmp/quercus-%s" "$username")

    if [ ! -f "$LOG_PATH" ]; then
        mkdir "$LOG_PATH"
    fi
}


#
# fatal
#
# Removes the log files.
#
# $1 -- Message to print to the screen.
#
function fatal() {
  printf "$1\n"
  rm -rf "$LOG_PATH"
  exit 1
}

#########################
# Execution starts here #
#########################
create_log_dir

case "$DEVICE" in
    ESP32C3)
        if [ "$C3BOARD" -eq 60 ] ; then
            targetsda=18
            targetscl=19
        elif [ "$C3BOARD" -eq 70 ] ; then
            targetsda=1
            targetscl=0
        else
            fatal "unknown ESP32C3 board version number"
        fi;
        ;;
    ESP32)
        targetsda=18
        targetscl=19
        ;;
    ESP32S2)
        targetsda=1
        targetscl=0
        ;;
    *) fatal "unknown targetdevice: $targetdevice";;
esac

debug "Command line variables" "WIFI_SSID" "WIFI_PASSWD" "DEVICE" \
      "C3BOARD" "TARGET_DIR" "IDF_DIR" "TARGET_BRANCH" "DEBUG"

# Create $TARGET_DIR and $HOME/.quercus if they do not exist

for d in "$TARGET_DIR" "$IDF_DIR"; do
    if [ ! -d "$d" ]; then
        if getyes "$d does not exist: create it?"; then
            mkdir "$d"

            if [ $? -ne 0 ]; then
	        fatal "Could not create $d"
            fi
        fi
    fi
done

# Get the user into dialout group if not already in it

groups | grep dialout > /dev/null

if [ $? -ne 0 ] ; then
    printf "Adding user to dialout group for USB device access: logout/login needed.\n"
    sudo usermod -a -G dialout $USER # BE CAREFUL TO DO THIS RIGHT!
    needtologout=1
fi

debug "Internal variables" "TMP" "ROOT_PATH" "nodeversion" "targetsda" \
      "targetscl" "needtologout"

printf "Installing required Linux packages.\n"

apt list --installed > "$LOG_PATH/tmp.$$" 2>&1

for package in $packages ; do
    grep "^$package" "$LOG_PATH/tmp.$$" > /dev/null 2>&1

    if [ $? -ne 0 ]; then
        sudo apt-get install -y $package > "$LOG_PATH/log.$$" 2>&1

        if [ $? -eq 0 ]; then
            printf "Installed Linux package %s\n" "$package"
        else
            cat "$LOG_PATH/log.$$"
            fatal "Could not install Linux package $package"
        fi
    fi
done

# Add direnv hook to .bashrc if not already there
grep "direnv hook bash" ~/.bashrc  > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "" >>~/.bashrc
    echo 'eval "$(direnv hook bash)"' >>~/.bashrc

    if [ $? -ne 0 ] ; then
        fail "Could not edit ~/.bashrc"
    fi

    neednewterminal=1
    printf "direnv has been set up but a new terminal is required.\n"
fi

# Determine if Espressif IDF already present and ready to use.
# If present but not usable, offer to recreate it.

if [ -d "$IDF_DIR/esp-idf" ]; then
    cd "$IDF_DIR/esp-idf"
    git branch -a | grep '^\*' | grep "$TARGET_BRANCH" > /dev/null

    if [ $? -eq 0 ] && [ -e .cloned ] && [ -e .submodules ] && [ -e .installed ]
    then
        present=1
    else
        if getyes "$IDF_DIR/esp-idf is present but not usable: recreate it?"
        then
            rm -rf "$IDF_DIR/esp-idf"

            if [ $? -ne 0 ] ; then
	        fatal "Could not erase $IDF_DIR/esp-idf"
            else
	        present=0
            fi
        else
            fatal "stash or correct esp-idf and run the script again"
        fi
    fi
fi

debug "Internal variables" "neednewterminal" "present"

if [ ! $present ]; then
    cd "$IDF_DIR"
    printf "Cloning esp-idf\n"
    git clone https://github.com/espressif/esp-idf.git > "$LOG_PATH/log.$$" 2>&1

    if [ $? -ne 0 ]; then
        cat "$LOG_PATH/log.$$"
        fatal "Could not clone espressif esp-idf repository."
    else
        cd esp-idf
        touch .cloned
        git checkout $TARGET_BRANCHprefix$TARGET_BRANCH > "$LOG_PATH/log.$$" 2>&1

        if [ $? -ne 0 ] ; then
            cat "$LOG_PATH/log.$$"
            fatal "git checkout $TARGET_BRANCHprefix$TARGET_BRANCH failed"
        fi

        printf "Loading submodules: This takes longer than the repo clone, be patient.\n"
        git submodule update --init --recursive > "$LOG_PATH/log.$$" 2>&1

        if [ $? -ne 0 ]; then
            cat "$LOG_PATH/log.$$"
            fatal "git submodule update --init --recursive failed"
        else
            touch .submodules
        fi

        # install source of export.sh in esp-idf/examples so power users
        # can have multiple esp-idf dirs with different branches

        cd "$IDF_DIR/esp-idf/examples"
        echo ". $IDF_DIR/esp-idf/export.sh" > .envrc
        direnv allow
    fi
fi

# Do a fresh install of the idf because we cannot know whether or not another
# instance has been installed by the user.

cd "$IDF_DIR/esp-idf"
./install.sh > "$LOG_PATH/log.$$"

if [ "$?" -ne 0 ]; then
    cat "$LOG_PATH/log.$$"
    fatal "esp-idf/install.sh failed"
fi

touch .installed

printf "Valid esp-idf repo\n"

# It's become too error prone to determine whether que_ant and/or que_aardvark
# have been mutated by a previous run of the script. Just always clone fresh
# copies for now.

# For a future otimization can seaarch for "[up to date]" in output of
# git fetch -v --dry-run to determine if an already present is up to date
# with its remote copy. If we can figure out how to answer the question
# "has an npm install been done already?" and "has an npm run build?" been
# done already then the script can be further optimized.

printf "Cloning que_aardvark and que_ant\n"
cd "$TARGET_DIR"

for repo in aardvark ant; do
    if [ -d que_$repo ] && [ -e que_$repo/.copied ]; then
        printf "\n" # hack
    else
        rm -rf que_$repo
        cp -r $ROOT_PATH/../../$repo que_$repo
        touch que_$repo/.copied
    fi
done

# Setting up direnv to automatically run IDF export.sh
# and steer node version when que_ant is cd'd to.

if [ ! -f "$TARGET_DIR/que_ant/.envrc" ]; then
    echo ". $IDF_DIR/esp-idf/export.sh >/dev/null 2>&1" > "$TARGET_DIR/que_ant/.envrc"
    echo ". $HOME/.nvm/nvm.sh use $nodeversion" >> "$TARGET_DIR/que_ant/.envrc"
    cd "$TARGET_DIR/que_ant"
    direnv allow
fi

# source .bashrc again in case direnv was installed to get the competion enabled
. $HOME/.bashrc > /dev/null 2>&1

if [ ! -d $HOME/.nvm ]; then
    printf "installing nvm\n"
    curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh 2 > /dev/null | bash > "$LOG_PATH/log.$$" 2>&1

    if [ "$?" -ne 0 ]; then
        cat "$LOG_PATH/log.$$"
        fatal "nvm could not be installed"
    fi
fi

# Make nvm visible to this script

export NVM_DIR=$HOME/.nvm
source "$NVM_DIR/nvm.sh" > /dev/null 2>&1

printf "Install node version %s\n" "$nodeversion"
nvm install $nodeversion > "$LOG_PATH/log.$$" 2>&1

if [ "$?" -ne 0 ]; then
    cat "$LOG_PATH/log.$$"
    fatal "Could not install nvm version $nodeversion"
fi

# Creating mdns-findable URL for Aardvark

cd "$TARGET_DIR/que_aardvark/src"

. "$IDF_DIR/esp-idf/export.sh" > /dev/null 2>&1
f1=$(esptool.py chip_id | grep MAC: | head -1 | cut -d: -f 6)
f2=$(esptool.py chip_id | grep MAC: | head -1 | cut -d: -f 7)

if [ "$?" -ne 0 ]; then
    printf "Dev board not connected: using 0000 as MAC address low order digits.\n"
    f1="00"
    f2="00"
fi

echo "export default {" > autoconfiguration.js
#echo "  localurl:  'http://ant_$f1$f2.local'" >> autoconfiguration.js
echo "  localurl:  'http://ant_0000.local'" >> autoconfiguration.js
echo "}" >> autoconfiguration.js
#printf "Micro DNS url for ant: http://ant_$f1$f2.local\n"
printf "Micro DNS url for ant: http://ant_0000.local\n"
printf "Preparing node in que_aardvark.\n"

cd "$TARGET_DIR/que_aardvark"

if [ ! -e .installed ]; then
    printf "Installing npm in que_aardvark\n"
    npm install > "$LOG_PATH/log.$$" 2>&1

    if [ "$?" -ne 0 ]; then
        cat "$LOG_PATH/log.$$"
        fatal "Could not install npm in que_aardvark."
    fi

    touch .installed
fi

npm run build > "$LOG_PATH/log.$$" 2>&1

if [ "$?" -ne 0 ]; then
    cat "$LOG_PATH/log.$$"
    fatal "Could not npm run build in que_aardvark"
fi

printf "Preparing node in que_ant.\n"

cd "$TARGET_DIR/que_ant/ant"
printf "Installing npm in que_ant.\n"
npm install > "$LOG_PATH/log.$$" 2>&1

if [ "$?" -ne 0 ]; then
    cat "$LOG_PATH/log.$$"
    fatal "Could not install npm in que_ant/ant.\n"
fi

npm run build > "$LOG_PATH/log.$$" 2>&1

if [ "$?" -ne 0 ]; then
    cat "$LOG_PATH/log.$$"
    fatal "Could not npm run build in que_ant/\n"
fi

printf "Kconfig.projbuild edits in que_ant.\n"

# Edit main/Kconfig.projbuild for SSID, password, SDA and SCL pins

cd "$TARGET_DIR/que_ant/components/apsta"
sed -e"s+.*ROUTERSSID.*$+               default $WIFI_SSID   # ROUTERSSID+" Kconfig.projbuild > "$LOG_PATH/tmp.$$"
sed -e"s+.*ROUTERPASSWORD.*$+               default $WIFI_PASSWD   # ROUTERPASSWORD+" "$LOG_PATH/tmp.$$" > Kconfig.projbuild

# What is this doing? Probably superstious. Ask Nick.
touch "$TARGET_DIR/que_ant/sdkconfig"

cd "$TARGET_DIR/que_ant/main"
sed -e"s+.*TARGETSDA.*$+		default $targetsda   # TARGETSDA+" Kconfig.projbuild > "$LOG_PATH/tmp.$$"
sed -e"s+.*TARGETSCL.*$+		default $targetscl   # TARGETSCL+" "$LOG_PATH/tmp.$$" > Kconfig.projbuild

. "$IDF_DIR/esp-idf/export.sh" > /dev/null 2>&1

cd "$TARGET_DIR/que_ant"
rm -rf build
idf.py set-target "$DEVICE" > "$LOG_PATH/log.$$" 2>&1

if [ $? -ne 0 ]; then
    cat "$LOG_PATH/log.$$"
    fatal "Could not do idf.py set-target."
fi

cd "$TARGET_DIR/que_ant"

# Remove this when Nick confirms it is no longer needed. Can't remember if his
# fix is in the repos or not
rm -rf ant/dist/js/*.map

printf "idf build of que_ant\n"
cd "$TARGET_DIR/que_ant"
rm -rf build
idf.py build > "$LOG_PATH/log.$$" 2>&1

if [ $? -ne 0 ]; then
    cat "$LOG_PATH/log.$$"
    fatal "Could not do idf.py build in que_ant.\n"
fi

if [ $neednewterminal -eq 1 ] || [ $needtologout -eq 1 ]; then
    printf "Installation almost complete.\n"

    if [ $needtologout -eq 1 ]; then
        printf "In order to be able to access USB hardware you must log\n"
        printf "out of your Linux session and log back in with your user\n"
        printf "id/password before proceeding with the next steps.\n"
    elif [ $neednewterminal ]; then
        printf "Before proceeding with the next steps below open a new\n"
        printf "terminal and use it for for the steps or else exit this\n"
        printf "terminal session and begin a new one.\n"
    fi
else
    printf "Installation complete\n"
fi

end_message=$(cat << EOF

1. To use the IDF in arbitrary places add the line below (without the quotes) to ~/.bashrc:
   ". %s/esp-idf/export.sh > /dev/null 2>&1"
2. cd to %s/que_ant
   To flash the project execute: idf.py flash
3. Then to display the serial output execute: idf.py monitor
   When it completes copy the first IP address into your clipboard. It may stall
   at the end for a while before displaying a line similar to the one below:
   "esp_netif_handlers: sta ip: 192.168.12.196, mask: 255.255.255.0, gw: 192.168.12.1"
   Use cntrl ] to break out of monitor session.
4. Edit file %s/que_aardvark/src/api/project.js and replace 192.168.100.150 on line 63
   with the IP copied to your clipboard.
5. cd %s/que_aardvark
   Then execute: npm run build
6. To bring up the web server execute: npm run serve
7. Lastly point your browser to http://localhost:8080\n
EOF
)

printf "$end_message" "$IDF_DIR" "$TARGET_DIR" "$TARGET_DIR" "$TARGET_DIR"

rm -rf "$LOG_PATH"
exit 0
