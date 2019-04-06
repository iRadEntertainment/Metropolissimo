#++++++++++++++++++++++#
#   NODE MANAGER.gd    #
#++++++++++++++++++++++#

extends Node

var tm
var tm_solid
var tm_climb
var tm_platf
var cam_ctrl
var cam
var gui
var pl
var spawn
var cnt
var tools

signal nodes_updated

func update_nodes(scene):
	var nodes = []
	var paths = ["tm","tm/solid","tm/climb","tm/platf","cam_ctrl","cam_ctrl/cam","GUI","player","cnt/spawn","cnt","tools"]
	
	for i in range(paths.size()):
		if scene.get_node(paths[i]) == null:
			prints("N_MNG: node at",paths[i],"not found")
		else:
			nodes.append(scene.get_node(paths[i]))
	
	tm       = nodes[0]
	tm_solid = nodes[1]
	tm_climb = nodes[2]
	tm_platf = nodes[3]
	cam_ctrl = nodes[4]
	cam      = nodes[5]
	gui      = nodes[6]
	pl       = nodes[7]
	spawn    = nodes[8]
	cnt      = nodes[9]
	tools    = nodes[10]
	emit_signal("nodes_updated")