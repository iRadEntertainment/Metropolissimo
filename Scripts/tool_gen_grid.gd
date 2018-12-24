#++++++++++++++++++++++#
#   tool_gen_grid.gd   #
#++++++++++++++++++++++#

#tool
extends Node2D

func _ready():
	var as = astar_grid_gen.as_c
	for point in as.get_points():
		var pos = as.get_point_position(point)
		pos = Vector2(pos.x,pos.y)
		pos_pool.append(pos)
	update()

func _process(delta):
	update()


var rad = 2
var col = Color( 1 , 0 , 0 )
var pos_pool = PoolVector2Array()

func _draw():
#	for pos in pos_pool:
#		draw_circle( pos - global_position , rad , col )
	pass

#export var calculate_nodes = false setget fl_calculate
#export var fl_draw         = false setget fl_draw_changed
#
#var as = AStar.new()
#var grid_nodes = []
#
#var tile_walkable = [ 0 , 1 ]
#var tile_empty    = [-1 , 10]
#
#func fl_calculate(val):
#	calculate_nodes = val
#	if !val: return
#	var tm        = get_parent().get_parent().get_node("tilemap_solido")
#	var used_rect = tm.get_used_rect()
#	var dim_tile  = tm.cell_size
#	var tm_pos    = tm.global_position
#	prints (used_rect,dim_tile)
#
#	for v in range( used_rect.position.y , used_rect.end.y ):
#		for u in range( used_rect.position.x , used_rect.end.x ):
#			var this_cell_id  = tm.get_cell(u,v)
#			var this_cell_pos = Vector3(u,v,0)*dim_tile.x
#
#			if this_cell_id in tile_walkable:
#				if tm.get_cell(u,v-1) in tile_empty:
#					as.add_point(as.get_available_point_id() , this_cell_pos)
#
#	update()
#
#func fl_draw_changed(val):
#	fl_draw = val
#
#	update()
#
#
#func _draw():
#	if fl_draw:
#		for point in as.get_points():
#			var pos = Vector2(as.get_point_position(point).x , as.get_point_position(point).y)
#			draw_circle(pos , 3 , Color(1,0,0))
#
#
#
#
#
