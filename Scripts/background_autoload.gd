extends Node

#Loading a level in godot engine using background load
#######################################################

### 1. autoload backgroundLoad.gd ###

func set_new_scene(scene_resource): # function in bacgroundload.gd
    current_scene = scene_resource.instance()
    var rootChildren = get_node("/root").get_children()
#    print("root children -->", rootChildren)
    get_node("/root").get_children().clear()
#    print("root children now -->", rootChildren) 
#    for i in range (rootChildren.size()):
#        get_node("/root").remove_child(i)
    get_node("/root").add_child(current_scene)
#    print ("loading scene, adding child - ", current_scene.get_name())

### 2. menus.gd which is the parent of level loader scene(s) ###

func _load_scene(scene): # load scene function in menus.gd
	loading = true
	_show_progress()
	_hide_current()
	get_node("/root/backgroundLoad").goto_scene( scene )

### 3. stage.gd which is connected to the main stage scene ###

func _ready(): #ready function in stage.gd
	var root = get_tree().get_root()
	var current_scene = root.get_child( root.get_child_count() -1 )
	var prev_scene = root.get_child( root.get_child_count() -2 )
	print (prev_scene)
	print ("current Scene on level load", prev_scene.get_name())
	if prev_scene != null || str(prev_scene) != ("[Deleted Object]"):# || ""):
		prev_scene.queue_free() # get rid of the old scene
