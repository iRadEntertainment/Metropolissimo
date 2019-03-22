#++++++++++++++++++++++#
#   NODE MANAGER.gd    #
#++++++++++++++++++++++#

extends Node

var tm_solid
var tm_climb
var tm_platf
var cam
var gui
var pl
var spawn
var cnt

signal nodes_updated

func update_nodes(scene):
	var nodes = []
	var paths = ["tm/solid","tm/climb","tm/platf","cam_ctrl","GUI","player","cnt/spawn","cnt"]
	
	for i in range(paths.size()):
		if scene.get_node(paths[i]) == null:
			prints("N_MNG: node at",paths[i],"not found")
		else:
			nodes.append(scene.get_node(paths[i]))
	
	tm_solid = nodes[0]
	tm_climb = nodes[1]
	tm_platf = nodes[2]
	cam      = nodes[3]
	gui      = nodes[4]
	pl       = nodes[5]
	spawn    = nodes[6]
	cnt      = nodes[7]
	emit_signal("nodes_updated")