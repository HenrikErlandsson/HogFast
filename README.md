# HogFast
Reduces memory of beefy Amigas accurately for running demos made for the Amiga 500 OCS 1MB platform.

Allows to run the entirety of demos released for the platform on any Amiga, with regards to limiting $C0 a.k.a. Slowmem or Ranger RAM. Also works for games, or any type of software intending to push the limits of said platform.

It persists your setting, so that you can have your Amiga always on, and not reboot unless the demo or game does not exit, or does not exit cleanly.

This also allows you to toggle Slowmem completely off, so that you can target or run OCS 512k platform software. It will always turn off all other types of non-Chipmem permanently. It will not limit Chipmem in any way, as there are some file systems vs harddisk controllers that can "HogChip".

##Purpose
Enjoying and testing on real hardware, without having to write disks or disk images (i.e. run from harddisk).

## Usage
HogFast once will allocate all Fastmem plus all slowmem but what's left from an optimal 1.3 bootblock to CLI.

Thereafter, HogFast will alternately allocate all slowmem and restore just enough slowmem to meet above spec.

This allows to have an Amiga always-on and continuously receive demos, CLI-compatible games, or your latest build infinitely and *without reboot*, until the software you run prevents exit or exits uncleanly.
