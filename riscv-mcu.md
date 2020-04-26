# RISC-V MCU 

TL;DR: Not worh it, I will never buy anything from Seed studio.

I have tried it multiple times to upload it to official site without sucess (from multiple PCs). Service desk was contacted but they told me that they didn't get any reviews so I am posting it here as a warning for others.

## Board review
Be very aware of shipping prices! Board is not as cheap as it sounds, not even close!
DHL is eeeexpensive and slow (at least in my country) - after 3 days it was in my country, but I got board 13 days after that - DHL express indeed!
DHL will respond very slowly to mails (and won't answer all the questions) or none at all (I have contacted 3 persons)
I have ordered 4 boards and 2 JTAGs and in the end cost was: $34 for hardware, $26 for shipping, $34 again to DHL. Oh, and more than 2 weeks of various mails to DHL.

Housing is not worth it and pretty useless - way to wide wholes for USB C connector, top and bottom halves never actually close - there is always a gap between.

Good things:
- open source RISC-V CPU :)
- 3 colored LEDs on board
- USB C connector
- LCD on board
- microSD on board
- it can be flashed without JTAG - board has USB DFU
It is neat little board with open source CPU and MCU peripherals in style of proven STM32 MCUs :)

Board quality looks nice and mini IPS display looks beatiful. Default LCD demo ("bad apple") is a nice showcase what this board can do (but it can be picky with SD cards).
SW setup is very easy - there is already prebuilt toolchain (GCC, binutils and newlib) which can be used with PlatformIO or without it - you can easly use it with build system which you prefer.  Documentation is availabe on english and there is firmware library. Setuping this board to blinky and UART with custom build system was a breeze.

If you can ignore all DHL situation, all lost nerves money and days in shipping, it is still fun board to play with.

## JTAG debugger review
TL;DR: Bought 2, only one works as JTAG, other not. Both have working UART part.

You need first to debug debugger (if it is working) then you can (maybe) debug board.
There is no tutorial, no schematic of this little thing. You will need working debugger, patched OpenOCD binary and special .cfg files for the debugger.

Neat that it has UART included - one USB port and you have debugger and UART buuuuut, no - There is no VCC so you need to power your board on some other way (probably another USB port) - not ideal.
On mine housing fall off even before I connected it to anything! Not nice. It even can't be put back - it will again fall off :(
Housing has printed pinout so it is nice - in case it doesn't fall off. Also both hausing have some mini hole which doesn't do anything useful and quality is not the best.

On the other working debugger one of GND pins is somehow half one inside case so you can't connect anything to it.
On non-working I tried to reflow pins - still doesn't work.

No LEDs to be found - it would be nice to have 2 colored LEDs for debugger (something like ST link) and 2 LEDs for UART TX and RX.

Debugger has 2x5 connector for connecting something like old AVR programmer cables, but they don't give you cable with connector.  But they at least give you some dupoint cables.

Bought it because it:
- So I can easy debug my RISC-V board without fiddling with debugger
- wasn't expensive compared to other FTDI boards (well, it was, because you will pay monstrous shipping)
- has a housing
- looked as neat way to connect to board
In the end all that things were false :(

It could be much better if:
- works
- housing doesn't fall off
- has Vcc so you don't need to connect another USB just for power
- has 2 status LEDs for debugger
- has 2 status LEDs for UART
- has premade ribbon cable with connector to just connect it to the RISC-V MCU board
