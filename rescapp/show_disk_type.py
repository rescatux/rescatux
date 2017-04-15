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

# 1st parametre = Disk device
# Returns True (Exit code 0) if disk can be found. False (Exit code 2) if it is not found.

import parted
import sys
import re

if ((len(sys.argv)-1) != 1 ):
        print 'Usage: ' + sys.argv[0] + ' ' + 'disk_device'
        print 'E.g.: ' + sys.argv[0] + ' ' + '/dev/sda'
        sys.exit(1)

disk_str=sys.argv[1]

device = parted.Device(disk_str,None)
disk = parted.Disk(device,None)



if (disk is not None):
        disk_type=disk.type
        print disk_type
        sys.exit(0)
else:
        sys.exit(2)


