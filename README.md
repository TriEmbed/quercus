# Quercus (NOTE: Project name will change soon)
Quercus is a standalone system for developing for and using the combination of
a WIFI-capable ESP32 and one or more Renesas/Dialog mixed signal FPGA
chips. The FPGA synthesis tool has a drag and drop GUI that involves zero
Verilog or VHDL. It has a built in simulator and generates files that Quercus
can program in place in the user's system for simple FPGA applications. These
FPGAs are around one to two dollars in single quantity, even ones mounted on a
DIP board that can plug into a wireless breadboard. Quercus is aimed at making
FPGAs available to "the rest of us" while also creating a development ecosystem
to augment the Espressif IDF and Arduino IDE.

## User group
The user group kickoff meeting was held on 8/31/2022. Video here: https://youtu.be/zqejgwW3aIo

## Installation

### Linux

The first thing that should be done is run the script below with it's help
screen as such:

```
$ ./linux_install.sh --help
Usage: linux_install.sh -[3bcdhprstD] --[c3board,target-branch,config,device,help,wifi-passwd,rewrite-config,target,debug]
    -3 NUM | --c3board NUM              - The version of the que_purple board either 60 | 70, defaults to 70.
    -c FILE | --config FILE             - Optional config file, defaults to .quercusrc
    -d DEVICE | --device DEVICE         - Can be one of ESP32 | ESP32C3 | ESP32S2 defaults to ESP32C3.
    -h | --help                         - This screen.
    -p PASSWD | --wifi-passwd PASSWD    - The Password for the SSID.
    -r | --rewrite-config               - Reprompts for entries then rewrites the config file.
    -s SSID | --wifi-ssid SSID          - The WiFi SSID in the current network.
    -t TARGET_DIR | --target TARGET_DIR - The directory where the build will reside, defaults to /home/cnobile/.quercus.
    -D | --debug                        - Turn on DEBUG mode (propagates to the installit.sh script)..
    -n | --noop                         - The installit.sh script will not run, but the config may still be created.

    I2C pins as follows
    -------------------
      ESP32: SDA 18 SCL 19
    ESP32S2: SDA 1 SCL 0
    ESP32C3: SDA 18 SCL 19 (m80 60 rev) SDA 1 SCL 0 (m80 70 rev)
```

The ```linux_install.sh``` script can be run in multiple ways which will be
reviewed below. This script has the ability to create and use a config
file. The config file ```.quercusrc``` can be located in either the base of the
Quercus directory or in your person user directory. The script will find it in
either place but will favor the Quercus directory.

1. To create a config file run the script with no arguments on the first
   run. If you need to rewrite the config file use the ```-r``` or 
   ```--rewrite-config``` argument.

   ```bash
   $ ./linux_install.sh
   ```
   or
   ```bash
   $ ./linux_install.sh -r
   ```
   The generated config file will always be put in the base of the Quercus
   repository, if you want it in your user home directory you will need to
   manually move it there. The ```linux_install.sh``` script will find it as
   long as there isn't a config file in the Quercus directory.

2. You can also use a config file with a different name as shown below. This
   can allow you to have a config for many different physical environments. You
   must add the ```-r``` argument if you already have a ```.quercusrc``` file.

   ```bash
   $ ./linux_install.sh -rc my_my.conf
   ```
   Just enter the filename **not** the full path as it will not be found. Once
   again it will be put into the base of the Quercus repository. It is
   advisable to move any of your own files to your user directory so it cannot
   be accidentally committed to the repository.

3. In all the cases above the script will run to completion after writing the
   config file. If you just want to write out the config file add a ```-n``` to
   the command line as below.

    ```bash
    $ ./linux_install.sh -n
   ```
   This can be used with any other arguments. For example the ```-r``` argument
   so you can rewrite the config but not run the rest of the script.

4. You can also turn on debugging which can be used with any other arguments.

   ```bash
   $ ./linux_install.sh -nD
   ```
   Assuming there is already a config file the above will just print out all
   the variable names and their values if any then exit. If you do not have a
   config file it will prompt for all values that are required and write then
   to the config file.

All the remaining arguments are used to override what is in the config file and
will not be saved to the config file. As such you can use them to override any
or all arguments that are in the config file.




### Windows
