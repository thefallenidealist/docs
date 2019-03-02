# OpenOCD commands and examples

##### Table of Contents  
* [Info](#info)  
* [Hardware connections](#hardware-connections)  
* [Basic usage](#basic-usage)  
* [Flash](#flash)  
	* [Info](#info-1)  
	* [Read](#read)  
	* [Write](#write)  
	* [Misc](#misc)  
* [Debugging](#debugging)  
* [Errors](#errors)  
* [TL;DR](#tldr)  
* [References](#references)  
* [Stuffs](#stuffs)  

## Info
OpenOCD (on-chip debugger) is a program for controlling on-chip debugging hardware.  
It can be used for displaying various information about hardware, upload/download flash, reading/writing HW and/or CPU registers, debugging, and many other interesting things.  
I have used it mostly for uploading/programming program/firmware/application to the MCU (with ST-link original or eBay clone programmer) and debugging (in combination with arm-none-eabi-gdb).  

## Hardware connections
I have used ST-link programmer on various STM32 boards.
Just connect this pins from programmer to the same named pins on the board:
- 3V3 (or 5V0)
- GND
- SWDCLK
- SWDIO

## Basic usage
`openocd -f $PROGRAMMER -f $TARGET -c $COMMAND`  

Example command for STM32F1 board (target):  
`openocd -f interface/stlink-v2.cfg -f target/stm32f1x.cfg -c init -c shutdown`  
Output:  
> ...  
> Info : STLINK v2 JTAG v21 API v2 SWIM v4 VID 0x0483 PID 0x3748  
> Info : using stlink api v2  
> Info : Target voltage: 3.238650  
> Info : stm32f1x.cpu: hardware has 6 breakpoints, 4 watchpoints  
> shutdown command invoked  

List supported interfaces (programmers):  
`ls -1 /usr/local/share/openocd/scripts/interface`  
> ...  
> stlink-v1.cfg  
> stlink-v2-1.cfg 
> stlink-v2.cfg  
> ...  

List supported targets:  
`ls -1 /usr/local/share/openocd/scripts/target`  
> ...  
> stm32f1x_stlink.cfg  
> stm32f1x.cfg  
> ...  

On Linux the previous commands (probably) would be:  
`ls -1 /usr/share/openocd/scripts/{interface,target}`  

Export target for examples:  
`export TARGET=stm32f1x`  
or:  
`export TARGET=stm32f4x`  

## Flash
### Info

#### List flash banks:  
`openocd -f interface/stlink-v2.cfg -f target/$TARGET.cfg -c init -c "reset halt" -c "flash banks" -c shutdown`  
> #0 : stm32f1x.flash (stm32f1x) at 0x08000000, size 0x00000000, buswidth 0, chipwidth 0  

#### Show size and address of flash:  
`openocd -f interface/stlink-v2.cfg -f target/$TARGET.cfg -c init -c "reset halt" -c "flash probe 0" -c shutdown`  
> Info : flash size = 64kbytes  
> flash 'stm32f1x' found at 0x08000000  

#### Show banks and "sectors" (about bank 0):  
`openocd -f interface/stlink-v2.cfg -f target/$TARGET.cfg -c init -c "reset halt" -c "flash info 0" -c shutdown`  
> Info : flash size = 64kbytes  
> #0 : stm32f1x at 0x08000000, size 0x00010000, buswidth 0, chipwidth 0  
>    0: 0x00000000 (0x400 1kB) not protected  
>    1: 0x00000400 (0x400 1kB) not protected  
>    2: 0x00000800 (0x400 1kB) not protected  
>    ...  
>   63: 0x0000fc00 (0x400 1kB) not protected  
> STM32F10x (Medium Density) - Rev: Y  


### Read
#### Dump flash to file (64 kB or 0x10000 bytes):  
`openocd -f interface/stlink-v2.cfg -f target/$TARGET.cfg -c init -c "reset halt" -c "dump_image dump.bin 0x08000000 0x10000" -c shutdown`  
> ...  
> xPSR: 0x01000000 pc: 0x080017a4 msp: 0x20005000  
> dumped 65536 bytes in 1.280808s (49.968 KiB/s)  
> shutdown command invoked  

**INFO** dump command won't work on my only STM32F103C8T6 board with 128 kB of flash  


#### Show value of 10 WORDs starting at memory location (mdw - memory display word):  
`openocd -f interface/stlink-v2.cfg -f target/$TARGET.cfg -c init -c "reset halt" -c "mdw 0x08000000 10" -c "reset run" -c shutdown`  
> 0x08000000: 20020000 08001f03 08001edb 08001eed 08001edb 08001edb 08001edb 00000000  
> 0x08000020: 00000000 00000000 

#### Show value of 10 HALFWORDs at memory location (mdh - memory display halfword):  
`openocd -f interface/stlink-v2.cfg -f target/$TARGET.cfg -c init -c "reset halt" -c "mdh 0x08000000 10" -c "reset run" -c shutdown`  
> 0x08000000: 0000 2002 1f03 0800 1edb 0800 1eed 0800 1edb 0800  

#### Show value of 10 BTYES at memory location (mdb - memory display byte):  
`openocd -f interface/stlink-v2.cfg -f target/$TARGET.cfg -c init -c "reset halt" -c "mdb 0x08000000 10" -c "reset run" -c shutdown`  
> 0x08000000: 00 00 02 20 03 1f 00 08 db 1e  


##### Example of little endian memory organization:  
- MSB is byte1
- LSB is byte4 - stored at lowest address

width | addr0 ... addr3              | example                    |
-----:|:----------------------------:|:--------------------------:|
u32   | \| b1b2b3b4 \|               | \| 08001f03 \|             |
u16   | \| b3b4 \| b1b2 \|           | \| 1f03 \| 0800 \|         |
 u8   | \| b4 \| b3 \| b2 \| b1 \|   | \| 03 \| 1f \| 00 \| 08 \| |

LE: writes LSB at lowest address ("backwards")  

### Write

#### Write image:  
`openocd -f interface/stlink-v2.cfg -f target/$TARGET.cfg -c init -c "reset halt" -c "flash write_image erase obj/rustSTM32.elf" -c "reset run" -c shutdown`  

#### Write hex image:  
`openocd -f interface/stlink-v2.cfg -f target/$TARGET.cfg -c init -c "reset halt" -c "flash write_image erase obj/rustSTM32.hex" -c "reset run" -c shutdown`  

#### Write bin image:  
**XXX** Doesn't work:  
`openocd -f interface/stlink-v2.cfg -f target/$TARGET.cfg -c init -c "reset halt" -c "flash write_image erase obj/rustSTM32.bin" -c "reset run" -c shutdown`  
> Warn : no flash bank found for address 0  
> wrote 0 bytes from file obj/rustSTM32.bin in 0.001493s (0.000 KiB/s)  

`openocd -f interface/stlink-v2.cfg -f target/$TARGET.cfg -c init -c "reset halt" -c "flash write_image erase obj/rustSTM32.bin 0x08000000" -c "reset run" -c shutdown`  
> xPSR: 0x61000000 pc: 0x20000046 msp: 0x2001ff30  
> Warn : no flash bank found for address 8100000  
> wrote 1048576 bytes from file obj/rustSTM32.bin in 25.935211s (39.483 KiB/s)  

But it will flash binary file to the MCU

`ls -lh obj/rustSTM32.bin`  
> -rwxr-xr-x  1 johnny  johnny   384M Jul 18 06:45 obj/rustSTM32.bin  



#### Erase whole flash bank:
`openocd -f interface/stlink-v2.cfg -f target/$TARGET.cfg -c init -c "reset halt" -c "$TARGET mass_erase 0" -c shutdown`  

#### Write 128 byte pattern "0xAB" to flash address 0x08000000:
`openocd -f interface/stlink-v2.cfg -f target/$TARGET.cfg -c init -c "reset halt" -c "flash fillb 0x08000000 0xAB 128" -c shutdown`  

### Misc
#### Unlock flash sector:  
`openocd -f interface/stlink-v2.cfg -f target/$TARGET.cfg -c init -c "reset halt" -c "$TARGET unlock 0" -c shutdown`  

#### Show CPU and debug registers:  
`openocd -f interface/stlink-v2.cfg -f target/$TARGET.cfg -c init  -c "reg" -c shutdown`  
> ...  
> (13) sp (/32): 0x20005000  
> (14) lr (/32): 0xFFFFFFFF  
> (15) pc (/32): 0x080017A4  
> (16) xPSR (/32): 0x01000000  
> (17) msp (/32): 0x20005000  
> (18) psp (/32): 0xBCB23F98  
> (19) primask (/1): 0x00  
> (20) basepri (/8): 0x00  
> (21) faultmask (/1): 0x00  
> (22) control (/2): 0x00  
> ...  

#### Verify:  
**TODO** 170731:  
Verify doesn't work on my STM32F4 (OpenOCD will try to checksum RAM or some weird address)  
`openocd -f interface/stlink-v2.cfg -f target/$TARGET.cfg -c init -c "reset halt" -c "program obj/rustSTM32.elf verify reset 0 exit"`  
> Error: checksum mismatch - attempting binary compare  
> diff 0 address 0x20000000. Was 0x02 instead of 0x43  
> ...  

### Debugging:
- open new shell and:  
`openocd -f interface/stlink-v2.cfg -f target/$TARGET.cfg -c init -c  "reset halt"`  
in new shell open arm-none-eabi-gdb (or another appropriate GDB):  
 `target remote localhost:3333`  
 `monitor reset halt`  
- another way:  
`arm-none-eabi-gdb --eval-command="target remote | openocd --file interface/stlink-v2.cfg --file target/$TARGET.cfg --command \"gdb_port pipe; init\"" obj/rustSTM32.elf`  

### Errors:
> Warn : UNEXPECTED idcode: 0x2ba01477
> Error: expected 1 of 1: 0x1ba01477
=> Wrong target, eg: STM32F1x instead STM32F4x


### TL;DR
Most frequently used commands  
  
#### Program:  
`openocd -f interface/stlink-v2.cfg -f target/$TARGET.cfg -c init -c "reset halt" -c "flash write_image erase obj/rustSTM32.elf" -c "reset run" -c shutdown`  
- Overkill:  
`openocd -f interface/stlink-v2.cfg -f target/$TARGET.cfg -c init -c targets -c "reset halt" -c "flash protect 0 0 11 off" -c "flash erase_address 0x08000000 0x40000" -c "flash write_image erase obj/rustSTM32.hex 0 ihex" -c "reset run" -c "shutdown"`

#### Debugging with GDB:  
`arm-none-eabi-gdb --eval-command="target remote | openocd --file interface/stlink-v2.cfg --file target/$TARGET.cfg --command \"gdb_port pipe; init\"" obj/rustSTM32.elf`  

#### Erase (write 0xFF)
`openocd -f interface/stlink-v2.cfg -f target/$TARGET.cfg -c init -c "reset halt" -c "$TARGET mass_erase 0" -c shutdown`  

#### Dump image from the MCU (size = 0x10k = 64kB):  
`openocd -f interface/stlink-v2.cfg -f target/$TARGET.cfg -c init -c "reset halt" -c "dump_image dump.bin 0x08000000 0x10000" -c "reset run" -c shutdown`  

## References
- https://en.wikipedia.org/wiki/In-circuit_emulation#On-chip_debugging
- http://openocd.org/doc/html/Flash-Commands.html
- http://openocd.org/doc/html/General-Commands.html

## Stuffs
created 170719  
Song of choice: [Cadaver Disposal - Transformatio Mundi](https://www.youtube.com/watch?v=VUX8wC9I80g)

program versions:  
- `openocd -v`  
Open On-Chip Debugger 0.10.0  
