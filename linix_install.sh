#!/usr/bin/env bash
#
# linux_install.sh
#
# This script calls the linux installit.sh script.
#
# The location of the config file can be either in the root of the quercus
# directory or in the user's home directory. You can change the name of the
# file as shown below.
#
# For help on this script run with -h or --help.
#

DEBUG=0
INSTALLIT="./tools/linux/installit.sh"
CURRENT_DIR=$(dirname $0)
ABS_PATH=$(readlink -f $CURRENT_DIR)
DEF_CONFIG=".quercusrc"
CONFIG_FILE=""
CONFIG_FULL_PATH=""
REWRITE_CONFIG=0
WIFI_SSID=""
WIFI_PASSWD=""
DEVICE="ESP32C3"
TARGET_DIR="$HOME/.quercus"
C3BOARD=70
TARGET_BRANCH="origin/release/v4.4"


#
# Debug function
#
# Arguments can be a list of strings or variables. All variable name cannot
# be preceeded by a $ in order for the debug function to work properly.
#
function debug() {
    if [ "$DEBUG" != "0" ]; then
        for val in "$@"; do
            eval tmp="\$$val"
            printf "%16s: %s\n" "$val" "$tmp"
        done
    fi
}


#
# help
#
function help() {
    local name=$(basename "$0")
    local help=$(cat << EOF
Usage: %s
    -c FILE | --config FILE             - Optional config file, defaults to %s
    -d DEVICE | --device DEVICE         - Can be one of ESP32 | ESP32C3 | ESP32S2.
    -r | --rewrite-config               - Rewrites the config file.
    -t TARGET_DIR | --target TARGET_DIR - The directory where the build will reside, defaults to %s/.quercus.
    -D | --debug                        - Turn on DEBUG mode.
    -h | --help                         - This screen.\n\n
EOF
)
    printf "$help" "$name" "$DEF_CONFIG" "$HOME"
}


#
# Get options
#
# Pass $* as the only argument.
#
function get_opts() {
    local opts="c:s:p:d:t:Dhr"
    local long="config::,wifi-ssid::,wifi-passwd::,device::,target-dir::,help,debug,rewrite-config"
    local options=$(getopt -o $opts --long $long -- "$@")
    eval set -- "$options"

    while true; do
        case "$1" in
            -c|--config)
                CONFIG_FILE=$2
                shift 2
                ;;
            -s|--wifi-ssid)
                WIFI_SSID=$2
                shift 2
                ;;
            -p|--wifi-passwd)
                WIFI_PASSWD=$2
                shift 2
                ;;
            -d|--device)
                DEVICE=$2
                shift 2
                ;;
            -t|--target-dir)
                TARGET_DIR=$2
                shift 2
                ;;
            -3|--c3board)
                C3BOARD=$2
                shift 2
                ;;
            -b|--target-branch)
                TARGET_BRANCH=$2
                shift 2
                ;;
            -r|--rewrite-config)
                REWRITE_CONFIG=1
                shift
                ;;
            -D|--debug)
                DEBUG=1
                shift
                ;;
            -h|--help)
                help
                $(printf "%s -help\n" "$INSTALLIT")
                exit 2
                ;;
            --)
                shift
                break
                ;;
            *)
                printf "Unknown argument: %s\n" "$1"
                exit 1
                ;;
        esac
    done
}


#
# Get config file
#
function find_config() {
    local path_dir dflag=0
    local paths=("$ABS_PATH" "$HOME")
    local files=("$CONFIG_FILE" "$DEF_CONFIG")

    for path in "${paths[@]}"; do
        for file in "${files[@]}"; do
            path_dir="$path/$file"
            #printf "%s\n" $path_dir

            if [ -f "$path_dir" ]; then
                dflag=1
                break
            fi

        done

        if [ "$dflag" = 1 ]; then
            break
        fi
    done

    if [ "$dflag" = 1 ]; then
        CONFIG_FULL_PATH="$path_dir"
    fi
}


#
# Read the config file.
#
function read_file() {
    if [ -f "$CONFIG_FULL_PATH" ]; then
        source $CONFIG_FULL_PATH
    fi
}


#
# Ask for arguments
#
function ask_for_args() {
    local tmp files=("$CONFIG_FILE" "$DEF_CONFIG")

    for file in "${files[@]}"; do
        if [ "$file" != "" ]; then
            CONFIG_FULL_PATH="$ABS_PATH/$file"
            break
        fi

    done

    #printf "%s\n%s\n%s\n" "$CONFIG_FULL_PATH" "$WIFI_SSID" "$WIFI_PASSWD"

    while true; do
        read -p "Enter WiFi SSID or if exists Default ($WIFI_SSID) [Dd]: " tmp

        if [ "${tmp^^}" = "D" ]; then
            if [ "$WIFI_SSID" != "" ]; then
                break
            fi
        elif [ "$tmp" != "" ]; then
            WIFI_SSID=$tmp
            break
        fi
    done

    while true; do
        read -p "Enter WiFi passwd or if exists Default ($WIFI_PASSWD) [Dd]: " tmp

        if [ "${tmp^^}" = "D" ]; then
            if [ "$WIFI_PASSWD" != "" ]; then
                break
            fi
        elif [ "$tmp" != "" ]; then
            WIFI_PASSWD=$tmp
            break
        fi
    done

    while true; do
        read -p "Enter target device or Default ($DEVICE) [Dd]: " tmp

        if [ "${tmp^^}" = "D" ]; then
            break
        elif [ "$tmp" != "" ]; then
            DEVICE=$tmp
            break
        fi
    done

    while true; do
        read -p "Enter target directory or Default ($TARGET_DIR) [Dd]: " tmp

        if [ "${tmp^^}" = "D" ]; then
            break
        elif [ "$tmp" != "" ]; then
            TARGET_DIR=$tmp
            break
        fi
    done

    while true; do
        read -p "Enter C3 board ID or Default ($C3BOARD) [Dd]: " tmp

        if [ "${tmp^^}" = "D" ]; then
            break
        elif [ "$tmp" != "" ]; then
            C3BOARD=$tmp
            break
        fi
    done

    while true; do
        read -p "Enter target branch or Default ($TARGET_BRANCH) [Dd]: " tmp

        if [ "${tmp^^}" = "D" ]; then
            break
        elif [ "$tmp" != "" ]; then
            TARGET_BRANCH=$tmp
            break
        fi
    done

    printf 'WIFI_SSID="%s"\n' "$WIFI_SSID" > "$CONFIG_FULL_PATH"
    printf 'WIFI_PASSWD="%s"\n' "$WIFI_PASSWD" >> "$CONFIG_FULL_PATH"
    printf 'DEVICE="%s"\n' "$DEVICE" >> "$CONFIG_FULL_PATH"
    printf 'TARGET_DIR="%s"\n' "$TARGET_DIR" >> "$CONFIG_FULL_PATH"
    printf 'C3BOARD="%s"\n' "$C3BOARD" >> "$CONFIG_FULL_PATH"
    printf 'TARGET_BRANCH="%s"\n' "$TARGET_BRANCH" >> "$CONFIG_FULL_PATH"
}


#======================+
# Start Execution Here |
#======================+
get_opts $*
find_config
read_file

debug "INSTALLIT" "CURRENT_DIR" "ABS_PATH" "HOME" "DEF_CONFIG" "CONFIG_FILE" \
      "CONFIG_FULL_PATH" "REWRITE_CONFIG"

if [ "$CONFIG_FULL_PATH" = "" ] || [ "$REWRITE_CONFIG" -eq 1 ]; then
    ask_for_args
fi

debug "WIFI_SSID" "WIFI_PASSWD" "DEVICE" "TARGET_DIR" "C3BOARD" "TARGET_BRANCH"

if [ ! -f "$TARGET_DIR" ]; then
    mkdir -p "$TARGET_DIR"
fi

$(printf '%s %s %s -targetdevice %s -targetdir %s -targetbranch %s -c3board %s' \
         "$INSTALLIT" "$WIFI_SSID" "$WIFI_PASSWD" "$DEVICE" "$TARGET_DIR" \
         "$TARGET_BRANCH" "$C3BOARD")
