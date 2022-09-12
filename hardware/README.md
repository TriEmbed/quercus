# Triangle Embedded Interest Group (TriEmbed) Quercus hardware projects
## Purple - Full custom PCB: ESP32C3 + sockets for ForgeFPGA 20 pin DIP board or SMD adapter designed for 830 point solderless breadboard. Reflow soldered except for male header pins.
## White - Combination 830 point solderless breadbord, ESP32 dev board and SLG47004V-DIP FPGA: Just instructions for a do it yourself assembly functionally equivalent to Purple board. No soldering required.
## Green - Future: "Motherboard" for Purple functionality, peripherals, peripheral connectors and large uncommited area. All reflow soldered except optional female headers? 

Purple TODO:
1. Mini->micro USB connector
2. Test points to make hand-soldering micro USB connector easier
3. Small JTAG connector
4. Test SMD adapter
5. Bring all 20 SMD adapter pins out to male headers
6. Thoroughly test reset and boot switches
7. Up the footprint as much as possible for more silkscreen room and easier hand-soldering (But with funding and an assembler such as Macrofab hand soldering is made moot)
8. Add DBUS connector
9. Provide conditioned 5v rail, 8 chalnel I2C compatible level shifte

