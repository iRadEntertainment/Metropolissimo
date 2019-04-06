#++++++++++++++++++++++#
#   DATA MANAGER.gd    #
#++++++++++++++++++++++#

extends Node

#---------- config_files
var data_dir  = str("res://metropolissimo_data")
var data_filename = "metropolissimo_data.cfg"
var data_path = str(data_dir,"/",data_filename)

var cfg_thumb_size  = 128
var cfg_fixed_size  = false
var cfg_window_size = Vector2(1024,768)
var cfg_fullscreen  = true
var cfg_vfx_enabled = true

var available_res = [	Vector2(640,360), Vector2(800,600), Vector2(1024,768),
						Vector2(1280,720), Vector2(1280,800), Vector2(1280,1024),
						Vector2(1360,768), Vector2(1366,768), Vector2(1440,900),
						Vector2(1536,864), Vector2(1600,900), Vector2(1680,1050),
						Vector2(1920,1080), Vector2(1920,1200), Vector2(2048,1152),
						Vector2(2560,1080), Vector2(2560,1440), Vector2(3440,1440),
						Vector2(3840,2160)]

#---------- save_games
var save_dir  = str(data_dir,"/savegame")

signal game_saved

#---------- Debug settings
var cfg_debug_mode        = true
var cfg_experimental_char = false


func _ready():
	load_initial_settings()
	load_settings()
	parse_loaded_settings()

func load_initial_settings():
	print("DATA MANAGER: loading initial settings")
	var dir = Directory.new()
	if dir.open(data_dir) != OK:
		print("DATA MANAGER: Unexisting folder")
		create_default_config()
	elif not Directory.new().file_exists(data_path):
		print("DATA MANAGER: no config file!")
		create_default_config()
	else:
		var file_config = ConfigFile.new()
		file_config.load(data_path)
		#var_name = file_config.get_value("settings", "var_name", var_name(or default value) )

func create_default_config():
	print("DATA MANAGER: creating default file")
	var dir = Directory.new()
	if dir.open(data_dir) != OK:
		var err_dir = dir.make_dir_recursive(data_dir)
		if err_dir == OK:
			prints("DATA MANAGER: folder created ->", data_dir)
		else:
			prints("DATA MANAGER: Unable to create folder -> Error",err_dir)
			return
	save_settings()

func save_settings():
	#--------- default values
	var file_config = ConfigFile.new()
	#--- general settings
	file_config.set_value("settings","cfg_thumb_size" ,cfg_thumb_size)
	file_config.set_value("settings","cfg_fixed_size" ,cfg_fixed_size)
	file_config.set_value("settings","cfg_window_size" ,cfg_window_size)
	file_config.set_value("settings","cfg_fullscreen" ,cfg_fullscreen)
	file_config.set_value("settings","cfg_vfx_enabled",cfg_vfx_enabled)
	
	#--- audio
	file_config.set_value("audio","master_bus_vol",audio_mng.master_bus_vol)
	file_config.set_value("audio","music_bus_vol" ,audio_mng.music_bus_vol)
	file_config.set_value("audio","sound_bus_vol" ,audio_mng.sound_bus_vol)
	
	file_config.set_value("audio","master_mute" ,audio_mng.master_mute)
	file_config.set_value("audio","music_mute"  ,audio_mng.music_mute)
	file_config.set_value("audio","sound_mute"  ,audio_mng.sound_mute)
	
	#--- debug settings
	file_config.set_value("settings","cfg_experimental_char" ,cfg_experimental_char)
	file_config.set_value("settings","cfg_debug_mode" ,cfg_debug_mode)
	
	#--------- finalizing
	var err_cfg = file_config.save(data_path)
	if err_cfg == OK:
		prints("DATA MANAGER: config file =", data_path)
	else:
		prints("DATA MANAGER: unable to save config file -> Error", err_cfg)

func load_settings():
	var file_config = ConfigFile.new()
	#--- check
	var err = file_config.load(data_path)
	if err != OK:
		print("DATA MANAGER: impossible to load %s"%data_path)
		return
	
	#--- load sections
	cfg_thumb_size  = file_config.get_value("settings","cfg_thumb_size",512)
	cfg_fixed_size  = file_config.get_value("settings","cfg_fixed_size",false)
	cfg_window_size = file_config.get_value("settings","cfg_window_size",Vector2(1024,768))
	cfg_fullscreen  = file_config.get_value("settings","cfg_fullscreen",true)
	cfg_vfx_enabled = file_config.get_value("settings","cfg_vfx_enabled",true)
	
	#--- load debug sections
	cfg_experimental_char = file_config.get_value("settings","cfg_experimental_char",true)
	cfg_debug_mode        = file_config.get_value("settings","cfg_debug_mode",true)
	
	#--- load audio sections
	audio_mng.master_bus_vol = file_config.get_value("audio","master_bus_vol")
	audio_mng.music_bus_vol  = file_config.get_value("audio","music_bus_vol")
	audio_mng.sound_bus_vol  = file_config.get_value("audio","sound_bus_vol")
	
	audio_mng.master_mute  = file_config.get_value("audio","master_mute", false)
	audio_mng.music_mute   = file_config.get_value("audio","music_mute" , false)
	audio_mng.sound_mute   = file_config.get_value("audio","sound_mute" , false)

func parse_loaded_settings():
	OS.window_resizable  = !cfg_fixed_size
	OS.window_borderless = cfg_fixed_size
	OS.window_size       = cfg_window_size
	OS.window_position   = Vector2()
	OS.window_fullscreen = cfg_fullscreen
	g_mng.fl_vfx_enabled = cfg_vfx_enabled


func quit_and_save():
	save_settings()
	get_tree().quit()
	


#========== GAME SAVES ================

func save_game():
	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for i in save_nodes:
		var node_data = i.call("save");
		save_game.store_line(to_json(node_data))
	save_game.close()

func load_game():
	var save_game = File.new()
	if not save_game.file_exists("user://save_game.save"):
		return # Error! We don't have a save to load.

    # We need to revert the game state so we're not cloning objects during loading. This will vary wildly depending on the needs of a project, so take care with this step.
    # For our example, we will accomplish this by deleting savable objects.
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for i in save_nodes:
		i.queue_free()

    # Load the file line by line and process that dictionary to restore the object it represents
	save_game.open("user://savegame.save", File.READ)
	while not save_game.eof_reached():
		var current_line = parse_json(save_game.get_line())
        # First we need to create the object and add it to the tree and set its position.
		var new_object = load(current_line["filename"]).instance()
		get_node(current_line["parent"]).add_child(new_object)
		new_object.position = Vector2(current_line["pos_x"], current_line["pos_y"])
        # Now we set the remaining variables.
		for i in current_line.keys():
			if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y":
				continue
			new_object.set(i, current_line[i])
	save_game.close()

func save_screenshot(save_thumb = false, save_num = 0):
	var img_path
	
	if save_thumb: img_path = str(save_dir , "/save_thumb" , save_num ,      ".png")
	else:          img_path = str(data_dir , "/" , utl.count_files(data_dir,".png") , ".png")
	
	
	get_viewport().set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	var capture = get_viewport().get_texture().get_data()
	get_viewport().set_clear_mode(Viewport.CLEAR_MODE_ALWAYS)
	capture.flip_y()
	
	if save_thumb:
		var crop = Image.new()
		crop.copy_from(capture)
		var min_size = min(crop.get_size().x ,crop.get_size().y)
		crop.crop(min_size, min_size)
		crop.convert(5)
		crop.resize(cfg_thumb_size,cfg_thumb_size,Image.INTERPOLATE_NEAREST)
		crop.resize_to_po2(true)
		#crop.blit_rect(capture,Rect2(pos,size),Vector2(0,0)) # capture.blit_rect( Image src, Rect2 src_rect, Vector2 dest=0 )
		crop.save_png(img_path)
	else:
		capture.save_png(img_path)
	prints("DATA MANAGER: screenshot saved at:" , img_path)

