# Triangle Embedded Interest Group (TriEmbed) Quercus hardware projects
## Purple - Full custom PCB: ESP32C3 + sockets for ForgeFPGA 20 pin DIP board or SMD adapter designed for 830 point solderless breadboard. Reflow soldered except for male header pins.
## White - Combination 830 point solderless breadbord, ESP32 dev board and SLG47004V-DIP FPGA: Just instructions for a do it yourself assembly functionally equivalent to Purple board. No soldering required.
## Green - Future: "Motherboard" for Purple functionality, peripherals, peripheral connectors and large uncommited area. All reflow soldered except optional female headers? 

Purple 1.00 requirements:
1. Mini->micro USB connector
2. Test points to make hand-soldering micro USB connector easier
3. Small JTAG connector
4. Test 0.70 SMD adapter 
5. Bring all 20 SMD adapter pins out to male headers
6. Thoroughly test reset and boot circuits
7. Up the footprint for more silkscreen room and easier hand-soldering 
8. Add DBUS connector
9. Provide conditioned 5v rail, 8 channel I2C compatible level shifter
10. Tesselated C3 module, not the one that fits in a slot. (Still AI-Thinker or Expressif?)
11. Power switch between VBUS and rest of board
12. Conditioned VBUS available as 5V source
13. 500mA supply and not one mA less
14. Supply regulator must not burn finger at max current (finger guard?)
15. Settle on power and user LEDs
16. Jumper to disable user LED
17. Dependency on decent 830 position solderless breadboard or else board is "insert only" and inexperienced people will not be able to get board out of breadboard without breaking a trace, breaking the board, bending pins, yada yada. Recommend Global Specialties or Twin Industries.

