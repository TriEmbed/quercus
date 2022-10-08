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
# Exit status:
#   0 -- Normal exit value.
#   1 -- Exit value after the help screen was called.
#   2 -- Exit value for an unknown argument.
#

# Internal variables except for _CONF_FULL_PATH not modified by anything
########################################################################
_ESP_DEVICES=("ESP32" "ESP32C3" "ESP32S2")
_DEVICE="ESP32C3"
_C3_TYPES=(60 70)
_C3BOARD=70
_IDF_DIR="$HOME/.quercus"
_INSTALLIT="./tools/linux/installit.sh"
_CURRENT_DIR=$(dirname "$0")
_ABS_PATH=$(readlink -f "$_CURRENT_DIR")
_DEF_CONF=".quercusrc"
_CONF_FULL_PATH=""
_TARGET_BRANCH="origin/release/v4.4"

# Configurable variables set by the args on the CLI
###################################################
DEBUG=0
NOOP=0
REWRITE_CONF=0
OPT_CONF_FILE=""
WIFI_SSID=""
WIFI_PASSWD=""
DEVICE=""
TARGET_DIR=""
C3BOARD=""
TARGET_BRANCH=""

# Config file values set by the config file if it exists
########################################################
X_WIFI_SSID=""
X_WIFI_PASSWD=""
X_DEVICE="$_DEVICE"
X_TARGET_DIR="$_IDF_DIR"
X_C3BOARD=$_C3BOARD
X_TARGET_BRANCH="$_TARGET_BRANCH"


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
        printf "%s\n%s\n" "$1" $dashes
        shift

        for val in "$@"; do
            eval tmp="\$$val"
            printf "%15s: %s\n" "$val" "$tmp"
        done

        printf "\n"
    fi
}


#
# help
#
function help() {
    local c3=$(printf " | %s" "${_C3_TYPES[@]}")
    local devices=$(printf " | %s" "${_ESP_DEVICES[@]}")
    local name=$(basename "$0")
    local help=$(cat << EOF
Usage: %s -[3bcdhprstD] --[c3board,target-branch,config,device,help,wifi-passwd,rewrite-config,target,debug]
    -3 NUM | --c3board NUM              - The version of the que_purple board either %s, defaults to %s.
    -c FILE | --config FILE             - Optional config file, defaults to %s
    -d DEVICE | --device DEVICE         - Can be one of %s defaults to %s.
    -h | --help                         - This screen.
    -p PASSWD | --wifi-passwd PASSWD    - The Password for the SSID.
    -r | --rewrite-config               - Reprompts for entries then rewrites the config file.
    -s SSID | --wifi-ssid SSID          - The WiFi SSID in the current network.
    -t TARGET_DIR | --target TARGET_DIR - The directory where the build will reside, defaults to %s/.quercus.
    -D | --debug                        - Turn on DEBUG mode (propagates to the installit.sh script)..
    -n | --noop                         - The installit.sh script will not run, but the config may still be created.

    I2C pins as follows
    -------------------
      ESP32: SDA 18 SCL 19
    ESP32S2: SDA 1  SCL 0
    ESP32C3: SDA 18 SCL 19 (m80 60 rev) SDA 1 SCL 0 (m80 70 rev)\n\n
EOF
)
    printf "$help" "$name" "${c3[*]:3}" "$_C3BOARD" "$_DEF_CONF" \
           "${devices[*]:3}" "$_DEVICE" "$HOME"
    exit 1
}


#
# Get options
#
# Pass $* as the only argument.
#
function get_opts() {
    local opts="3:b:c:s:p:d:t:Dhrn"
    local long="c3board:,target-branch:,config:,wifi-ssid:,wifi-passwd:,device:,target-dir:,help,debug,rewrite-config,noop"
    local options=$(getopt -o $opts --long $long -- "$@")
    eval set -- "$options"

    while true; do
        #printf "%s\n" "$1"
        case "$1" in
            -c|--config)
                OPT_CONF_FILE=$2
                shift 2
                ;;
            -n|--noop)
                NOOP=1
                shift
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
                REWRITE_CONF=1
                shift
                ;;
            -D|--debug)
                DEBUG=1
                shift
                ;;
            -h|--help)
                help
                ;;
            --)
                shift
                break
                ;;
            *)
                printf "Unknown argument: %s\n" "$1"
                exit 2
                ;;
        esac
    done
}


#
# Get config file
#
function find_config() {
    local path_dir dflag=0
    local paths=("$_ABS_PATH" "$HOME")
    local files=("$OPT_CONF_FILE" "$_DEF_CONF")

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
        _CONF_FULL_PATH="$path_dir"
    fi
}


#
# Read the config file.
#
function read_file() {
    if [ -f "$_CONF_FULL_PATH" ]; then
        source "$_CONF_FULL_PATH"
    fi
}


#
# Ask for arguments and set config args if necessary.
#
function ask_for_args() {
    local tmp files=("$OPT_CONF_FILE" "$_DEF_CONF")
    local save_flag=0

    for file in "${files[@]}"; do
        if [ "$file" != "" ]; then
            _CONF_FULL_PATH="$_ABS_PATH/$file"
            break
        fi

    done

    #debug "" "WIFI_SSID" "X_WIFI_SSID" "REWRITE_CONF"

    if [ "$WIFI_SSID" = "" ] && [ "$X_WIFI_SSID" = "" ] || [ $REWRITE_CONF -eq 1 ]
    then
        save_flag=1

        while true; do
            read -p "Enter WiFi SSID or if exists Default ($X_WIFI_SSID) [Dd]: " tmp

            if [ "${tmp^^}" = "D" ]; then
                if [ "$X_WIFI_SSID" != "" ]; then
                    WIFI_SSID="$X_WIFI_SSID"
                    break
                fi
            elif [ "$tmp" != "" ]; then
                WIFI_SSID="$tmp"
                break
            fi
        done
    elif [ "$X_WIFI_SSID" != "" ]  && [ "$WIFI_SSID" = "" ]; then
        WIFI_SSID="$X_WIFI_SSID"
    fi

    if [ "$WIFI_PASSWD" = "" ] && [ "$X_WIFI_PASSWD" = "" ] || [ $REWRITE_CONF -eq 1 ]
    then
        save_flag=1

        while true; do
            read -p "Enter WiFi passwd or if exists Default ($X_WIFI_PASSWD) [Dd]: " tmp

            if [ "${tmp^^}" = "D" ]; then
                if [ "$X_WIFI_PASSWD" != "" ]; then
                    WIFI_PASSWD="$X_WIFI_PASSWD"
                    break
                fi
            elif [ "$tmp" != "" ]; then
                WIFI_PASSWD="$tmp"
                break
            fi
        done
    elif [ "$X_WIFI_PASSWD" != "" ] && [ "$WIFI_PASSWD" = "" ]; then
        WIFI_PASSWD="$X_WIFI_PASSWD"
    fi

    if [ "$DEVICE" = "" ] && [ "$X_DEVICE" = "" ] || [ $REWRITE_CONF -eq 1 ]
    then
        save_flag=1

        while true; do
            read -p "Enter target device or Default ($X_DEVICE) [Dd]: " tmp

            if [ "${tmp^^}" = "D" ]; then
                if [ "$X_DEVICE" != "" ]; then
                    DEVICE="$X_DEVICE"
                else
                    DEVICE="$_DEVICE"
                fi

                break
            elif [ "$tmp" != "" ]; then
                DEVICE="$tmp"
                break
            fi
        done
    elif [ "$X_DEVICE" != "" ] && [ "$DEVICE" = "" ]; then
        DEVICE="$X_DEVICE"
    fi

    if [ "$DEVICE" = "$_DEVICE" ]; then
        if [ "$C3BOARD" = "" ] && [ "$X_C3BOARD" = "" ] || [ $REWRITE_CONF -eq 1 ]
        then
        save_flag=1

            while true; do
                read -p "Enter C3 board ID or Default ($X_C3BOARD) [Dd]: " tmp

                if [ "${tmp^^}" = "D" ]; then
                    if [ "$X_C3BOARD" != "" ]; then
                        C3BOARD="$X_C3BOARD"
                    else
                        C3BOARD=$_C3BOARD
                    fi

                    break
                elif [ "$tmp" != "" ]; then
                    C3BOARD=$tmp
                    break
                fi
            done
        elif [ "$X_C3BOARD" != "" ] && [ "$C3BOARD" = "" ]; then
            C3BOARD=$X_C3BOARD
        fi
    fi

    if [ "$TARGET_DIR" = "" ] && [ "$X_TARGET_DIR" = "" ] || [ $REWRITE_CONF -eq 1 ]
    then
        save_flag=1

        while true; do
            read -p "Enter target directory or Default ($X_TARGET_DIR) [Dd]: " tmp

            if [ "${tmp^^}" = "D" ]; then
                if [ "$X_TARGET_DIR" != "" ]; then
                    TARGET_DIR="$X_TARGET_DIR"
                else
                    TARGET_DIR="$_IDF_DIR"
                fi

                break
            elif [ "$tmp" != "" ]; then
                TARGET_DIR="$tmp"
                break
            fi
        done
    elif [ "$X_TARGET_DIR" != "" ] && [ "$TARGET_DIR" = "" ]; then
        TARGET_DIR="$X_TARGET_DIR"
    fi

    if [ "$TARGET_BRANCH" = "" ] && [ "$X_TARGET_BRANCH" = "" ] || [ $REWRITE_CONF -eq 1 ]
    then
        save_flag=1

        while true; do
            read -p "Enter target branch or Default ($X_TARGET_BRANCH) [Dd]: " tmp

            if [ "${tmp^^}" = "D" ]; then
                if [ "$X_TARGET_BRANCH" != "" ]; then
                    TARGET_BRANCH="$X_TARGET_BRANCH"
                else
                    TARGET_BRANCH="$_TARGET_BRANCH"
                fi

                break
            elif [ "$tmp" != "" ]; then
                TARGET_BRANCH="$tmp"
                break
            fi
        done
    elif [ "$X_TARGET_BRANCH" != "" ] && [ "$TARGET_BRANCH" = "" ]; then
        TARGET_BRANCH=$X_TARGET_BRANCH
    fi

    if [ "$save_flag" -eq 1 ]; then
        printf "\n"
        printf 'X_WIFI_SSID="%s"\n' "$WIFI_SSID" > "$_CONF_FULL_PATH"
        printf 'X_WIFI_PASSWD="%s"\n' "$WIFI_PASSWD" >> "$_CONF_FULL_PATH"
        printf 'X_DEVICE="%s"\n' "$DEVICE" >> "$_CONF_FULL_PATH"
        [ "$DEVICE" = "$_DEVICE" ] && \
            printf 'X_C3BOARD="%s"\n' $C3BOARD >> "$_CONF_FULL_PATH"
        printf 'X_TARGET_DIR="%s"\n' "$TARGET_DIR" >> "$_CONF_FULL_PATH"
        printf 'X_TARGET_BRANCH="%s"\n' "$TARGET_BRANCH" >> "$_CONF_FULL_PATH"
        printf "The config file %s was saved.\n" "$_CONF_FULL_PATH"
    fi
}


#
# sanity_checks
#
# Check that values from either the command line
# or the config file pass some simple tests.
#
function sanity_checks() {
    if [[ "${_ESP_DEVICES[*]}" != *"$DEVICE"* ]]; then
        local devices=$(printf " | %s" "${_ESP_DEVICES[@]}")
        printf "\nInvalid device must be one of %s, found %s\n\n" \
               "${devices[*]:3}" "$DEVICE"
        help
    fi

    if [ "$C3BOARD" != "" ] && [[ "${_C3_TYPES[*]}" != *"$C3BOARD"* ]]; then
        local c3=$(printf " | %s" "${_C3_TYPES[@]}")
        printf "\nInvalid c3board, must be one of %s, found %s\n\n"\
               "${c3[*]:3}" "$C3BOARD"
        help
    fi
}


#======================#
# Start Execution Here #
#======================#
get_opts $*

debug "Command line arguments" "WIFI_SSID" "WIFI_PASSWD" "DEVICE" \
      "TARGET_DIR" "TARGET_BRANCH" "C3BOARD"

find_config
read_file

debug "Constants or internal variables" "_DEVICE" "_C3BOARD" "_IDF_DIR" \
      "_INSTALLIT" "_CURRENT_DIR" "_ABS_PATH" "_DEF_CONF" "_CONF_FULL_PATH" \
      "HOME" "REWRITE_CONF" "NOOP" "OPT_CONF_FILE"

debug "Config default values, or CLI arguments" "X_WIFI_SSID" "X_WIFI_PASSWD" \
      "X_DEVICE" "X_TARGET_DIR" "X_C3BOARD" "X_TARGET_BRANCH"

ask_for_args
sanity_checks

debug "Final arguments" "WIFI_SSID" "WIFI_PASSWD" "DEVICE" "TARGET_DIR" \
      "TARGET_BRANCH" "C3BOARD"

[ "$NOOP" -eq 0 ] && \
    $(printf "%s %s %s %s %s %s %s %s %s" "$_INSTALLIT" "$WIFI_SSID" \
             "$WIFI_PASSWD" "$DEVICE" "$TARGET_DIR" "$_IDF_DIR" \
             "$TARGET_BRANCH" "$DEBUG" "$C3BOARD")

exit 0
