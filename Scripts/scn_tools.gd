# scn_tools.gd

extends Control

var fl_draw_as_points = false

func _ready():
	rect_size = n_mng.tm_solid.get_used_rect().size
	


func draw_As_points_toggle():
	fl_draw_as_points = !fl_draw_as_points
	update()

func _draw():
	if data_mng.cfg_debug_mode:
		if fl_draw_as_points:
			for pos in astar_grid_gen.points_pos:
				draw_circle( pos , 1.5 , Color(1 , 0 , 0))