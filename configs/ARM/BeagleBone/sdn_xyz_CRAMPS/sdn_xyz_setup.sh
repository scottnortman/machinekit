#!/bin/bash
################################################################################
#	File:	sdn_xyz_setup.sh
#	Desc:	bash script to define error functions and initialize IO for the 
#			3 axis xyz prototype system using the CRAMPS BeagleBone cape.
#	Auth:	Original authors below; modified by scott.nortman@gmail.com
#	Date:	Jan. 2019
################################################################################

# Copyright 2013
# Charles Steinkuehler <charles@steinkuehler.net>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA


dtbo_err () {
	echo "Error loading device tree overlay file: $DTBO" >&2
	exit 1
}

pin_err () {
	echo "Error exporting pin:$PIN" >&2
	exit 1
}

dir_err () {
	echo "Error setting direction:$DIR on pin:$PIN" >&2
	exit 1
}

PRU=/sys/class/uio/uio0
echo -n "Waiting for $PRU "

while [ ! -r $PRU ]
do
    echo -n "."
    sleep 1
done
echo OK

if [ ! -r $PRU ] ; then
	echo PRU control files not found in $PRU >&2
	exit 1;
fi


# Export GPIO pins:
# One pin needs to be exported to enable the low-level clocks for the GPIO
# modules (there is probably a better way to do this)
# 
# Any GPIO pins driven by the PRU need to have their direction set properly
# here.  The PRU does not do any setup of the GPIO, it just yanks on the
# pins and assumes you have the output enables configured already
# 
# Direct PRU inputs and outputs do not need to be configured here, the pin
# mux setup (which is handled by the device tree overlay) should be all
# the setup needed.
# 
# Any GPIO pins driven by the hal_bb_gpio driver do not need to be
# configured here.  The hal_bb_gpio module handles setting the output
# enable bits properly.  These pins _can_ however be set here without
# causing problems.  You may wish to do this for documentation or to make
# sure the pin starts with a known value as soon as possible.


# Instead of loading an explicit *.bbio file, we are creating one here 'on the fly'

sudo $(which config-pin) -f - <<- EOF

	P9.23	low		# Machine Power control output, output_pins=923
	
	P9.25	low		# LED control, output_pins =>925

	# ESTOP IO
	P8.17	in		# ESTOP input from external switch, input_pins=817
	P8.26	high	# ESTOP_SW Output, output_pins=826

	# Global Axis enable, shared for all axes
	P9.14	high	# Axis Enable, active low, output_pins=914

	# Note:  The min and max limits are configured as N.C. to HI,
	#	therefore when asserted, they are open, and there is a
	#	pull down resistor so they are LO TRUE.  This way, if the
	#	cable fails, it is safe

	# X AXIS PINS
	P8.07	in_pd	# X Max, input_pins=> 807
	P8.08	in_pd	# X Min, input_pins=> 808
	P8.12	low		# X Dir, Direction from stepgen => 812
	P8.13	low		# X Step, Step from stepgen => 813

	# Y AXIS PINS
	P8.09	in_pd	# Y Max, input_pins=> 809
	P8.10	in_pd	# Y Min, input_pins=> 810
	P8.14	low		# Y Dir, Direction from stepgen => 814
	P8.15	low		# Y Step, Step from stepgen => 815

	# Z AXIS PINS
	P9.11	in_pd	# Z Max, input_pins=> 911
	P9.13	in_pd	# Z Min, input_pins=> 913
	P8.18	low		# Z Dir, Direction from stepgen => 818
	P8.19	low		# Z Step, Step from stepgen => 819

	# A AXIS, E0 extruder (Not required, leave as default)
	P9.12	low		# E0 Dir, Direction from stepgen => 912
	P9.16	low		# E0 Step, step from stepgen => 916

	# B AXIS, E1 extruder (Not required, leave as default)
	P9.18	low		# E1 Dir, Direction from stepgen => 918
	P9.17	low		# E1 Step, step from stepgen => 917

	# C AXIS, E2 extruder (Not required, leave as default)
	P9.26	low		# E2 Dir, Direction from stepgen => 926
	P9.24	low		# E2 Step, step from stepgen => 924


	# FET 1 (Not required, set to default)
	P8.11	low		# FET 1 : Heated Bed, PWM direct from PRU => 811
	P9.15	low 	# FET 2 : E0
	P9.27	low		# FET 3 : E2
	P9.21	low		# FET 4 : E1
	P9.41	low		# FET 5
	P9.22	low		# FET 6

	P9.91	in	# Reserved, connected to P9.41

	P8.16	high	# eMMC Enable
	
# eMMC signals, uncomment *ONLY* if you have disabled the on-board eMMC!
# MachineKit images disable eMMC and HDMI audio by default in uEnv.txt:
#  capemgr.disable_partno=BB-BONELT-HDMI,BB-BONE-EMMC-2G
	P8.22	low	# Servo 4
	P8.23	low	# Servo 3
	P8.24	low	# Servo 2
	P8.25	low	# Servo 1

#	P9.19	low	# I2C SCL
#	P9.20	low	# I2C SDA

	P9.28	low	# SPI CS0
	P9.29	low	# SPI MISO
	P9.30	low	# SPI MOSI
	P9.31	low	# SPI SCLK

#	P9.42	low	# SPI CS1
	P9.92	in	# Reserved, connected to P9.42
EOF

