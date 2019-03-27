#++++++++++++++++++++++#
#   NODE MANAGER.gd    #
#++++++++++++++++++++++#

extends Node

var tm
var tm_solid
var tm_climb
var tm_platf
var cam
var gui
var pl
var spawn
var cnt
var tools

signal nodes_updated

func update_nodes(scene):
	var nodes = []
#	var paths = ["tm","tm/solid","tm/climb","tm/platf","cam_ctrl","GUI","player","cnt/spawn","cnt","tools"]
	var paths = ["tm","tm/solid","tm/climb","tm/platf","cam_ctrl","GUI","pl_sperim","cnt/spawn","cnt","tools"]
	
	for i in range(paths.size()):
		if scene.get_node(paths[i]) == null:
			prints("N_MNG: node at",paths[i],"not found")
		else:
			nodes.append(scene.get_node(paths[i]))
	
	tm       = nodes[0]
	tm_solid = nodes[1]
	tm_climb = nodes[2]
	tm_platf = nodes[3]
	cam      = nodes[4]
	gui      = nodes[5]
	pl       = nodes[6]
	spawn    = nodes[7]
	cnt      = nodes[8]
	tools    = nodes[9]
	emit_signal("nodes_updated")