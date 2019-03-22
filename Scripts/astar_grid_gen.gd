#++++++++++++++++++++++#
#   astar_grid_gen.gd  #
#++++++++++++++++++++++#

extends Control

var as_c       = AStar.new()  # AStar complete with all connections available and all nodes
var as_no_jump = AStar.new()  # AStar 0 : NO JUMP
var grid_nodes = []
var points_pos = PoolVector2Array()

var tile_walkable = [ 0 , 1 ]
var tile_empty    = [-1 , 6,7,8,9,10]

func start():
	find_nodes()



func find_nodes():
	
	var used_rect = n_mng.tm_solid.get_used_rect()
	var dim_tile  = n_mng.tm_solid.cell_size
	var tm_pos    = n_mng.tm_solid.global_position
	var node_offset        = Vector2(dim_tile.x/2 , 0)
	var node_offset_half   = Vector2(0 , dim_tile.y  /2)
	var node_offset_quart  = Vector2(0 , dim_tile.y  /4)
	var node_offset_3quart = Vector2(0 , dim_tile.y*3/4)
	#node offset moves node from the top-left corner to top center

	for v in range( used_rect.position.y , used_rect.end.y ):
		for u in range( used_rect.position.x , used_rect.end.x ):
			var this_cell_id  = n_mng.tm_solid.get_cell(u,v)
			var this_cell_pos = Vector2 ( u * dim_tile.x  ,  v * dim_tile.y) + node_offset

			if this_cell_id in [0,5,6,7,9] and free_up_n_tiles(u,v,2):
				add_grid_points([as_c], this_cell_pos)
			elif this_cell_id in [1,4] and free_up_n_tiles(u,v,2):
				add_grid_points([as_c], this_cell_pos + node_offset_half)
			elif this_cell_id in [2] and free_up_n_tiles(u,v,2):
				add_grid_points([as_c], this_cell_pos + node_offset_3quart)
			elif this_cell_id in [3] and free_up_n_tiles(u,v,2):
				add_grid_points([as_c], this_cell_pos + node_offset_quart)
			
			elif this_cell_id in [8,10] and free_up_n_tiles(u,v,2):
				add_grid_points([as_c], this_cell_pos)
			


func free_up_n_tiles(u,v,n_tiles):
	var is_free = true
	for i in range(n_tiles):
		if not (n_mng.tm_solid.get_cell(u , v -1-i) in tile_empty) :
			is_free = false
			break
	return is_free

func add_grid_points(as_array, vec2):
	points_pos.append( vec2 )
	var vec3 = Vector3 ( vec2.x , vec2.y , 0 )
	for asgrid in as_array:
		asgrid.add_point(asgrid.get_available_point_id() , vec3)