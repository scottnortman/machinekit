#!/usr/bin/python

import sys
import os
import subprocess
import importlib
from machinekit import launcher
from time import *

launcher.register_exit_handler()
launcher.set_debug_level( 5 )
os.chdir( os.path.dirname( os.path.realpath( __file__ ) ) )

try :
    launcher.check_installation()
    launcher.cleanup_session()
    launcher.start_process( "configserver -n SDN_XYZ /home/machinekit/git/Cetus" )
    launcher.start_process( 'machinekit /home/machinekit/git/machinekit/configs/ARM/BeagleBone/sdn_xyz_CRAMPS/sdn_xyz_CRAMPS.ini' )
except subprocess.CalledProcessError:
    launcher.end_session()
    sys.exit( 1 )


#loop until exit signal received
while True:
    sleep( 1 )
    launcher.check_processes()


