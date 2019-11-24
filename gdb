# 190910
# dump memory to file
dump [format] memory filename start_addr end_addr
dump binary memory file1 0x08000000 0x08010000
# write file to memory
restore filename [binary] bias start end
restore random64 binary 0x08000000
# Restoring binary file random64 into memory (0x8000000 to 0x8010000)
# Writing to flash memory forbidden in this context


# BMP + GDB
-> info mem
Using memory regions provided by the target.
Num Enb Low Addr   High Addr  Attrs
0   y   0x08000000 0x08020000 flash blocksize 0x400 nocache
1   y   0x20000000 0x20005000 rw nocache

-> load
Loading section .text, size 0x164c8 lma 0x8002000
Error writing data to flash
