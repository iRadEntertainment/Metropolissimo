#====================#
#    main_menu.gd    #
#====================#

extends Control

var margin_offs = 40
enum SubMenu {NONE , LOAD_GAME, OPTIONS , DEBUG}

var fade_off = false
const stage1_1_path = "res://Stages/Stage1/stage1.tscn"

onready var thumb_btn = preload("res://Instances/thumb_load.tscn")

func _ready():
	g_mng.connect("vfx_enabled",self,"vfx_toggle")
	$hbox_bttm/btns_main/g_new.connect("new_game_click",self,"_btn_new_game")
	vfx_toggle(g_mng.fl_vfx_enabled)
	audio_mng.start_menu_music()
	check_for_savegames()

func vfx_toggle(val):
	$vfx.visible = val

func _process(delta):
	mouse_parallax_bg()
	if fade_off:
		var alpha = modulate.a
		modulate.a -= delta*2
		if modulate.a < 0.1:
			fade_off = false
			g_mng.load_new_game(stage1_1_path)
			queue_free()

func mouse_parallax_bg():
	var mouse_offs = Vector2()
	var screen = OS.get_screen_size()
	mouse_offs.x = (get_global_mouse_position().x/screen.x) 
	mouse_offs.y = (get_global_mouse_position().y/screen.y)
	$bg_tex.margin_left   =    -mouse_offs.x  * margin_offs*2
	$bg_tex.margin_right  =  (1-mouse_offs.x) * margin_offs*2
	$bg_tex.margin_top    =    -mouse_offs.y  * margin_offs*2
	$bg_tex.margin_bottom =  (1-mouse_offs.y) * margin_offs*2


func show_sub_menu(val):
	var sub_menus = [$hbox_bttm/cnt_load_game, $hbox_bttm/cnt_opts , $hbox_bttm/cnt_debug]
	for i in range(sub_menus.size()):
		if i == val-1:
			sub_menus[i].visible = !sub_menus[i].visible
		else:
			sub_menus[i].visible = false

func _on_load_game_click():          show_sub_menu(SubMenu.LOAD_GAME)
func _on_options_btn_option_click(): show_sub_menu(SubMenu.OPTIONS)
func _btn_debug_click():             show_sub_menu(SubMenu.DEBUG)
func _btn_new_game():
	fade_off = true
	audio_mng.music_fade_out()

func check_for_savegames():
	var savegames_count = utl.count_files(data_mng.save_dir, ".png")
	prints("DATA MANAGER: savegames count =", savegames_count)
	if savegames_count > 0:
		var cnt = $hbox_bttm/cnt_load_game/hbox/btns_load
		for i in range(savegames_count):
			var tmb_inst = thumb_btn.instance()
			tmb_inst.img      = str(data_mng.save_dir ,"/save_thumb", i+1 , ".png")
			tmb_inst.savename = str(i+1," - save")
			cnt.add_child(tmb_inst)
			
	