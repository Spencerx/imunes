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
registerModule $MODULE

################################################################################
########################### CONFIGURATION PROCEDURES ###########################
################################################################################

#****f* rj45.tcl/rj45.confNewNode
# NAME
#   rj45.confNewNode -- configure new node
# SYNOPSIS
#   rj45.confNewNode $node_id
# FUNCTION
#   Configures new node with the specified id.
# INPUTS
#   * node_id -- node id
#****
proc $MODULE.confNewNode { node_id } {
	global nodeNamingBase

	setNodeName $node_id [getNewNodeNameType rj45 $nodeNamingBase(rj45)]
}

#****f* rj45.tcl/rj45.confNewIfc
# NAME
#   rj45.confNewIfc -- configure new interface
# SYNOPSIS
#   rj45.confNewIfc $node_id $ifc
# FUNCTION
#   Configures new interface for the specified node.
# INPUTS
#   * node_id -- node id
#   * ifc -- interface name
#****
proc $MODULE.confNewIfc { node_id ifc } {
}

proc $MODULE.generateConfigIfaces { node_id ifaces } {
}

proc $MODULE.generateUnconfigIfaces { node_id ifaces } {
}

proc $MODULE.generateConfig { node_id } {
}

proc $MODULE.generateUnconfig { node_id } {
}

#****f* rj45.tcl/rj45.ifacePrefix
# NAME
#   rj45.ifacePrefix -- interface name prefix
# SYNOPSIS
#   rj45.ifacePrefix
# FUNCTION
#   Returns rj45 interface name prefix.
# RESULT
#   * name -- name prefix string
#****
proc $MODULE.ifacePrefix {} {
	return "x"
}

#****f* rj45.tcl/rj45.netlayer
# NAME
#   rj45.netlayer -- layer
# SYNOPSIS
#   set layer [rj45.netlayer]
# FUNCTION
#   Returns the layer on which the rj45 operates, i.e. returns LINK.
# RESULT
#   * layer -- set to LINK
#****
proc $MODULE.netlayer {} {
	return LINK
}

#****f* rj45.tcl/rj45.virtlayer
# NAME
#   rj45.virtlayer -- virtual layer
# SYNOPSIS
#   set layer [rj45.virtlayer]
# FUNCTION
#   Returns the layer on which the rj45 node is instantiated,
#   i.e. returns NATIVE.
# RESULT
#   * layer -- set to NATIVE
#****
proc $MODULE.virtlayer {} {
	return NATIVE
}

#****f* rj45.tcl/rj45.nghook
# NAME
#   rj45.nghook
# SYNOPSIS
#   rj45.nghook $eid $node_id $iface_id
# FUNCTION
#   Returns the id of the netgraph node and the netgraph hook name. In this
#   case netgraph node name correspondes to the name of the physical interface.
# INPUTS
#   * eid -- experiment id
#   * node_id -- node id
#   * iface_id -- interface id
# RESULT
#   * nghook -- the list containing netgraph node name and
#     the netraph hook name (in this case: lower).
#****
proc $MODULE.nghook { eid node_id iface_id } {
	set iface_name [getIfcName $node_id $iface_id]
	set vlan [getIfcVlanTag $node_id $iface_id]
	if { $vlan != "" && [getIfcVlanDev $node_id $iface_id] != "" } {
		set iface_name ${iface_name}_$vlan
	}

	return [list $iface_name lower]
}

################################################################################
############################ INSTANTIATE PROCEDURES ############################
################################################################################

#****f* rj45.tcl/rj45.prepareSystem
# NAME
#   rj45.prepareSystem -- prepare system
# SYNOPSIS
#   rj45.prepareSystem
# FUNCTION
#   Loads ng_ether into the kernel.
#****
proc $MODULE.prepareSystem {} {
	catch { exec kldload ng_ether }
}

#****f* rj45.tcl/rj45.nodeCreate
# NAME
#   rj45.nodeCreate -- instantiate
# SYNOPSIS
#   rj45.nodeCreate $eid $node_id
# FUNCTION
#   Procedure rj45.nodeCreate puts real interface into promiscuous mode.
# INPUTS
#   * eid -- experiment id
#   * node_id -- node id
#****
proc $MODULE.nodeCreate { eid node_id } {
	setToRunning "${node_id}_running" true
}

#****f* rj45.tcl/rj45.nodeNamespaceSetup
# NAME
#   rj45.nodeNamespaceSetup -- rj45 node nodeNamespaceSetup
# SYNOPSIS
#   rj45.nodeNamespaceSetup $eid $node_id
# FUNCTION
#   Linux only. Attaches the existing Docker netns to a new one.
# INPUTS
#   * eid -- experiment id
#   * node_id -- node id
#****
proc $MODULE.nodeNamespaceSetup { eid node_id } {
}

#****f* rj45.tcl/rj45.nodeInitConfigure
# NAME
#   rj45.nodeInitConfigure -- rj45 node nodeInitConfigure
# SYNOPSIS
#   rj45.nodeInitConfigure $eid $node_id
# FUNCTION
#   Runs initial L3 configuration, such as creating logical interfaces and
#   configuring sysctls.
# INPUTS
#   * eid -- experiment id
#   * node_id -- node id
#****
proc $MODULE.nodeInitConfigure { eid node_id } {
}

proc $MODULE.nodePhysIfacesCreate { eid node_id ifaces } {
	# first deal with VLAN interfaces to avoid 'non-existant'
	# interface error
	set vlan_ifaces {}
	set nonvlan_ifaces {}
	foreach iface_id $ifaces {
		if { [getIfcVlanTag $node_id $iface_id] != "" && [getIfcVlanDev $node_id $iface_id] != "" } {
			lappend vlan_ifaces $iface_id
		} else {
			lappend nonvlan_ifaces $iface_id
		}
	}

	foreach iface_id [concat $vlan_ifaces $nonvlan_ifaces] {
		captureExtIfc $eid $node_id $iface_id

		setToRunning "${node_id}|${iface_id}_running" true
	}
}

proc $MODULE.nodeLogIfacesCreate { eid node_id ifaces } {
}

#****f* rj45.tcl/rj45.nodeIfacesConfigure
# NAME
#   rj45.nodeIfacesConfigure -- configure rj45 node interfaces
# SYNOPSIS
#   rj45.nodeIfacesConfigure $eid $node_id $ifaces
# FUNCTION
#   Configure interfaces on a rj45. Set MAC, MTU, queue parameters, assign the IP
#   addresses to the interfaces, etc. This procedure can be called if the node
#   is instantiated.
# INPUTS
#   * eid -- experiment id
#   * node_id -- node id
#   * ifaces -- list of interface ids
#****
proc $MODULE.nodeIfacesConfigure { eid node_id ifaces } {
}

#****f* rj45.tcl/rj45.nodeConfigure
# NAME
#   rj45.nodeConfigure -- configure rj45 node
# SYNOPSIS
#   rj45.nodeConfigure $eid $node_id
# FUNCTION
#   Starts a new rj45. Simulates the booting proces of a node, starts all the
#   services, etc.
#   This procedure can be called if it is instantiated.
# INPUTS
#   * eid -- experiment id
#   * node_id -- node id
#   * ifaces -- list of interface ids
#****
proc $MODULE.nodeConfigure { eid node_id } {
}

################################################################################
############################# TERMINATE PROCEDURES #############################
################################################################################

#****f* rj45.tcl/rj45.nodeIfacesUnconfigure
# NAME
#   rj45.nodeIfacesUnconfigure -- unconfigure rj45 node interfaces
# SYNOPSIS
#   rj45.nodeIfacesUnconfigure $eid $node_id $ifaces
# FUNCTION
#   Unconfigure interfaces on a rj45 to a default state. Set name to iface_id,
#   flush IP addresses to the interfaces, etc. This procedure can be called if
#   the node is instantiated.
# INPUTS
#   * eid -- experiment id
#   * node_id -- node id
#   * ifaces -- list of interface ids
#****
proc $MODULE.nodeIfacesUnconfigure { eid node_id ifaces } {
}

proc $MODULE.nodeIfacesDestroy { eid node_id ifaces } {
	if { $ifaces == "*" } {
		set ifaces [ifcList $node_id]
	}

	foreach iface_id $ifaces {
		releaseExtIfc $eid $node_id $iface_id

		setToRunning "${node_id}|${iface_id}_running" false
	}
}

proc $MODULE.nodeUnconfigure { eid node_id } {
}

#****f* rj45.tcl/rj45.nodeShutdown
# NAME
#   rj45.nodeShutdown -- layer 3 node nodeShutdown
# SYNOPSIS
#   rj45.nodeShutdown $eid $node_id
# FUNCTION
#   Shutdowns a rj45 node.
#   Simulates the shutdown proces of a node, kills all the services and
#   processes.
# INPUTS
#   * eid -- experiment id
#   * node_id -- node id
#****
proc $MODULE.nodeShutdown { eid node_id } {
}

#****f* rj45.tcl/rj45.nodeDestroy
# NAME
#   rj45.nodeDestroy -- destroy
# SYNOPSIS
#   rj45.nodeDestroy $eid $node_id
# FUNCTION
#   Destroys an rj45 emulation interface.
# INPUTS
#   * eid -- experiment id
#   * node_id -- node id
#****
proc $MODULE.nodeDestroy { eid node_id } {
	setToRunning "${node_id}_running" false
}
