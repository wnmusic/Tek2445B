# Tek2445B
utils of maintaining Tek 2445B oscilloscope 

## FPGA
Use ICEStick as the NVRAM programmer, the 24 IO from the board to be connected to a DS1225 or FM1808 chip. 

## Data
`orignal.bin` is the orignal dumped data from my 2445B, it has a parity error and CRC error. The parity error is @ addres 6B. 
`modify.bin` is the arbitrarily modify the 6B calibration data and make the scope recalc the CRC. It is not clear what is the CRC algorirhtm for this device. This should be replaced by re-calibrate the scope, but I don't have all the tools now and it is too expensive. 

