# Flashing BlackMagic firmware on ST-link programmer

##### Table of Contents  
* [Needed](#needed)  
* [Hardware](#hardware)  
* [Software](#software)  
  * [Building](#building)  
  * [Binary releases](#binary-releases)  
* [Flashing](#flashing)  
* [References](#references)  
* [Stuffs](#stuffs)  

## Needed
**Hardware:**
- programmer - ST-link programmer (or UART and changing BOOT0 jumper)  
- STM32 board with 128 kB of flash or ST-link programmer as a victim which will be disasembled and flashed  

**Software:**
- OpenOCD
- dfu-util
- arm-none-eabi-gcc (for building)
- git
- Unix tools
- ...

## Hardware
**Hardware connections when programming the programmer:**

programmer	|	victim programmer
------------|-------------
3.3V		|	3.3V
GND			|	GND
SWDIO		|	JTMS (PA13 - phy pad: 34)
SWDCLK		|	JTCK (PA14 - phy pad: 37)

PA13 and PA14 are internal pads (located below STM32F101C8T6) inside the programmer (the one with black housing).  
Pinout of that internal pads (in my case) is:
1. PA13 - JTMS, physical pin 34 (internal data)	- closest to the USB port
2. GND
3. PA14 - JTCK, physical pin 37 (internal clock)
4. 3.3V - closest to the ISP port (2x5 header)  

Pinout of added header from front side on my programmer (thanks to Burga for soldering):
1. Data - JTMS (PA13)
2. GND
3. Clock - JTCK (PA14)
4. 3.3V

That internal pins must be connected to the programmer, otherwise programmer won't see the device.  
My (cheap eBay clone for $2-3) programmer have STM32F101C8T6 (with 128 kB of flash), not STM32F103C8T6 MCU.

**hardware connections when programming the dev board (with 128 or more kB of flash):**  

programmer	|	dev board
------------|-------------
3.3V		|	3.3V
GND			|	GND
SWDIO		|	SWDIO
SWDCLK		|	SWDCLK

**INFO:** Cheap eBay boards with STM32F103C8T6 won't work (at least none of my boards worked) - they have 64 kB of flash which is too small for newer BlackMagic firmware


## Software
### Building

Fetch the source:  
`git clone https://github.com/blacksphere/blackmagic`  
`cd blackmagic`  
`git submodule init`
`git submodule update`

#### Building on Linux machine:
`make clean`  
`make -j4`  
`cd src`  
`make clean`  
`make -j4 PROBE_HOST=stlink`  
  

#### Building on FreeBSD machine:
Tested on FreeBSD 11.1-PRERELEASE  
  
`sed -i '' 's/#!\/usr\/bin\/env\ python$/#!\/usr\/bin\/env\ python2/g' libopencm3/scripts/irq2nvic_h`  
make will fail with this message:  
"/usr/local/bin/arm-none-eabi-ld: cannot find -lc_nano"  
That means that it can't find a newlib nano.  
FreeBSD newlib pkg doesn't have a nano version:  
`pkg info -l arm-none-eabi-newlib-2.4.0 | grep nano`  

download newlib nano from the net, for example:  
http://launchpadlibrarian.net/300667138/libnewlib-arm-none-eabi_2.4.0.20160527-2_all.deb  
`ar -x ${DOWNLOAD_FOLDER}/libnewlib*deb`  
`tar xvJf data.tar.xz`  
`cp usr/lib/arm-none-eabi/newlib /tmp`  
Now we have libc_nano:  
`find /tmp/newlib -name libc_nano.a`  
`/tmp/newlib/armv6-m/libc_nano.a`  
`/tmp/newlib/libc_nano.a`  
`/tmp/newlib/armv7-m/libc_nano.a`  
`/tmp/newlib/fpu/libc_nano.a`  
`/tmp/newlib/armv7e-m/libc_nano.a`  
`/tmp/newlib/armv7e-m/softfp/fpv5-sp-d16/libc_nano.a`  
`/tmp/newlib/armv7e-m/softfp/fpv5-d16/libc_nano.a`  
`/tmp/newlib/armv7e-m/softfp/libc_nano.a`  
`/tmp/newlib/armv7e-m/fpu/fpv5-sp-d16/libc_nano.a`  
`/tmp/newlib/armv7e-m/fpu/libc_nano.a`  
`/tmp/newlib/armv7e-m/fpu/fpv5-d16/libc_nano.a`  
`/tmp/newlib/thumb/libc_nano.a`  

Patch the Makefile so it can find the newlib nano:  
`sed -i '' 's/-L..\/libopencm3\/lib/-L..\/libopencm3\/lib\ -L\/tmp\/newlib/' src/platforms/stlink/Makefile.inc`  
<!-- `sed -i '' 's/LDFLAGS_BOOT := $(LDFLAGS) --specs=nano.specs \\/LDFLAGS_BOOT := $(LDFLAGS) \\/' src/platforms/stlink/Makefile.inc`   -->
`gmake clean`  
`gmake -j4`  
`cd src`  
`gmake clean`  
`gmake -j4 PROBE_HOST=stlink`  

**XXX** firmware built on FreeBSD doesn't work, I don't know why (maybe size related?), use binary release, or build on Linux machine  
FreeBSD: wrote 8192 bytes from file blackmagic_dfu.bin in 0.501548s (15.951 KiB/s)  
Linux:   wrote 7168 bytes from file blackmagic_dfu.bin in 0.454049s (15.417 KiB/s)  


  

### Binary releases
Files are from 2016.08.11.
- https://embdev.net/articles/File:Blackmagic_dfu-v1.6-rc0-213-gdf7ad91.bin
- https://embdev.net/articles/File:Blackmagic-v1.6-rc0-213-gdf7ad91.bin  

Compiled under Linux, version 7663794fdfb586f77d4b755600069ad4f1a0bdeb from 2017.07.25.
- https://github.com/thefallenidealist/files/blob/master/blackmagic%20firmware/Linux/blackmagic_dfu.bin
- https://github.com/thefallenidealist/files/blob/master/blackmagic%20firmware/Linux/blackmagic.bin

## Flashing
1. Connect wires as described in [Hardware](#hardware)  

2. Erase the flash (optional):  
`openocd -f interface/stlink-v2.cfg -f target/stm32f1x.cfg -c "init" -c "halt" -c "stm32f1x mass_erase 0" -c "shutdown"`  

3. Unlock the flash:  
`openocd -f interface/stlink-v2.cfg -f target/stm32f1x.cfg -c init -c "reset halt" -c "$TARGET unlock 0" -c shutdown`


4. Flash DFU file with OpenOCD:  
`openocd -f interface/stlink-v2.cfg -f target/stm32f1x.cfg -c init -c "reset halt" -c "program blackmagic_dfu.bin 0x08000000 verify" -c "reset run" -c "shutdown"`  
- example output:  
...  
Info : flash size = 128kbytes  
target halted due to breakpoint, current mode: Thread  
xPSR: 0x61000000 pc: 0x2000003a msp: 0x20005000  
wrote 7168 bytes from file blackmagic_dfu.bin in 0.447168s (15.654 KiB/s)  
** Programming Finished **  
** Verify Started **  
target halted due to breakpoint, current mode: Thread  
xPSR: 0x61000000 pc: 0x2000002e msp: 0x20005000  
verified 6880 bytes in 0.115740s (58.050 KiB/s)  
** Verified OK **  
shutdown command invoked  


3. Disconnect the programmer and connect other side (victim programmer or board) to the USB  

4. Check if it is recognized:  
`dfu-util -l`  

- In my case the output is:  
`Found DFU: [1d50:6017] ver=0100, devnum=6, cfg=1, intf=0, path="", alt=0, name="@Internal Flash   /0x08000000/8*001Ka,120*001Kg", serial="DDB5A7DF"`  

5. Flash the rest with dfu-util:  
`dfu-util -a 0 -s 0x08002000:leave:force -D blackmagic.bin`  
- if there is more than one DFU capable device, device address must be specified:  
`dfu-util -d 1d50:6017 -a 0 -s 0x08002000:leave:force -D blackmagic.bin`  
- Example output:  
DfuSe interface name: "Internal Flash   "  
Downloading to address = 0x08002000, size = 58780  
Download        [=========================] 100%        58780 bytes  
Download done.  
File downloaded successfully  
dfu-util: Error during download get_status  

6. Find if device is recognized:  
`dfu-util -l`  
`Found Runtime: [1d50:6018] ver=0100, devnum=6, cfg=1, intf=4, path="", alt=0, name="Black Magic Firmware Upgrade (STLINK)", serial="DDB5A7DF"`  

- Find the serial device (under FreeBSD) - the last two should be the blackmagic programmer and UART:  
`ls -ltr /dev/cuaU*`  
In my case there are cuaU3 and cuaU4 devices. The first one is BlackMagic probe, the second is UART.  

- or check /var/log/messages (or how it is called today on Linux) or dmesg:  
Jul 27 23:30:01 innovator kernel: ugen0.6: <Black Sphere Technologies Black Magic Probe STLINK, Firmware v1.6.1-50-g7663794> at usbus0  
Jul 27 23:30:01 innovator kernel: umodem3 on uhub2  
Jul 27 23:30:01 innovator kernel: umodem3: <Black Magic GDB Server> on usbus0  
Jul 27 23:30:01 innovator kernel: umodem3: data interface 1, has no CM over data, has no break  
Jul 27 23:30:01 innovator kernel: umodem4 on uhub2  
Jul 27 23:30:01 innovator kernel: umodem4: <Black Magic UART Port> on usbus0  
Jul 27 23:30:01 innovator kernel: umodem4: data interface 3, has no CM over data, has no break  
Jul 27 23:30:01 innovator root: Unknown USB device: vendor 0x1d50 product 0x6018 bus uhub2  

7. Check it with GDB:  
- HW connections with board:  
  - STM32F1 board/programmer: connect HW (SWDIO->SWDIO, SWDCLK->SWDCLK)  
  - STM32F4 board: disconnect onboard ST-link jumpers, SWDIO->PA13, SWDCLK->PA14  
- `arm-none-eabi-gdb somefile.elf`  
  - `target extended-remote /dev/cuaU3`  
  - `monitor version`  
Black Magic Probe (Firmware v1.6.1-50-g7663794) (Hardware Version 1)  
  - `mon swdp_scan`  
  Target voltage: unknown  
  Available Targets:  
  No. Att Driver  
   1      STM32F4xx  
  - `attach 1`
  - `continue`

## References
- https://embdev.net/articles/STM_Discovery_as_Black_Magic_Probe#Building_Firmware_for_ST_Link_V2_Clones_and_Flash_Using_Two_Cheap_Clones


## Stuffs
Created on 170719  
Song of choice: Kreator - Gods of Violence  

program versions:  
- `openocd -v`  
Open On-Chip Debugger 0.10.0  
-  `dfu-util -V`  
dfu-util 0.9  
- `arm-none-eabi-gcc -v`  
gcc version 6.3.0 (FreeBSD Ports Collection for armnoneeabi)
- blackmagic source:  
pulled on 2017.07.25., last hash:  
`git rev-parse --short HEAD`  
7663794  
- `gmake -v`  
GNU Make 4.2.1  
Built for amd64-portbld-freebsd11.0  
- `GDB >>> monitor version`  
Black Magic Probe (Firmware v1.6.1-50-g7663794) (Hardware Version 1)  
Copyright (C) 2015  Black Sphere Technologies Ltd.  
