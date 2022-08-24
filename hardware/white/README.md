# white dev board
The "white board" is a Quercus hardware that can be made with off the shelf parts: an ESP32 dev board described below and a SLG47004V-DIP on a long (830 point) solderless breadboard. 
![This is an image](https://white-with-LEDs.jpg)

Here is a suitable ESP32 "WROOM" board:

https://smile.amazon.com/gp/product/B08MFCC4SR/ref=ppx_yo_dt_b_search_asin_title?ie=UTF8&psc=1

File "esp32pinout.odt" in this directory shows the TOP VIEW of the pins. The lable "CONN" is in the position of the board's USB micro connector.

File "board-top-view.jpg" in this directory shows a top view of the board with wire connections for the "BLINKY" application.

File "SLG47004V_DIP_Proto_Board_Quick_Start_Guide.pdf" shows a diagram of the FPGA DIP board. Note well that while "Pin 1 (vcc)" is in position 1 of the 20 position DIP connector most (possibly) all other pins have labels that DO NOT reflect their connector positions. One must look at the actual connector pin position using the red or blue connection line to orient a connection.

