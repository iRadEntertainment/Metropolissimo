#++++++++++++++++++++++#
#   GAME MANAGER.gd    #
#++++++++++++++++++++++#

extends Node

#------ scenes var
const loading_scene_path     = "res://Instances/loading_screen.tscn"
onready var gui_preload      = preload("res://Instances/GUI.tscn")
onready var cam_ctrl_preload = preload("res://Instances/cam_ctrl.tscn")
onready var pl_preload       = preload("res://Instances/player.tscn")
onready var pl_preload_xp    = preload("res://Instances/pl_sperim.tscn")

#------ option vars
var fl_vfx_enabled = false setget _vfx_enabled
signal vfx_enabled

#------ in game vars
var fl_ingame      = false
var action_allowed = true
var max_gravity    = 2000

var tween_slow_time = null
var slow_time_factor = .02
var slow_time_fade   = 0.5 #seconds


func _ready():
	VisualServer.set_default_clear_color( Color(0,0,0,1) )

#============ Input and menu
func _input(event):
	if fl_ingame:
		if event.is_action_pressed("quick_menu"):
			n_mng.gui.quick_menu(true)
			audio_mng.quick_menu(true)
			slow_down_time(true)
		if event.is_action_released("quick_menu"):
			n_mng.gui.quick_menu(false)
			audio_mng.quick_menu(false)
			slow_down_time(false)
		if event is InputEventKey:
			if event.scancode == KEY_F12 and event.is_pressed():
				data_mng.save_screenshot(true,1)

func _vfx_enabled(val):
	fl_vfx_enabled = val
	emit_signal("vfx_enabled",val)

#============= loading scenes management
func load_new_game(path):
	
	
	#--- add loading_screen.tscn
	var loading_screen = load(loading_scene_path).instance()
	get_node("/root").add_child(loading_screen)
	loading_screen.connect("loading_complete",self,"scene_loaded")
	
	#--- add info for the title of the loading screen
	#TODO
	
	#--- load the next scene and wait for the signal
	loading_screen.load_next_scene(path)

func load_stage_from_main_menu(path):
	utl.n_base().queue_free()
	load_new_game(path)

func scene_loaded(incoming_scene):
	add_stage_instances(incoming_scene)
	n_mng.update_nodes(incoming_scene)
	
	#--- scene setup
	get_tree().paused = true
	get_node("/root").add_child(incoming_scene)
	
	n_mng.tm.calculate_solid_grid()
	astar_grid_gen.start()
	n_mng.tm.replace_solid_cells()
	n_mng.cnt.generate_pickups()
	
	get_tree().paused = false
	#--- game setup
	game_setup_and_start()
	fl_ingame = true

func add_stage_instances(incoming_scene):
	var name = incoming_scene.get_name()
	prints("G_MNG: next scene =",name)
	if "stage" in name:
		prints("G_MNG: adding",name,"instances")
		
		incoming_scene.add_child(gui_preload.instance())
		print("G_MNG: - GUI")
		incoming_scene.add_child(cam_ctrl_preload.instance())
		print("G_MNG: - CAM CONTROL")
		
		var pl_instance
		if data_mng.cfg_experimental_char:
			pl_instance = pl_preload_xp.instance()
			print("G_MNG: - Player experimental")
		
		else:
			pl_instance = pl_preload.instance()
			print("G_MNG: - Player")
			
		incoming_scene.add_child(pl_instance)

func game_setup_and_start():
	n_mng.pl.global_position  = n_mng.spawn.get_node("1").global_position
	n_mng.cam.global_position = n_mng.spawn.get_node("1").global_position
	
	audio_mng.set_ingame_music(0 , false)

#=============== Game mechanics
func slow_down_time(val):
	if tween_slow_time == null:
		tween_slow_time = Tween.new()
		utl.n_base().add_child(tween_slow_time)
	
	var game_speed = Engine.time_scale
	var tween_time = inverse_lerp(slow_time_factor,1,game_speed) * slow_time_fade
	if not val:
		tween_time = inverse_lerp(1,slow_time_factor,game_speed) * slow_time_fade
	var target_time = 1
	if val: target_time = slow_time_factor
	tween_slow_time.stop_all()
	tween_slow_time.interpolate_property(Engine, "time_scale", game_speed, target_time, tween_time, Tween.TRANS_EXPO, Tween.EASE_OUT)
	tween_slow_time.start()




