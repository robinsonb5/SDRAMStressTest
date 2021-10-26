# SDRAM Stress Test

This is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

SDRAMStressTest is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with the SDRAMStressTest.  If not, see <https://www.gnu.org/licenses/>.

## What does it do?
The SDRAM Stress Test is designed to give an SDRAM chip a heavy workout, using the multi-port SDRAM controller from the TurboGrafx16 core.
The tester performs a pseudo-random series of writes to RAM on each port simultaneously, then reads back the same series of addresses from each port, comparing the data received.

## Why?
Because the existing memory tester on MiSTer - which has been ported to other platforms - only takes the SDRAM for a gentle stroll, with no bank interleaving and thus any problems with crosstalk or power delivery to the module don't manifest.  This test makes use of bank interleaving, meaning addresses are crossing the bus at the same time as data, banks are being precharged at the same time as data is being sent or received, and the chip is generally working a lot harder.

## Limitations
The MiSTer memory modules in common use share the DQM pins with the upper two address bits.  This prevents taking full advantage of bank interleaving - and in fact the memory controller used in this core will only work with such modules in CL2 mode.  Since most chips can't do CL at more than 100MHz, that's the realistic maximum speed for this tester on MiSTer or other boards using the same modules.
On boards which don't have this limitation, the tester can run in CL3 mode, as fast as the chips will allow.
In order to have some compatibility with both types of memory, this tester doesn't make use of burst mode.

