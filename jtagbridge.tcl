#!/opt/intelFPGA_lite/18.1/quartus/bin/quartus_stp -t

#   jtagbridge.tcl - Virtual JTAG proxy for Altera devices

package require Tk
init_tk

source [file dirname [info script]]/DeMiSTify/EightThirtyTwo/tcl/vjtagutil.tcl

####################### Main code ###################################

proc updatedisplay {} {
	global connected
	global portReadCount
	global portErrorCount
	global portErrorBits
	if {$connected} {
		if [ vjtag::usbblaster_open ] {
			for {set idx 0} {$idx<5} {incr idx} {
				vjtag::send [expr (0xfe << 24) + $idx]
				set portReadCount($idx) [vjtag::recv_blocking ]
				set portErrorCount($idx) [vjtag::recv_blocking ]
				set portErrorBits($idx) [format %x [vjtag::recv_blocking]]
				# Resync if the FIFO contains any extraneous data
				vjtag::recv
			}
		}
		vjtag::usbblaster_close
	}
	after 50 updatedisplay
}

proc send_reset {} {
	global connected
	set contmp $connected;
	set connected 0
	if {$contmp} {
		if [ vjtag::usbblaster_open ] {
			vjtag::send [expr (0xff << 24) ]
		}
		vjtag::usbblaster_close
	}
	set connected $contmp
}


proc connect {} {
	global displayConnect
	global connected
	set connected 0

	if { [vjtag::select_instance 0x55aa] < 0} {
		set displayConnect "Connection failed\n"
		set connected 0
	} else {
		set displayConnect "Connected to:\n$::vjtag::usbblaster_name\n$::vjtag::usbblaster_device"
		set connected 1
	}
}


wm state . normal
wm title . "SDRAMStressTest Statistics"

global connected
set connected 0

frame .frmConnection -relief sunken -borderwidth 2 -padx 5 -pady 5
pack .frmConnection -fill both -expand 1

set  displayConnect "Not yet connected\nNo Interface\nNo Device"
label .lblConn -justify left -textvariable displayConnect
button .btnConn -text "Connect..." -command "connect"
button .btnReset -text "Reset" -command "send_reset"

grid .btnConn -in .frmConnection -row 0 -column 0 -padx 5 -sticky ew
grid .btnReset -in .frmConnection -row 1 -column 0 -padx 5 -sticky ew
grid .lblConn -in .frmConnection -row 0 -column 1 -rowspan 2 -padx 5 -pady 5

global portReadCount
global portErrorCount
global portErrorBits

frame .frame -relief sunken -borderwidth 2 -padx 5 -pady 5
pack .frame -fill both -expand yes

for {set idx 0} {$idx<5} {incr idx} {
	grid columnconfigure .frame $idx -weight 1
}

for {set idx 0} {$idx<5} {incr idx} {
	label .lbl($idx) -justify right -text "port $idx reads:"
	set portReadCount($idx) 0
	label .lblReadCount($idx) -justify left -textvariable portReadCount($idx)

	label .lbl1($idx) -justify right -text "errors:"
	set portErrorCount($idx) 0
	label .lblErrorCount($idx) -justify left -textvariable portErrorCount($idx)

	label .lbl2($idx) -justify right -text "error bits:"
	set portErrorBits($idx) 0
	label .lblErrorBits($idx) -justify left -textvariable portErrorBits($idx)

	grid .lbl($idx) -in .frame -row $idx -column 0 -padx 5 -pady 2
	grid .lblReadCount($idx) -in .frame -row $idx -column 1 -padx 5 -pady 2
	grid .lbl1($idx) -in .frame -row $idx -column 2 -padx 5 -pady 2
	grid .lblErrorCount($idx) -in .frame -row $idx -column 3  -padx 5 -pady 2
	grid .lbl2($idx) -in .frame -row $idx -column 4 -padx 5 -pady 2
	grid .lblErrorBits($idx) -in .frame -row $idx -column 5 -padx 5 -pady 2
}

update

connect
updatedisplay
tkwait window .


##################### End Code ########################################

