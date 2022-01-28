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

Version 0.60 

0. B U G: Not clear which way to plug in the SLG47004V-DIP. Plugging it in backwards might be very bad. Ideally next design should make it physically impossible to plug the board in backwards. Arranging for interference with the C3 should make this relatively trivial.
1. Bug: No review process for this board version. Could have avoided some mistakes and gotten some ideas for improvement. Let's not send an update to fab without a couple days open for peer review.
2. Bug: Center to center distance of header pairs off slightly
3. Bug: Silkscreen hard to read
4. ECO: Silkscreen should include SLG47004V-DIP pin labels, but this means changing to different board form factor.
5. ECO: header for the I2C and power/ground for programming some Dialog elsewhere like in some other circuit
6. Bug: Probably need to follow best practices and pull regulator output caps up closer to the regulator.
7. Bug: Switch to USB micro connector as some have already tossed their collection of mini cables!
8. Bug: VERY difficult to decide which way to plug in the SLG47004V-DIP.
9. Need to understand the consequences of putting the SLG47004V-DIP in backwards.
10. Bug: Name on underside of board is misspelled.
11. Bug: No license on silkscreen, only in the Eagle schematic (and that was unilateral: not the will of the FPGA Leage (working group)
12. Bug: Schematic doesn't match build:
    1. Reg output caps 2x68uF but cap used is 100uF
    2. Through hole caps instead of SMD
13. Bug: Need pushbutton to GP8 to support serial boot mode. Other details to do with serial boot being worked out.
14. Bug: Need push button that grounds both enable and GP8 to reset.
15. Bug: Need to tie EN up with pullup
16. TODO: Need a minimum of two push buttons and maybe three: reset, go into bootloader mode and ??
17. TODO: Need a four position header for I2C connection so the board can be more conveniently used as a progammer.
18. TODO: Need three header pins to conveniently connect a USB to serial dongle.
19. BUG: Another bug: Need an updated C3 Eagle library. At a minimum change DP4 to GP4 and put the schematic inside a box. Ideal would be to have nine things on each side corresponding to the mini C3 module's connections. That is, make the schematic look like the C3 module as much as possible.
20. Todo issue: There are two special Eagle CAD lib components to get into the repo. First is the above C3 module and second is a lib component for the Dialog SLG47004V-DIP
21. TODO: Need a minimum of two push buttons. One to ground EN and GPIO8 to do a reset and the other to ground GPIO2 and GPIO0 to enter bootloader mode. Or that's the current theory.
22. TODO: Need a four position header for I2C connection so the board can be more conveniently used as a progammer.
23. TODO: Need some header pins to conveniently connect a USB to serial dongle. "Some" is probably four or five, as RTS must be controllable and possibly DTR too. This takes a special dongle. :-(
24. Provision for Dialog programming sockets?
25. Make C3 pins accessible via breadboard? 
26. Add a 1-10uF cap from EN to ground for more reliable reset behavior.

(Tentative decision to stick with USB mini connector for now. Micro is a pain to solder: trying to stick to easy hand soldering. Micro requires ridiculously fine soldering iron tip, mini could probably be done with the smallest Hakko tip available without too much trouble.)

Parts not in hand

1. Mini USB connectors (should be in hand 1/29. Harvested one off another board for first prototype)
2. SMD caps (should be in hand 2/1. Kludged aluminum caps in place for first prototype)

