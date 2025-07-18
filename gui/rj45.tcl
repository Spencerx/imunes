#
# Copyright 2005-2013 University of Zagreb.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
# This work was supported in part by Croatian Ministry of Science
# and Technology through the research contract #IP-2003-143.
#

# $Id: rj45.tcl 130 2015-02-24 09:52:19Z valter $


#****h* imunes/rj45.tcl
# NAME
#  rj45.tcl -- defines rj45 specific procedures
# FUNCTION
#  This module is used to define all the rj45 specific procedures.
# NOTES
#  Procedures in this module start with the keyword rj45 and
#  end with function specific part that is the same for all the
#  node types that work on the same layer.
#****

set MODULE rj45

#****f* rj45.tcl/rj45.toolbarIconDescr
# NAME
#   rj45.toolbarIconDescr -- toolbar icon description
# SYNOPSIS
#   rj45.toolbarIconDescr
# FUNCTION
#   Returns this module's toolbar icon description.
# RESULT
#   * descr -- string describing the toolbar icon
#****
proc $MODULE.toolbarIconDescr {} {
	return "Add new External interface"
}

proc $MODULE._confNewIfc { node_id ifc } {
	global node_cfg

	set node_cfg [_setIfcName $node_cfg $ifc "UNASSIGNED"]
}

#****f* rj45.tcl/rj45.icon
# NAME
#   rj45.icon -- icon
# SYNOPSIS
#   rj45.icon $size
# FUNCTION
#   Returns path to node icon, depending on the specified size.
# INPUTS
#   * size -- "normal", "small" or "toolbar"
# RESULT
#   * path -- path to icon
#****
proc $MODULE.icon { size } {
	global ROOTDIR LIBDIR

	switch $size {
		normal {
			return $ROOTDIR/$LIBDIR/icons/normal/rj45.gif
		}
		small {
			return $ROOTDIR/$LIBDIR/icons/small/rj45.gif
		}
		toolbar {
			return $ROOTDIR/$LIBDIR/icons/tiny/rj45.gif
		}
	}
}

proc $MODULE.notebookDimensions { wi } {
	set h 160
	set w 100

	return [list $h $w]
}

#****f* rj45.tcl/rj45.configGUI
# NAME
#   rj45.configGUI -- configuration GUI
# SYNOPSIS
#   rj45.configGUI $c $node_id
# FUNCTION
#   Defines the structure of the rj45 configuration window by calling
#   procedures for creating and organising the window, as well as procedures
#   for adding certain modules to that window.
# INPUTS
#   * c -- tk canvas
#   * node_id -- node id
#****
proc $MODULE.configGUI { c node_id } {
	global wi
	#
	#guielements - the list of modules contained in the configuration window
	#		(each element represents the name of the procedure which creates
	#		that module)
	#
	#treecolumns - the list of columns in the interfaces tree (each element
	#		consists of the column id and the column name)
	#
	global guielements treecolumns
	global node_cfg node_existing_mac node_existing_ipv4 node_existing_ipv6

	set guielements {}
	set treecolumns {}
	set node_cfg [cfgGet "nodes" $node_id]
	set node_existing_mac [getFromRunning "mac_used_list"]
	set node_existing_ipv4 [getFromRunning "ipv4_used_list"]
	set node_existing_ipv6 [getFromRunning "ipv6_used_list"]

	configGUI_createConfigPopupWin $c
	wm title $wi "rj45 configuration"

	configGUI_nodeName $wi $node_id "Node name:"
	set tabs [configGUI_addNotebookRj45 $wi $node_id [lsort [_ifcList $node_cfg]]]

	configGUI_nodeRestart $wi $node_id
	configGUI_buttonsACNode $wi $node_id
}
