#==========================#
#        WEAPONS.GD        #
#==========================#

extends Node2D

onready var holster = get_node("../rmted_front/hips_rmted/wp_holster")
onready var hand    = get_node("../rmted_front2/forearm_r/hand_r/wp_hand")

enum WpNum {UNARMED, PISTOL, RIFLE}

signal anim_holster_done
signal anim_unholster_done

var fl_wp_held = false

var wp_num        = 0
var wp_node_armed = null

var clips = [15, 15, 15, 15, 15]
var rifle_cooldown = 0.15

func _ready():
	show()
	select(WpNum.UNARMED)
#	holster(true)

func _input(event):
#	if event.is_action_pressed("reload"):
#		key_p_reload = true
#		$timers/key_keep_pressed.start()
#
#		if $timers/double_tap.is_stopped():
#			$timers/double_tap.start()
#		else:
#			self.st_armed = !st_armed #setget will call the function _st_armed_changed
#
#	if event.is_action_released("reload"):
#		key_p_reload = false
#		if st_armed: weapon_reload()
	
	if event is InputEventKey and event.is_pressed():
		match event.scancode:
			KEY_1: select(WpNum.UNARMED)
			KEY_2: select(WpNum.PISTOL)
			KEY_3: select(WpNum.RIFLE)

func select(num):
	if num == wp_num: return
	
	wp_num = num
	
	for i in range (get_child_count()):
		if i+1 == num:
			get_child(i).show()
			wp_node_armed = get_child(i)
		else:
			get_child(i).hide()

func holster(val):
	if wp_num == WpNum.UNARMED: return
	
	fl_wp_held = val
	
	if val:
		var tree_body = n_mng.pl.get_node("anim/tree_body")
		holster.remote_path = holster.get_path_to(wp_node_armed)
		hand.remote_path    = ""
	else:
		holster.remote_path = ""
		hand.remote_path    = hand.get_path_to(wp_node_armed)
	
	for rem_tranf in [holster,hand]:
		rem_tranf.update_position = true
		rem_tranf.update_rotation = true
		rem_tranf.update_scale    = true
	
	if wp_node_armed.has_method("sfx_holster"):
		wp_node_armed.sfx_holster(val)

func fire(obj_aimed , arr_obj_excluded):
	if wp_num == WpNum.UNARMED: return

	if wp_node_armed.has_method("fire"):
#		if wp_num == WpNum.RIFLE:
#			for i in range (4):
#				wp_node_armed.fire(obj_aimed , arr_obj_excluded)
#				OS.delay_usec(0.5)
#		else:
		wp_node_armed.fire(obj_aimed , arr_obj_excluded)

func reload():
	if wp_num == WpNum.UNARMED: return
	if wp_node_armed.has_method("reload"):
		wp_node_armed.reload()

func _process(delta):
	
	pass






