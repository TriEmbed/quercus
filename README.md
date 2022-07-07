# Triangle Embedded Interest Group (TriEmbed) M80 Standalone ESP32/FPGA Board
![Repo logo](/images/que_m80.png)
## que_m80: Making Dialog Semiconductor mixed signal FPGA chips more accessible

![v0.70 Prototype with FPGA DIP Adapter](/images/v0.70-DIP-adapter.jpg)
![v0.70 Prototype with SMD Adapter](/images/v0.70-SMD-adapter.jpg)

1. A stand alone, easy to use Espressif ESP32 C3-based dev board that can be a programmer for the Dialog SLGxxxxx ICs and also run applications with an onboard SLG47004V-DIP. 
2. Cache of Dialog info resources
   1. Only resources specifically relevant to the board design and application
   2. Local copies of frequently used docs
   3. Additional cookbooks for getting to blinky with Dialog FPGAs 

This project is designed in concert with Nick Edgington's "que_aardvark" node.js web application and "que_ant" ESP32 firmware project in different repositories. The que_ant firmware is designed to allow the ESP32 to directly program a Dialog FPGA without the need for the synthesis tool.

## Project Status

que_m80 versions 0.60 and 0.70 were released and are still in a testing phase. The board silkscreen labels the boards with the name "Aaardvark".

A version 0.80 board is being planned for TBD release with the following changes:
1. Name change to "M80"
2. ECO elimination
3. Updates to reset and boot circuitry
4. Provision for a strap to tie the USB connector down and reduce the chance of broken solder joints.
5. Considering connection of SMD adapter pins to Dialog DIP pins if a compatible set of connections can be worked out. This would allow an SMD part in the adapter to be used for in circuit testing and not just programming.

See the "firedeck" repository for information about the 10x10cm "motherboard" hardware design being planned.

### Release notes

**0.70** ETA 2/11/2022 - Second prototype. Pure superset of 0.60:

1. Set of female headers to accept a Dialog programming adapter. The adapter and the SLG4704V-DIP cannot be on the board at the same time.
2. CH340C USB interface chip that obviates the need for a dongle for programming via USB.
3. User-controlled LED connected to GPIO2 (pin 14?)
4. Reset pushbutton with a 4.7uF cap across it to stretch time it takes enable to return to a high level
5. Aluminum electrolytic cap for regulator output
6. Four position header for connecting ESP32's I2C bus to an outboard Dialog chip for programming. 
7. C3 module firmware creating access point to provide a wireless web interface for uploading and programming a Dialog synthesis file.
8. Shorter and narrower slot for C3 board to fit more tightly
9. Dialog board cannot be plugged in backwards

**0.60 Initial prototype 1/24/2022

1. 3.3v regulated supply with power on LED, 
2. AI Thinker ESP32-C3-M1 single RISCV core + WIFI + Bluetooth
3. Socket for Dialog SLG47004V-DIP for programming purposes and/or to combine with the ESP32 for applications
4. Requires USB to serial logic cable with both RTS and DTR control for programming
5. Designed to work with firmware that makes the system a general purpose Dialog chip programmer

## Bug/Todo/Wish Lists

   Note: Many items become easy when we can go with a MUCH larger board that follows the big rule of providing a generous area for people to put their own circuitry in place in a straight forward manner. But this requires a supplier other than OSH Park for significantly lower cost. Guestimate can switch to cheaper supplier for rev 0.80 assuming no major problems with 0.70. So with this in mind expect the "wish" items to become "todo" with the larger board.
   "*" means fixed/implemented for next release (in next rev Eagle files) 
   "^" means item to be fixed/implemented when board size increased

### Version 0.80 Bug/Todo/wish list.

1. Thorough design review(s)
2. Switch to USB micro connector? This needs group discussion. There is an inexpensive supply of USB mini sockets in hand while getting inexpensive micros is on the wrong side of Chinese New Year. Need to hash this out for version 0.80.
2. Bug: Silkscreen hard to read. Need booth library and board layout changes.
3. Wish: Silkscreen should include SLG47004V-DIP pin labels, not just numbers.
4. Todo: Need pushbutton for boot? 
5. Todo: Provision for additional Dialog chips?
6. Wish: Pet peripheral footprints
7. Bug: No consensus about licensing. 0.70 board has "CC By-SA 2.00" on underside but we need concensus for 0.80 as it will be released to the public unless it requires a lot of bodge wires. 

### Version 0.70 bug/todo list: 

1. Bug: Decoupling/bypass cap for CH340C overlooked: 100nF cap has to be added on top of the USB chip manually as part of assembly.
2. Todo: The reset circuit is incomplete. Have to cut the traces from !DTR (pin 14) and !RTS (pin 13) under the chip them through a pair of NPN resistors to EN and GP9. A boot switch will be added by gluing it to the board.

### Version 0.60 Bug/Todo/wish list.

1. *U G H  B U G: Not clear which way to plug in the SLG47004V-DIP. Plugging it in backwards might be very bad. Make it physically impossible to plug the board in backwards. Arranging for interference with the C3 or other tall part if backwards should make this relatively trivial to do. REMEMBER the board footprint has to be turned 180 degrees to accomplish this. The "long" end of the SLG has to point the other way so the short end can be close to the C3, making it impossible to insert the SLG the wrong way.
2. Bug: No review process for this board version. Could have avoided some mistakes and gotten some ideas for improvement. Let's not send an update to fab without a couple days open for peer review.
3. *Bug: Center to center distance of header pairs off slightly. Need to line up to work well with breadboard. Wish: Consider cutouts to make use of breadboard feasible even when the board is larger such as 10x10cm. Side would be cut out from edge, then have rectangular cutouts along other side for access to the breadboard jumper sites.
4. *Bug: Name on underside of board is misspelled.
5. Bug: No license on silkscreen, only in the Eagle schematic (and that was unilateral: not the will of the FPGA working group.
6. *Bug: Schematic doesn't match build:
    1. Reg output caps 2x68uF but cap used is 100uF
    2. Through hole caps instead of SMD
    3. Pullups not specified resistance

## Parts issues

As of 6/2/2022 most parts are in hand to build about a dozen more que_m80 boards. Notable exception is the pushbutton switches. Hopefully other parts availability improving with the lessening pandemic crisis in China. 


