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
# 2nd parametre = Disk type to check
# Returns True (Exit code 0) if Disk type matches the requested one. False (Exit code 2) if it does not match the requested one.

import parted
import sys
import re

if ((len(sys.argv)-1) != 2 ):
        print 'Usage: ' + sys.argv[0] + ' ' + 'partition_device' + ' ' + 'disktype_to_check'
        print 'E.g.: ' + sys.argv[0] + ' ' + '/dev/sda2' + ' ' + 'gpt'
        sys.exit(1)

disktype_partition_str=sys.argv[1]
disktype_to_check_str=sys.argv[2]

disktype_disk_str=re.sub(r'[0-9]*$', '', disktype_partition_str)

disktype_device = parted.Device(disktype_disk_str,None)
disktype_disk = parted.Disk(disktype_device,None)

disktype_disk_type = disktype_disk.type

if (disktype_disk_type == disktype_to_check_str):
        print disktype_partition_str+ ' disk type is ' + disktype_to_check_str
        sys.exit(0)
else:
        print disktype_partition_str+ ' disk type is not ' + disktype_to_check_str + ' but '+ disktype_disk_type
        sys.exit(2)

