#!/usr/bin/env python
# Rescapp main script
# Copyright (C) 2016, 2017 Adrian Gibanel Lopez
#
# Rescapp is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Rescapp is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Rescapp.  If not, see <http://www.gnu.org/licenses/>.

# 1st parametre = Partition device

# Shows partition flags separated by commas
# Returns True (Exit code 0) if any flag is found. False (Exit code 2) if no flag is found.

import parted
import _ped
import sys
import re

flags_to_check = [ 'boot', 'bios_grub', 'root', 'swap', 'hidden', 'raid', 'lvm', 'lba', 'hp-service', 'palo', 'prep', 'msftres', 'msftdata', 'atvrecv', 'diag', 'legacy_boot', 'irst', 'esp' ]


if ((len(sys.argv)-1) != 1 ):
        print 'Usage: ' + sys.argv[0] + ' ' + 'partition_device'
        print 'E.g.: ' + sys.argv[0] + ' ' + '/dev/sda2'
        sys.exit(1)

flag_partition_str=sys.argv[1]

flag_disk_str=re.sub(r'[0-9]*$', '', flag_partition_str)

flag_device = parted.Device(flag_disk_str,None)
flag_disk = parted.Disk(flag_device,None)
flag_partition = flag_disk.getPartitionByPath(flag_partition_str)

any_flag_found = False
flags_output=''

for nflag in flags_to_check:

  flag_to_check = _ped.partition_flag_get_by_name(nflag)

  if (flag_partition.getFlag(flag_to_check)):
    if not any_flag_found:
      flags_output = nflag
      any_flag_found = True
    else:
      flags_output = flags_output + ',' + nflag


if any_flag_found:
  print flags_output
  sys.exit(0)
else:
  sys.exit(2)