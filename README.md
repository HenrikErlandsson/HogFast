# HogFast
Reduces memory of beefy Amigas accurately for running demos made for the Amiga 500 OCS 1MB platform.

## Requirements
Amiga 500, or any Amiga with a RAM expansion or accelerator with RAM mappable to Slowmem a.k.a. $C0 or Ranger RAM. Examples are Kipper or Individual Computers expansions.

## Software description
Amiga CLI utility executable.

## Problem that the software solves
Allows to run the entirety of demos released for the platform on any Amiga, with regards to limiting Slowmem. Also works for games, or any type of software intending to push the limits of said platform. With persistence, so that you can have your Amiga always on, and not reboot unless the demo or game does not exit, or does not exit cleanly.

It also allows you to toggle Slowmem completely off, so that you can target or run OCS 512k platform software at whim. It will always turn off all other types of non-Chipmem permanently. It will not limit Chipmem in any way, as there are some file systems vs harddisk controllers that can "HogChip".

## Purpose
Enjoying and testing software on real hardware or in WinUAE from harddisk, without first having to write disks or disk images to get the correct environment.

## Usage
HogFast once will allocate all Fastmem plus all slowmem but what's left from an optimal 1.3 bootblock to CLI.

Thereafter, HogFast will alternately allocate all slowmem and restore the above accurate amount of slowmem.

This allows to have an Amiga always-on and continuously receive demos, CLI-compatible games, or your latest build infinitely and *without reboot*, until the software you run prevents exit or exits uncleanly.

## Notes
This release is not part of the AmiLiveFloppy project, but connected to it in the following ways:
1. A harddisk environment will never be able to maximize Chipmem without fragmenting it (since SpaceBoot cannot be used as a harddisk bootblock), so you must then fragment your chipmem SECTIONs in your exe. Again, HogFast does not affect Chipmem. If you intend pushing the platform and make a harddisk release, HogFast is accurate, whether or not you decide to fragment your chipmem sections to provide a harddisk release and still maximize memory limits for OCS 1MB.
2. HogFast can temporarily be put on an AmiLiveFloppy with a SpaceBoot bootblock, if you wish to not fragment chipmem, and will then also be accurate.
3. HogFast works on OS1.3 to 3.1. It likely also works on 1.2 and versions released after 3.1 but not tested. The exact accuracy will therefore differ with essentially the Kickstart version. On 1.3, the accuracy is estimated between 0KB and -4KB on the first 3 executions of HogFast, and will then settle a little to provide slightly better accuracy. I.e. if you are pushing every byte, then HogFast is not quite a perfect replacement for an Amiga and a disk image with SpaceBoot. (Other AmiLiveFloppy component not necessary.)
4. If you are preparing a release floppy with a mix of executables, for example a so-called Packdisk, where some require a 0.5MB Slowmem environment and some require all non-Chipmem off, you can install SpaceBoot (to replace "Add21k" or similar on the disk), then add HogFast to the floppy and call it from your menu for the individual executables to run correctly, without patching them.
