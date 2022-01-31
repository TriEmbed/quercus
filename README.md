# Triangle Embedded Interest Group (TriEmbed)
## Aardvark: Making Dialog Semiconductor mixed signal FPGA chips more accessible:
1. A stand alone, easy to use Espressif ESP32 C3-based dev board that can be used as a programmer for the Dialog SLGxxxxx ICs or to run applications with an onboard SLG47004V-DIP. 
2. Additional accessibility tools like breakout boards such as the Dialog SLG47004V-DIP.
3. Cache of Dialog info resources
   1. Pointers to Dialog web resources
   2. Local copies of frequently used docs
   3. Additional cookbooks for getting to blinky with Dialog FPGAs 

Release notes:
 0.60 1/18/2022 - Initial prototype. Bare bones requiring USB to serial logic cable for initial programming and an absolute minimum of features beyond eventual support for programming a plugged in SLG47004V-DIP

BUGS and ECO requests (could be grouped: don't need 20+ repo issues)

Version 0.60 Bug/Todo/wish list.

   Note: Many items become easy when we can go with a MUCH larger board that follows the big rule of providing a generous area for people to put their own circuitry in place in a straight forward manner. But this requires a supplier other than OSH Park for significantly lower cost. Guestimate can switch to cheaper supplier for rev 0.8x or 0.9x. So with this in mind expect the "wish" items to become "todo" with the larger board.
   "*" means fixed/implemented for post-0.60 release (in next rev Eagle files) 
   "^" means item to be fixed/implemented when board size increased

0. U G H  B U G: Not clear which way to plug in the SLG47004V-DIP. Plugging it in backwards might be very bad. Make it physically impossible to plug the board in backwards. Arranging for interference with the C3 or other tall part if backwards should make this relatively trivial to do.
1. Bug: No review process for this board version. Could have avoided some mistakes and gotten some ideas for improvement. Let's not send an update to fab without a couple days open for peer review.
2. Bug: Center to center distance of header pairs off slightly. Need to line up to work well with breadboard. Wish: Consider cutouts to make use of breadboard feasible even when the board is larger such as 10x10cm. Side would be cut out from edge, then have rectangular cutouts along other side for access to the breadboard jumper sites.
3. ^Bug: Silkscreen hard to read
4. ^Wish: Silkscreen should include SLG47004V-DIP pin labels, not just numbers.
5. ^Todo: Add header for the I2C and power/ground for programming some Dialog elsewhere like in some other circuit. Put a four position JST PH on one side of board as well as four position header.
7. Todo: Switch to USB micro connector as some have already tossed their collection of mini cables!
8. *Bug: Name on underside of board is misspelled.
9. Bug: No license on silkscreen, only in the Eagle schematic (and that was unilateral: not the will of the FPGA working group.
10. *Bug: Schematic doesn't match build:
    1. Reg output caps 2x68uF but cap used is 100uF
    2. Through hole caps instead of SMD
    3. Pullups not specified resistance
11. ^Todo: Need pushbuttons for reset and boot.
12. Bug: Need to tie EN up with pullup? Conflicting docs about this.
13. Bug: Need to pull GPIO9 up. Be sure to document this as it creates constraints on use of the pin.
14. Todo: The C3 slot is both too long and two wide. Measure width with microscope but only narrow it one wee skoshin. Use C3 dev board with C3 removed as a model.
15. Todo: Need an updated C3 Eagle library. At a minimum change DP4 to GP4 and put the schematic inside a box. Ideal would be to have nine things on each side corresponding to the mini C3 module's connections. That is, make the schematic look like the C3 module as much as possible.
16. Todo: There are two special Eagle CAD lib components to get into the repo. First is the above C3 module and second is a lib component for the Dialog SLG47004V-DIP.
17. Todo: Need a minimum of two push buttons. One to ground EN and GPIO8 to do a reset and the other to ground GPIO2 and GPIO0 to enter bootloader mode. Or that's the current theory.
18. Todo: Need a four position header for I2C connection so the board can be more conveniently used as a progammer.
19. ^Todo: Provision for one Dialog programming socket.
20. ^Todo: Provision for additional Dialog chips?
21. *Todo: Add a 4.7uF cap from EN to ground for reliable reset behavior.
22. Todo: Consult Kevin about regulator decoupling. May need Tantulum or aluminimum electrolytics for LM1117 regulator. Placement of output cap seems too far away.
23. Todo: Add USB slave chip to make it straight forward to flash C3. Using USB to serial dongle may not be onerous but inappropriate for target users.

Parts not in hand

1. SMD caps (should be in hand 2/1. Kludged aluminum caps in place for first prototype)
2. USB chip

