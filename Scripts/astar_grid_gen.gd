#++++++++++++++++++++++#
#   astar_grid_gen.gd  #
#++++++++++++++++++++++#

extends Control

var as_c = AStar.new()  # AStar complete with all connections available and all nodes
var as_0 = AStar.new()  # AStar 0 : NO JUMP
var grid_nodes = []

var tile_walkable = [ 0 , 1 ]
var tile_empty    = [-1 , 10]

func start():
	get_tree().paused = true
	find_nodes()
	get_tree().paused = false

func find_nodes():
	var tm        = n_mng.tm_solid
	var used_rect = tm.get_used_rect()
	var dim_tile  = tm.cell_size
	var tm_pos    = tm.global_position
	var node_offset = Vector3(dim_tile.x/2,0,0)
	#node offset moves node from the top-left corner to top center

	for v in range( used_rect.position.y , used_rect.end.y ):
		for u in range( used_rect.position.x , used_rect.end.x ):
			var this_cell_id  = tm.get_cell(u,v)
			var this_cell_pos = Vector3 ( u * dim_tile.x   ,   v * dim_tile.y , 0 )

			if this_cell_id in tile_walkable:
				if tm.get_cell(u,v-1) in tile_empty:
					add_grid_points([as_c], this_cell_pos)
	
	as_c.get_points()

func add_grid_points(as_array, vector):
	for asgrid in as_array:
		asgrid.add_point(asgrid.get_available_point_id() , vector)