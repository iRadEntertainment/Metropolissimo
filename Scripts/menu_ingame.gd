#++++++++++++++++++++++#
#    menu_ingame.gd    #
#++++++++++++++++++++++#

extends CanvasLayer

var fl_debug_mode = false
var pan_velocity  =  50
var col_red    = Color(0.8 , 0.1 , 0.2)
var col_green  = Color(0.1 , 0.8 , 0.2)
var col_orange = Color(0.5 , 0.6 , 0.2)

var mouse_info_offset = Vector2()

var fl_mouse_info = false

func _ready():
	connect_player_var_box()
	$mouse_info.visible = false
	$menu.visible  = false
	$debug.visible = fl_debug_mode
	mouse_info_offset = - $mouse_info.rect_size/2

func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_F2 and event.is_pressed():
			$debug.visible = !$debug.visible
			fl_debug_mode = $debug.visible
			n_mng.tools.draw_As_points_toggle()
		
		if event.scancode == KEY_ESCAPE and event.is_pressed():
			get_tree().paused = !get_tree().paused
			$menu.visible = get_tree().paused
			n_mng.cam.get_node("pos").visible = get_tree().paused
		
		if get_tree().paused:
			if event.scancode == KEY_W and event.is_pressed():  n_mng.cam.global_position.y -= pan_velocity
			if event.scancode == KEY_A and event.is_pressed():  n_mng.cam.global_position.x -= pan_velocity
			if event.scancode == KEY_S and event.is_pressed():  n_mng.cam.global_position.y += pan_velocity
			if event.scancode == KEY_D and event.is_pressed():  n_mng.cam.global_position.x += pan_velocity
	
	if event is InputEventMouseButton and get_tree().paused:
		if event.button_index == BUTTON_WHEEL_UP:   n_mng.cam.get_node("cam").zoom /= 1.2
		if event.button_index == BUTTON_WHEEL_DOWN: n_mng.cam.get_node("cam").zoom *= 1.2
		if event.button_index == BUTTON_MIDDLE:     n_mng.cam.get_node("cam").zoom = Vector2 ( 1 , 1 )

func _mouse_info():
	if !fl_debug_mode: return
	fl_mouse_info = true
	if not $mouse_info.visible: $mouse_info.visible = true
	$mouse_info.rect_position = get_viewport().get_mouse_position() + mouse_info_offset
	$mouse_info/show_off.start()

func _on_mouse_info_show_timeout():
	fl_mouse_info = false
	$mouse_info.visible = false

var show_quick_menu = false
func quick_menu(val):
	show_quick_menu = val
	$quick_menu.visible = true
	set_process(true)

func _process(delta):
	var alpha = inverse_lerp(1 , g_mng.slow_time_factor , Engine.time_scale)
	var col = Color(1,1,1,alpha)
	$quick_menu/overlay.set("modulate",col)
	
	if show_quick_menu:
		if alpha >=   1:
			set_process(false)
	else:
		if alpha <= g_mng.slow_time_factor:
			$quick_menu.visible = false
			set_process(false)


#========== player Var

func connect_player_var_box():
	$debug/player_var/st1/st.text = str(n_mng.pl.acc_speed)
	$debug/player_var/st2/st.text = str(n_mng.pl.jump)
	$debug/player_var/st3/st.text = str(n_mng.pl.climb_speed)
	$debug/player_var/st4/st.text = str(n_mng.pl.stop_multiplier)
	
	$debug/player_var/st1/st.connect("text_entered",self,"_pl_acc_speed_set")
	$debug/player_var/st2/st.connect("text_entered",self,"_pl_jump_set")
	$debug/player_var/st3/st.connect("text_entered",self,"_pl_climb_set")
	$debug/player_var/st4/st.connect("text_entered",self,"_pl_stop_mult_set")


#export (int) var gravity     = 50

#var speed_walk      = 170
#var speed_run       = 400
#var speed_sprint    = 550
#var speed_stealth   = 80
#var speed_crouch    = 140

func _pl_acc_speed_set(val):
	n_mng.pl.acc_speed       = int(val)
	$debug/player_var/st1/st.release_focus()
func _pl_jump_set(val):
	n_mng.pl.jump            = int(val)
	$debug/player_var/st2/st.release_focus()
func _pl_climb_set(val):
	n_mng.pl.climb_speed     = int(val)
	$debug/player_var/st3/st.release_focus()
func _pl_stop_mult_set(val):
	n_mng.pl.stop_multiplier = float(val)
	$debug/player_var/st4/st.release_focus()










