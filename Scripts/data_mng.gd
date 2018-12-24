#++++++++++++++++++++++#
#   DATA MANAGER.gd    #
#++++++++++++++++++++++#

extends Node

#---------- config_files
var data_dir  = str(OS.get_system_dir(0),"/metropolissimo_data")
var data_filename = "metropolissimo_data.cfg"
var data_path = str(data_dir,"/",data_filename)

#---------- save_games
var save_dir  = str(data_dir,"/savegame")
var thumb_size = 128
signal game_saved


func _ready():
	load_initial_settings()

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
	
	#--------- default values
	var file_config = ConfigFile.new()
	file_config.set_value("settings","thumb_size",thumb_size)
	
	#--------- finalizing
	var err_cfg = file_config.save(data_path)
	if err_cfg == OK:
		prints("DATA MANAGER: config file =", data_path)
	else:
		prints("DATA MANAGER: unable to save config file -> Error", err_cfg)

#func carica_dati(dicosa):
#	if dicosa == "tutto" and not Directory.new().file_exists(perc_file_conf):
#		print("CARICAMENTO FALLITO: file di config non presente")
#		print("CHECK PRIMO AVVIO: genero file di default")
#		salva_dati("tutto")
#	var file_config = ConfigFile.new()
#	file_config.load(perc_file_conf)
#
#	if dicosa in ["settaggi", "tutto"]:
#		print("CARICAMENTO: settaggi")
#		fl_fullscreen   = file_config.get_value("settaggi","fl_fullscreen",false)
#		fl_low_process  = file_config.get_value("settaggi","fl_low_process",true)
#		fl_orologio     = file_config.get_value("settaggi","fl_orologio",true)
#		fl_mostra_fin   = file_config.get_value("settaggi","fl_mostra_fin",0)
#		bak_manuale     = file_config.get_value("settaggi","bak_manuale","")
#		fl_soffice_inst = file_config.get_value("settaggi","fl_soffice_inst",false)
#		fl_cont_vis     = file_config.get_value("settaggi","fl_cont_vis",false)
#		arrotonda       = file_config.get_value("settaggi","arrotonda",0.05)
#
#		_set_contabilita_visibile(fl_cont_vis)
#	if dicosa in ["ultimo_avvio", "tutto"]:
#		print("CARICAMENTO: ultimo_avvio")
#		ultimo_avvio_gio = file_config.get_value("date_avvio","ultimo_avvio_gio",str(giorno)+" "+mese+" "+str(anno))
#		ultimo_avvio_set = file_config.get_value("date_avvio","ultimo_avvio_set",settimana_corr)
#	if dicosa in ["turni", "tutto"]:
#		print("CARICAMENTO: turni")
#		var scheda_vuota = [[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0],[0,0,0,0,0,0]]
#		scheda_pass = file_config.get_value("schede_turni","scheda_pass",scheda_vuota)
#		scheda_corr = file_config.get_value("schede_turni","scheda_corr",scheda_vuota)
#		scheda_pros = file_config.get_value("schede_turni","scheda_pros",scheda_vuota)
#	if dicosa in ["rubrica", "tutto"]:
#		print("CARICAMENTO: rubrica")
#		lista_nomi   = file_config.get_value("rubrica","lista_nomi",[])
#		diz_contatti = file_config.get_value("rubrica","diz_contatti",{})
#	if dicosa in ["preventivi", "preventivi_prezzi", "tutto"]:
#		print("CARICAMENTO: preventivi")
##		diz_preventivi_prezzi_default = {"tipo"      :[ ["creazione",1.6],["riparazione",1],["produzione",1.4],["creazione partecipata",1.8] ],
##										"difficolta" :[ ["facile",15],["media",20],["difficile",25] ],
##										"metalli"    :[ ["argento",0.4],["oro",35],["rame",0.006] ],
##										"pacchetti"  :[ ["economy - orecchini",3],["economy - bracciale",7],["economy - anello",3] ],
##										"pietre"     :[ ["pietra di prova",15.3] ],
##										"IVA"        : 22}
#		lista_preventivi      = file_config.get_value("preventivi","lista_preventivi",[])
#		diz_preventivi_prezzi = file_config.get_value("preventivi","diz_preventivi_prezzi",diz_preventivi_prezzi_default)
#
#		for chiave in diz_preventivi_prezzi_default.keys():
#			if not diz_preventivi_prezzi.has(chiave):
#				diz_preventivi_prezzi[chiave] = diz_preventivi_prezzi_default[chiave]
#
#		for chiave in diz_preventivi_prezzi.keys():
#			if typeof(diz_preventivi_prezzi[chiave]) != TYPE_INT:
#				if diz_preventivi_prezzi[chiave] == null or diz_preventivi_prezzi[chiave].empty():
#					diz_preventivi_prezzi[chiave] = diz_preventivi_prezzi_default[chiave]
#	if dicosa in ["contabilita", "tutto"]:
#		print("CARICAMENTO: contabilita")
#		diz_contabilita         = file_config.get_value("contabilita","diz_contabilita",[])
#		lista_date_cont         = file_config.get_value("contabilita","lista_date_cont",[])
#
#
#func salva_dati():
#	var file_config = ConfigFile.new()
#	if Directory.new().file_exists(perc_file_conf): file_config.load(perc_file_conf)
#
#	file_config.set_value("settaggi","fl_fullscreen",fl_fullscreen)
#	file_config.save(perc_file_conf)
#	print(str("SALVATAGGIO: Completato in - ",perc_file_conf))

#func esegui_backup(tipo = "pre-apertura"):
#	if not Directory.new().file_exists(perc_file_conf):
#		print("RIPRISTINO: Nessun file di config presente")
#		return
#
#	var file_config = ConfigFile.new()
#	if   tipo == "pre-apertura":
#		print("RIPRISTINO: Salvataggio backup pre-apertura")
#		file_config.load(perc_file_conf)
#		file_config.save(perc_file_conf+".bak")
#	elif tipo == "manuale":
#		print("RIPRISTINO: Salvataggio backup manuale")
#		bak_manuale = str(giorno)+"_"+mese_c
#		salva_dati("settaggi")
#		file_config.load(perc_file_conf)
#		file_config.save(perc_file_conf+"_"+bak_manuale+".bak")
#
#func ripristina_backup(quale = "pre-apertura"):
#	print("RIPRISTINO: " + quale)
#	var file_config = ConfigFile.new()
#	if quale == "pre-apertura":
#		if Directory.new().file_exists(perc_file_conf+".bak"):
#			file_config.load(perc_file_conf+".bak")
#			file_config.save(perc_file_conf)
#			carica_dati("tutto")
#		else: print("Nessun back-up presente")
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
		crop.resize(thumb_size,thumb_size,Image.INTERPOLATE_NEAREST)
		crop.resize_to_po2(true)
		#crop.blit_rect(capture,Rect2(pos,size),Vector2(0,0)) # capture.blit_rect( Image src, Rect2 src_rect, Vector2 dest=0 )
		crop.save_png(img_path)
	else:
		capture.save_png(img_path)
	prints("DATA MANAGER: screenshot saved at:" , img_path)

