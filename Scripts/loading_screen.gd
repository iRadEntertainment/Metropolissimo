#=====================#
#  LOADING_SCREEN.GD  #
#=====================#

extends Control

signal loading_complete

var actual_scene
var loader
var fl_loader_ready = false
var fl_just_preload
var fl_old_scene_freed = true
var fl_anim_on = false
var tempo_max = 50 #msec
var wait_frames = 10


func load_next_scene(scene, just_preload = false):
	fl_just_preload = just_preload
	actual_scene = utl.n_base()
	loader = ResourceLoader.load_interactive(scene)
	set_process(true)

func _process(delta):
	if wait_frames > 0:
		wait_frames -= 1
		return
	if not fl_anim_on:
#		$anim.play("loading")
		fl_anim_on = true
	if not fl_old_scene_freed: #n_sfondo.get_opacity()>=1 and :
		fl_old_scene_freed = true
		actual_scene.queue_free()
	
	if loader == null: # nel while successivo, se il loader = null non serve più processare
		set_process(false)
		return
	
	var err = loader.poll()
	if err == ERR_FILE_EOF: # caricamento finito
		var loaded_scene = loader.get_resource()
		loader = null
		fl_loader_ready = true
		if fl_just_preload == false:
			open_next_scene(loaded_scene)
	elif err == OK:
		update_percentage()
	else: # errore durante il caricamento
		loading_error()
		loader = null

func update_percentage():
	var percentage = float(loader.get_stage()) / loader.get_stage_count()
	# update animations
	$progress.value = percentage
#	var length = $anim.get_current_animation_length()
#	$anim.seek(percentage * length, true)

func open_next_scene(loaded_scene):
	fl_old_scene_freed = false
	actual_scene = loaded_scene.instance()

	#---------- send the scene resource to g_mng with the signal
	emit_signal("loading_complete",actual_scene)
	queue_free()


func loading_error():
	print ("LOADING_SCREEN: !!!Loading error!!!")