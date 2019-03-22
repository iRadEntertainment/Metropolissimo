# tm_startup.gd

extends Node2D

#--- solid grid arrays
var grid_cell     = []
var grid_flipx    = []
var grid_flipy    = []
var grid_traspond = []
var start_pos     = Vector2()

var show_debug = false
var debug = false setget _debug_set

func _ready():
	set_process_input(false)
#	calculate_solid_grid()
#	replace_solid_cells()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_pressed():
				show_debug = true
				debug_tm()
			else:
				show_debug = false

	#code for dragging the debug graphical node
	if show_debug and event is InputEventMouseMotion:
		debug_tm()

func debug_tm():
	var pos = get_global_mouse_position()/32
	pos = Vector2( floor(pos.x) , floor(pos.y) )
	$tm_debug.position = pos*32
	$tm_debug.coord = pos
	$tm_debug.num   = $solid.get_cell(pos.x, pos.y)
	if $tm_debug.num == -1: $tm_debug.num = ""
	$tm_debug.solid = ( $solid.get_cellv(pos) != -1 )
	$tm_debug.climb = ( $climb.get_cellv(pos) != -1 )
	$tm_debug.bg    = ( $bg.get_cellv(pos) != -1 )
	$tm_debug.flipx = ( $solid.is_cell_x_flipped( pos.x, pos.y ) )
	$tm_debug.flipy = ( $solid.is_cell_y_flipped( pos.x, pos.y ) )
	$tm_debug.trasp = ( $solid.is_cell_transposed( pos.x, pos.y ) )
	$tm_debug.refresh()

func calculate_solid_grid():
	var used_rect = $solid.get_used_rect()
	start_pos = used_rect.position

	for v in range( used_rect.position.y , used_rect.end.y ):
		var row_cell  = PoolIntArray()
		var row_flipx = PoolIntArray()
		var row_flipy = PoolIntArray()
		var row_trans = PoolIntArray()
		for u in range( used_rect.position.x , used_rect.end.x ):
			row_cell.append( int($solid.get_cell(u,v)) )
			row_trans.append( int($solid.is_cell_transposed(u,v)) )
			row_flipx.append( int($solid.is_cell_x_flipped(u,v)) )
			row_flipx.append( int($solid.is_cell_y_flipped(u,v)) )

		grid_cell.append(row_cell)
		grid_flipx.append(row_flipx)
		grid_flipy.append(row_flipy)
		grid_traspond.append(row_trans)

func replace_solid_cells():
	#replace all the cell in solid that have to be on "climb" or "platf" tilemaps
	for j in range(grid_cell.size()):
		var v = int( j - start_pos.y )
		for i in range(grid_cell[0].size()):
			var u = int( i - start_pos.x )
			if $solid.get_cell(u,v) in [6,7,8,9,10]:
				match $solid.get_cell(u,v):
					6:
						$solid.set_cell(u,v,-1) ; $platf.set_cell(u,v,6)
					7:
						$solid.set_cell(u,v,-1) ; $platf.set_cell(u,v,6) ; $climb.set_cell(u,v,0)
					8:
						$solid.set_cell(u,v,-1) ; $climb.set_cell(u,v,1)
					9:
						$solid.set_cell(u,v,-1) ; $platf.set_cell(u,v,6) ; $climb.set_cell(u,v,2)
					10:
						$solid.set_cell(u,v,-1) ; $climb.set_cell(u,v,3)

func _debug_set(val):
	debug = val
	set_process_input(val)
#	$solid.collision_layer