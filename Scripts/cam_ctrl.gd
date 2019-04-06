
# -------- camera_ctrl.gd -----------

extends Position2D

export var offset_ahead = Vector2(150,-32)
export var smooth       = 0.05

var zoom_step    = 1.2
var zoom_default = 0.8
var zoom_target  = 0.8
var zoom_speed   = 5
var zoom_min     = 0.25
var zoom_max     = 8

var go_to = Vector2()


func _ready():
	set_process(true)
	set_process_input(true)
	
	zoom_target = zoom_default
	#----------- cam limits
	$cam.limit_left   = n_mng.tm_solid.get_used_rect().position.x * 32
	$cam.limit_top    = n_mng.tm_solid.get_used_rect().position.y * 32
	$cam.limit_right  = n_mng.tm_solid.get_used_rect().end.x * 32
	$cam.limit_bottom = n_mng.tm_solid.get_used_rect().end.y * 32

func _input(event):
	if (event is InputEventMouseButton):
		
		zoom_max = (8    if data_mng.cfg_debug_mode else 1.4)
		zoom_min = (0.25 if data_mng.cfg_debug_mode else 0.5)
		
		if (event.button_index == BUTTON_WHEEL_UP):   zoom_target = clamp(zoom_target/zoom_step, zoom_min, zoom_max)
		if (event.button_index == BUTTON_WHEEL_DOWN): zoom_target = clamp(zoom_target*zoom_step, zoom_min, zoom_max)
		if (event.button_index == BUTTON_MIDDLE):     zoom_target = zoom_default

func _process(delta):
	if n_mng.pl.fl_flipped:
		if offset_ahead.x > 0:
			offset_ahead.x = -offset_ahead.x
	else:
		if offset_ahead.x < 0:
			offset_ahead.x = -offset_ahead.x
	var offset_vec_mov = n_mng.pl.vec_mov * 0.2
	go_to = n_mng.pl.global_position + offset_ahead + offset_vec_mov
	
	if n_mng.pl.st_aim or n_mng.pl.st_look_at:
		var pos = n_mng.pl.looking_at_pos
		if n_mng.pl.st_aim: pos = get_global_mouse_position()
		go_to.x = lerp(go_to.x, pos.x, smooth*7)
		go_to.y = lerp(go_to.y, pos.y, smooth*7)
	
	#---------- pan cam control node position
	global_position.x = lerp(global_position.x , go_to.x, smooth * delta*70)
	global_position.y = lerp(global_position.y , go_to.y, smooth * delta*70)
	
	#---------- zoom
	if abs($cam.zoom.x - zoom_target) > 0.001:
		$cam.zoom.x = lerp($cam.zoom.x, zoom_target, clamp(delta * zoom_speed , 0, 0.5) )
		$cam.zoom.y = lerp($cam.zoom.y, zoom_target, clamp(delta * zoom_speed , 0, 0.5) )
	elif abs($cam.zoom.x - zoom_target) > 0:
		$cam.zoom.x = zoom_target
		$cam.zoom.y = zoom_target
	
	