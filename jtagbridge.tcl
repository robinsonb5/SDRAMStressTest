#!/opt/intelFPGA_lite/18.1/quartus/bin/quartus_stp -t

#   jtagbridge.tcl - Virtual JTAG proxy for Altera devices

global vjtag_instance

package require Tk
init_tk

source [file dirname [info script]]/DeMiSTify/EightThirtyTwo/tcl/vjtagutil.tcl

####################### Main code ###################################

proc updatedisplay {} {
	global connected
	global portReadCount
	global portErrorCount
	global portErrorBits
	global vjtag_instance
	if {$connected} {
		if [ usbblaster_open $vjtag_instance ] {
			for {set idx 0} {$idx<5} {incr idx} {
				vjtag_send $vjtag_instance $idx
				set portReadCount($idx) [vjtag_recv_blocking $vjtag_instance]
				set portErrorCount($idx) [vjtag_recv_blocking $vjtag_instance]
				set portErrorBits($idx) [format %x [vjtag_recv_blocking $vjtag_instance]]
			}
		}
		usbblaster_close $vjtag_instance
	}
	after 50 updatedisplay
}

proc send_reset {} {
	global connected
	global vjtag_instance
	set contmp $connected;
	set connected 0
	if {$contmp} {
		if [ usbblaster_open $vjtag_instance ] {
			vjtag_send $vjtag_instance 255
		}
		usbblaster_close $vjtag_instance
	}
	set connected $contmp
}

proc connect_jtag { id } {
	global usbblaster_name
	global usbblaster_device
	global vjtag_instance
	global displayConnect
	global connected

	if { [count_instances $id] > 1 } {
		set vjtag_instance [usbblaster_findinstance $id [select_instance $id]]
	} else {
		set vjtag_instance [usbblaster_findinstance $id 0]
	}
	
	if {$vjtag_instance<0} {
		set displayConnect "Connection failed\n"
		set connected 0
	} else {
		set displayConnect "Connected to:\n$usbblaster_name\n$usbblaster_device"
		set connected 1
	}
}


proc count_instances { id } {
	set instancecount 0
	while { [usbblaster_findinstance $id $instancecount] >-1} {
		incr instancecount
	}
	return $instancecount
}


proc select_instance { id } {
	global usbblaster_name
	global usbblaster_device
	global connected
	global select_instance_idx
	set connected 0

	toplevel .dlg
	wm state .dlg normal
	wm title .dlg "Connect to..."

	listbox .dlg.lb -selectmode single -width 78
	grid .dlg.lb -in .dlg -row 1 -column 1 -sticky ew -padx 5 -pady 2

	set idx 0
	set instance [usbblaster_findinstance $id $idx]
	while {$instance>-1} {
		.dlg.lb insert $idx "$usbblaster_name / $usbblaster_device / $instance"
		incr idx
		set instance [usbblaster_findinstance $id $idx]
	}
	set select_instance_idx 0
	bind .dlg.lb {<<ListboxSelect>>}  {global select_instance_idx; set select_instance_idx [.dlg.lb curselection]}
	button .dlg.bt -text "Connect" -command [puts [.dlg.lb curselection]; list destroy .dlg]
	grid .dlg.bt -in .dlg -row 2 -column 1 -sticky ew -padx 5 -pady 2

	tkwait window .dlg
	return $select_instance_idx
}

# Find the USB Blaster
puts "found [count_instances 0x55aa ] instances"

wm state . normal
wm title . "SDRAMStressTest Statistics"

global connected
set connected 0

# Connect button
set  displayConnect "Not yet connected\nNo Interface\nNo Device"
frame .frmConnection
grid .frmConnection -in .  -row 1 -column 1

button .btnConn -text "Connect..." -command "set connected 0; connect_jtag 0x55aa"
grid .btnConn -in .frmConnection -row 1 -column 1 -padx 5 -sticky ew

button .btnReset -text "Reset" -command "send_reset"
grid .btnReset -in .frmConnection -row 2 -column 1 -padx 5 -sticky ew

label .lblConn -justify left -textvariable displayConnect
grid .lblConn -in .frmConnection -row 1 -column 2 -columnspan 5 -rowspan 2 -padx 5 -pady 5

global portReadCount
global portErrorCount
global portErrorBits

for {set idx 0} {$idx<5} {incr idx} {
	label .lbl($idx) -justify right -text "port $idx reads:"
	grid .lbl($idx) -in .frmConnection -row [expr $idx + 3] -column 1 -padx 5 -pady 2

	set portReadCount($idx) 0
	label .lblReadCount($idx) -justify left -textvariable portReadCount($idx)
	grid .lblReadCount($idx) -in .frmConnection -row [expr $idx + 3] -column 2 -padx 5 -pady 2

	label .lbl1($idx) -justify right -text "errors:"
	grid .lbl1($idx) -in .frmConnection -row [expr $idx + 3] -column 3 -padx 5 -pady 2

	set portErrorCount($idx) 0
	label .lblErrorCount($idx) -justify left -textvariable portErrorCount($idx)
	grid .lblErrorCount($idx) -in .frmConnection -row [expr $idx + 3] -column 4  -padx 5 -pady 2

	label .lbl2($idx) -justify right -text "error bits:"
	grid .lbl2($idx) -in .frmConnection -row [expr $idx + 3] -column 5 -padx 5 -pady 2

	set portErrorBits($idx) 0
	label .lblErrorBits($idx) -justify left -textvariable portErrorBits($idx)
	grid .lblErrorBits($idx) -in .frmConnection -row [expr $idx + 3] -column 6 -padx 5 -pady 2
}

update

# connect_jtag 0x55aa
updatedisplay
tkwait window .


#puts "\nType 'q' then enter to quit.  Type 'r' then enter to reset (not yet reliable)"
#puts "\n\n\n\n\n"

#puts "\x1b\[?25l"
#puts "\x1b\[7B"
#gets stdin keystrokes
#while {$keystrokes != "q" } {
#	gets stdin keystrokes
#	if [ usbblaster_open $vjtag_instance ] {
#		puts "\x1b\[7A"
#		for {set i 0} {$i<5} {incr i} {
#			vjtag_send $vjtag_instance $i
#			set reads [vjtag_recv_blocking $vjtag_instance]
#			set errors [vjtag_recv_blocking $vjtag_instance]
#			set errbits [format %x [vjtag_recv_blocking $vjtag_instance]]
#			puts "\x1b\[Kport $i\treads: $reads\terrors: $errors\terror bits: $errbits"
#		}
#		if {$keystrokes != ""} {
#			while { [vjtag_recv $vjtag_instance]>=0 } { }
#			if {$keystrokes == "r"} {
#				vjtag_send $vjtag_instance 255
#			}
#
#			puts "\x1b\[2A"
#		}
#		puts "\x1b\[K"
#		while { [vjtag_recv $vjtag_instance]>=0 } { }
#		usbblaster_close $vjtag_instance
#	}
#}
#puts "\x1b\[?25h"

##################### End Code ########################################

