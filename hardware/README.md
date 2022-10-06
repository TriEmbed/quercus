# Triangle Embedded Interest Group (TriEmbed) Quercus hardware projects
## Purple - Full custom PCB: ESP32C3 + sockets for ForgeFPGA 20 pin DIP board or SMD adapter designed for 830 point solderless breadboard. Reflow soldered except for male header pins. Uses a Renesas 46585 or similar ForgeFPGA for voltage regulation (and perhaps sequencing)
## White - Combination 830 point solderless breadbord, ESP32 dev board and SLG47004V-DIP FPGA: Just instructions for a do it yourself assembly functionally equivalent to Purple board. No soldering required.
## Green - Future: "Motherboard" for Purple functionality, peripherals, peripheral connectors and large uncommited area. All reflow soldered except optional female headers? 

Purple 1.00 requirements:
1. Mini->C USB connector if the support parts for C not onerous. NOTE that the board to host USB connection has to be to >= USB rev X to get more than 500mA (vanilla 3 or greater?)
2. Test points to make hand-soldering USB connector easier (MADE MOOT by the presence of a QFN on the board: very few people can hand solder the board if it has a fine-pitch QFN)
3. Small JTAG connector for use with ESP-PROG or the like P L U S separate USB-micro socket for the USB serial JTAG interface to the C3. It isn't clear yet (and would make a wonderful issue for somebody to research) whether or not there is any advantage to the board having the two flavors of JTAG interface. For more details see here: https://docs.espressif.com/projects/esp-idf/en/latest/esp32c3/api-guides/jtag-debugging/index.html
5. Test 0.70 SMD adapter 
6. Bring all 20 SMD adapter pins out to male headers
7. Thoroughly test reset and boot circuits with 0.70 + breadboard parts (i.e. partially depopulate and tie bodge wires to male header pins on breadboard)
8. Widen the board for more silkscreen room. Just one row of breadboard positions
NO: we will not do this initially 8. Add Digilent Pmod (AMP MODUL MTE) eight position I2C connector. No support for 6/12pos Pmod connectors, only I2C for now.
9. Provide conditioned 5v rail, (4, 8?) channel I2C compatible level shifter. This will further lengthen the board
10. Tesselated C3 module, not the one that fits in a slot. (Still AI-Thinker or Expressif? Dawn?)
11. Power switch between VBUS and rest of board
12. Conditioned VBUS available as 5V source
13. 500mA supply for ESP32 or more if its datasheet calls for it as worst case and we have USB C with its higher current support. 
14. Supply regulator must not burn finger at max current (finger guard?). Made moot by use of ForgeFPGA regulator circuit (watch the current loop design!)
15. Settle on power and user LEDs
NO: we will not do this as the tesselated module has beaucoup pins 16. Jumper to disable user LED
17. Dependency on decent 830 position solderless breadboard or else board is "insert only" and inexperienced people will not be able to get board out of breadboard without breaking a trace, breaking the board, bending pins, etc. Recommend Global Specialties or Twin Industries. This is a simple fact of life because of the large number of pins. You get what you pay for. We should be careful about provenance wrt breadboards we source.

