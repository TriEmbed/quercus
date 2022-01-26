# Triangle Embedded Interest Group (TriEmbed)
## Aardvark: Making Dialog Semiconductor mixed signal FPGA chips more accessible:
1. A stand alone, easy to use programmer for the SLGxxxxx ICs leveraging the Espressif ESP C3 RISCV module and special chip sockets
2. Additional accessibility tools like breakout boards such as the Dialog SLG47004V-DIP.
3. Cache of Dialog info resources
   1. Pointers to Dialog web resources
   2. Local copies of frequently used docs
   3. Additional cookbooks for getting to blinky with Dialog FPGAs 

Release notes:
 0.60 1/18/2022 - Initial prototype. Bare bones requiring USB to serial logic cable for initial programming and an absolute minimum of features beyond eventual support for programming a plugged in SLG47004V-DIP

BUGS and ECO requests
 0.60 
1. Bug: Name on underside of board is misspelled.
2. Bug: Center to center distance of header pairs off slightly
3. Bug: Silkscreen hard to read
4. ECO: Silkscreen should include SLG47004V-DIP pin labels, but this means changing to different board form factor.
5. ECO: header for the I2C and power/ground for programming some Dialog elsewhere like in some other circuit
6. Bug: Probably need to follow best practices and pull regulator output caps up closer to the regulator.
7. Bug: Switch to USB micro connector as some have already tossed their collection of mini cables!
8. Bug: VERY difficult to decide which way to plug in the SLG47004V-DIP.
9. Need to understand the consequences of putting the SLG47004V-DIP in backwards.
