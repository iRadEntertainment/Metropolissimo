#==========================#
#        PLAYER.GD         #
#==========================#

extends "res://Scripts/class_human.gd"
#player flags
var st_on_floor   : bool = true
var st_back_unbal : bool = false
var st_fron_unbal : bool = false

var st_action     : bool = false setget _st_action_changed
var st_aim        : bool = false setget _st_aim_changed
var st_armed      : bool = false setget _st_armed_changed
var st_look_at    : bool = false
var looking_at_pos = Vector2()
var looking_at_mouse : bool = false
var st_can_jump   : bool = true

var st_att_ladd   : bool = false
var st_att_rope   : bool = false
var st_next_ladd  : bool = false
var st_on_ladd    : bool = false
var st_next_rope  : bool = false
var st_on_rope    : bool = false
var st_on_plat    : bool = false
var st_is_center  : bool = false

var st_moving     : bool = false
var st_sprinting  : bool = false
var st_crouching  : bool = false
var st_jumping    : bool = false
var st_fire_trig  : bool = false

var anim_busy     : bool = false
var anim_busy_top : bool = false
var anim_busy_bot : bool = false
var pl_movement   : int = 1
enum PlMove {BUSY,
IDLE, CROUCH_IDLE, PRONE,
WALK, RUN, SPRINT, JUMP,
STEALTH, CROUCH_WALK, ROLL,
CLIMB_LADDER, CLIMB_LADDER_U, CLIMB_LADDER_D,
CLIMB_ROPE, CLIMB_ROPE_U, CLIMB_ROPE_D}

#player inputs
var no_input     = false
var key_p_reload = false

var aim_vector  = Vector2()
var head_rot_to_be_reset = false

#player textures
onready var head_tex_nor   = preload("res://Sprites/player/personaggio__0000_testa.png")
onready var head_tex_34u   = preload("res://Sprites/player/personaggio__0000_testa_34u.png")
onready var head_tex_up    = preload("res://Sprites/player/personaggio__0000_testa_up.png")
onready var head_tex_34d   = preload("res://Sprites/player/personaggio__0000_testa_34d.png")
onready var head_tex_down  = preload("res://Sprites/player/personaggio__0000_testa_down.png")

#triggers status
var tr_top_detect = false
var tr_bot_detect = false

#player stats
var life = 4

var pl_stat_aim_pistol        = 0.08    # seconds
var pl_stat_aim_follow_pistol = 10     # multiplier

var stop_multiplier = 1.1
var speed_walk      = 170
var speed_run       = 400
var speed_sprint    = 550
var speed_stealth   = 80
var speed_crouch    = 140

#collision polygon

var coll_standing : PoolVector2Array = [Vector2(0,0),Vector2(-8,-4),Vector2(-8,-44),Vector2(0,-56),Vector2(8,-44),Vector2(8,-4)]
var coll_crouch   : PoolVector2Array = [Vector2(0,0),Vector2(-8,-4),Vector2(-8,-20),Vector2(0,-30),Vector2(8,-20),Vector2(8,-4)]

#==================================================

func _ready():
#	set_physics_process(true)
#	set_process_input(true)
	
	max_speed = speed_walk
	pl_movement = PlMove.IDLE
	$anim/tree_body.active = true
	$anim/tree_legs.active = true
	
	update_life_interface()


func _input(event):
	if pl_movement == PlMove.BUSY: return
	if event.is_action_pressed("action"):
		_st_action_changed(!st_action)
		if !st_action and st_aim:
			_st_aim_changed(false)
	
	if event.is_action_pressed("jump"):
		st_jumping = true
		if st_att_ladd or st_att_rope:
			st_att_ladd = false
			st_att_rope = false
	if event.is_action_released("jump"):
		st_jumping = false
	
	if event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right"):
		if not (st_att_ladd or st_att_rope):
			st_moving = true
		if (st_att_ladd or st_att_rope) and st_on_floor:
			st_att_ladd = false
			st_att_rope = false
	if event.is_action_released("ui_left") or event.is_action_released("ui_right"):
		if not (event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right")):
			st_moving = false
	
	if event.is_action_pressed("crouch"):  $poly_coll.polygon = coll_crouch
	if event.is_action_released("crouch"): $poly_coll.polygon = coll_standing
	
	if event.is_action_pressed("sprint"):   st_sprinting = true
	if event.is_action_released("sprint"):  st_sprinting = false
	
	if event.is_action_pressed("aim"):
		if st_armed: _st_aim_changed(true)
		else:
			st_look_at = true
			looking_at_mouse = true
		
	if event.is_action_released("aim"):
		if st_aim:    _st_aim_changed(false)
		st_look_at = false
		looking_at_mouse = false
	
	if st_aim and event.is_action_pressed("fire"):
		st_fire_trig = true
		fire()
	
	if st_aim and event.is_action_released("fire"):
		st_fire_trig = false
	
	if event.is_action_pressed("reload"):
		key_p_reload = true
		$timers/key_keep_pressed.start()
		
		if $timers/double_tap.is_stopped():
			$timers/double_tap.start()
		elif $weapons.wp_num != $weapons.WpNum.UNARMED:
			self.st_armed = !st_armed #setget will call the function _st_armed_changed

	if event.is_action_released("reload"):
		key_p_reload = false
		if st_armed: weapon_reload()


#===================================== PROCESS =====================================
func _physics_process(d):
	#----------- status ----------------
	check_pl_on_floor()
	check_movement_status()
	check_env_status()
	#----------- gravity --------------
	vec_mov.y += gravity*d*50
	if is_on_ceiling():               vec_mov.y = 1
	if is_on_floor():                 vec_mov.y = 0
	elif st_on_floor and !st_jumping: vec_mov.y = 0
	
	if st_att_ladd or st_att_rope :   vec_mov.y = 0
	
	#----------- jumping --------------
	
	if st_jumping and st_crouching and st_on_plat and st_can_jump: #----------jump off platform
		st_can_jump = false
		vec_mov.y = -jump/4
		ignore_platforms(true , 0.3)
	if st_jumping and st_can_jump and st_on_floor: #----------jump
		st_can_jump = false
		vec_mov.y = -jump
		$sfx/jump.play()
	if not st_jumping and vec_mov.y < 0: #----------cut jump height
		vec_mov.y /= 1.3
	vec_mov.y = clamp(vec_mov.y , -g_mng.max_gravity , g_mng.max_gravity)
	
	#----------- movement --------------
	if (st_att_ladd or st_att_rope):
		vec_mov.x /= stop_multiplier
	
	elif Input.is_action_pressed("ui_right"):
		if fl_flipped: fl_flipped = false
		if not (st_att_ladd or st_att_rope):
			if vec_mov.x < 0: vec_mov.x /= 1.5
			elif vec_mov.x < 20: vec_mov.x = 20
			vec_mov.x += acc_speed*d
	elif Input.is_action_pressed("ui_left"):
		if !fl_flipped: fl_flipped = true
		if not (st_att_ladd or st_att_rope):
			if vec_mov.x > 0: vec_mov.x /= 1.5
			elif vec_mov.x > -20: vec_mov.x = -20
			vec_mov.x -= acc_speed*d
	else:
		vec_mov.x /= stop_multiplier
		if abs(vec_mov.x) < 20 and vec_mov.x != 0:
			vec_mov.x = 0
	
	vec_mov.x = clamp(vec_mov.x,-max_speed,max_speed)
	
	#----------- movement climb --------------
	if (st_att_ladd or st_att_rope):
		center_on_tile(d)
		if Input.is_action_pressed("ui_up"):   vec_mov.y = -climb_speed
		if Input.is_action_pressed("ui_down"): vec_mov.y =  climb_speed
		if Input.is_action_pressed("ui_down"): vec_mov.y =  climb_speed
	
	#----------- flipping sprites --------------
	if fl_flipped:
		$body_parts.scale.x = -1 ; $rays.scale.x = -1
	else:
		$body_parts.scale.x =  1 ; $rays.scale.x =  1
	
	#----------- moving platform/objects --------------
	if $rays/floor_c.is_colliding():
		var obj_vec_mov = $rays/floor_c.get_collider().get("vec_mov")
		if obj_vec_mov:
#			print(obj_vec_mov)
			move_and_collide(obj_vec_mov)
	
	
	#----------- move and slide --------------
#	if st_moving and not st_jumping and $rays/floor_c.is_colliding():
#		vec_mov = vec_mov.slide($rays/floor_c.get_collision_normal())
#	vec_mov = stick_to_slopes(vec_mov)
	move_and_slide(vec_mov,Vector2(0,-1), 5,4,deg2rad(46))
	
	# ---------- anim ----------------
	if st_look_at:
		if looking_at_mouse: looking_at_pos = get_global_mouse_position()
		pl_look_at(looking_at_pos)
	elif head_rot_to_be_reset: pl_look_reset()
	
	set_player_anim(d)
	
	# ---------- sfx ----------------
#	if st_on_floor and st_moving:
#		if   abs(vec_mov.x) >= speed_run:
#			if $timers/steps.wait_time != 0.3: $timers/steps.wait_time = 0.3
#		elif abs(vec_mov.x) >= speed_walk:
#			if $timers/steps.wait_time != 0.4: $timers/steps.wait_time = 0.4
#		elif abs(vec_mov.x) >= speed_crouch:
#			if $timers/steps.wait_time != 0.7: $timers/steps.wait_time = 0.7
#		else:
#			if $timers/steps.wait_time != 0.8: $timers/steps.wait_time = 0.8
#		if $timers/steps.is_stopped():
#			$timers/steps.start()
#			$sfx/steps.stream = sfx_steps_water[randi()%4]
#			$sfx/steps.play()
	
	# ---------- fire ----------------
	
	
	#========== TEST =================
	
	#=================================
	

func stick_to_slopes(vec_mov):
	if !$rays/floor_c.is_colliding() or !st_on_floor or st_jumping or st_on_ladd or st_on_rope or st_next_ladd or st_next_rope:
		return vec_mov
	
	var n = $rays/floor_c.get_collision_normal()
	vec_mov = vec_mov.slide(n)
	if st_fron_unbal:
		vec_mov.y = abs(vec_mov.x)*1.1
	return vec_mov


#======================== STATUS ============================

func update_life_interface():
	var col = Color.red
	if life >= 3:
		col = Color.green
	elif life > 1:
		col = Color.orangered
	
	$body_parts/hips/body/arm_r/life1.visible = life >= 1
	$body_parts/hips/body/arm_r/life1/light.color = col
	
	$body_parts/hips/body/arm_r/life2.visible = life >= 2
	$body_parts/hips/body/arm_r/life2/light.color = col
	
	$rmted_front2/forearm_r/life3.visible = life >= 3
	$rmted_front2/forearm_r/life3/light.color = col
	
	$rmted_front2/forearm_r/life4.visible = life >= 4
	$rmted_front2/forearm_r/life4/light.color = col


func get_hit(val=1,HIT_NORM = Vector2(), hit_pos = Vector2()):
	life -= val
	update_life_interface()


#======================== FLAGS ============================
func check_pl_on_floor():
	if $rays/floor_b.is_colliding() or $rays/floor_f.is_colliding():
		if not st_on_floor: st_on_floor = true
		if not   $rays/floor_c.is_colliding():
			if   $rays/floor_b.is_colliding():
				st_fron_unbal = true ; st_back_unbal = false
			elif $rays/floor_f.is_colliding():
				st_back_unbal = true ; st_fron_unbal = false
		else:
			st_fron_unbal = false ; st_back_unbal = false
	elif st_on_floor:
		st_on_floor = false ; st_fron_unbal = false ; st_back_unbal = false
	
	if st_on_floor and !st_can_jump:
		if $timers/can_jump.is_stopped(): $timers/can_jump.start()

func check_movement_status(): #processed
	var previous = pl_movement
	if pl_movement == PlMove.BUSY: return
	if not (st_on_floor or st_att_ladd or st_att_rope):
		pl_movement = PlMove.JUMP
		if Input.is_action_just_pressed("jump"):
			$anim/tree_body.transition_node_set_current("jump_up",0)
			$anim/tree_legs.transition_node_set_current("jump_up",0)
		change_animation_main()
		return
	#---- st_moving
	if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
		if !st_moving: st_moving = true
	else:
		if st_moving: st_moving = false
	
	#---- attached to ladder or ropes
	if st_att_ladd:
		if Input.is_action_pressed("ui_up"):     pl_movement = PlMove.CLIMB_LADDER_U
		elif Input.is_action_pressed("ui_down"): pl_movement = PlMove.CLIMB_LADDER_D
		else:                                    pl_movement = PlMove.CLIMB_LADDER
		return
	
	if st_att_rope:
		if Input.is_action_pressed("ui_up"):     pl_movement = PlMove.CLIMB_ROPE_U
		elif Input.is_action_pressed("ui_down"): pl_movement = PlMove.CLIMB_ROPE_D
		else:                                    pl_movement = PlMove.CLIMB_ROPE
		return
	
	if st_moving:
		if st_crouching and st_sprinting:
			if st_action: pl_movement = PlMove.ROLL
			else:         pl_movement = PlMove.PRONE
		elif st_sprinting:
			if st_action: pl_movement = PlMove.SPRINT
			else:         pl_movement = PlMove.RUN
		elif st_crouching:
			if st_action: pl_movement = PlMove.CROUCH_WALK
			else:         pl_movement = PlMove.STEALTH
		else:
			if st_action: pl_movement = PlMove.RUN
			else:         pl_movement = PlMove.WALK
		change_speed()
	
	else:
		if st_crouching: pl_movement = PlMove.CROUCH_IDLE
		else:            pl_movement = PlMove.IDLE
	# -------------- call transition on animation
	if previous != pl_movement:
		change_animation_main()

func check_env_status(): #processed
	#----- can_jump
	if !st_on_floor and st_can_jump: st_can_jump = false
	
	#----- top and bottom trigger areas
	tr_top_detect = not $triggers/env_detect_top.get_overlapping_bodies().empty()
	tr_bot_detect = not $triggers/env_detect_bot.get_overlapping_bodies().empty()
	
	
	#----- st_is_centered to ladders or ropes
	#TODO
	
	#----- st_on_plat
	if tr_bot_detect:
		if not n_mng.tm_climb in $triggers/env_detect_bot.get_overlapping_bodies():
			if not st_on_plat: st_on_plat = true
	else:   if     st_on_plat: st_on_plat = false
	
	#----- crouching
	if Input.is_action_pressed("ui_down"):
		if not st_att_ladd or not st_att_rope:
			st_crouching = true
	else:
		st_crouching = false
	
	#----- st_on_ladders or ropes
	if tr_bot_detect:
		if n_mng.tm_climb in $triggers/env_detect_bot.get_overlapping_bodies():
#			if not (st_on_ladd or st_on_rope):
			var tm_pos = n_mng.tm_climb.world_to_map($triggers/env_detect_bot.global_position)
			if   n_mng.tm_climb.get_cell(tm_pos.x , tm_pos.y) in [0]: st_on_ladd = true
			else:                                                     st_on_ladd = false
			if   n_mng.tm_climb.get_cell(tm_pos.x , tm_pos.y) in [2]: st_on_rope = true
			else:                                                     st_on_rope = false
		else:
			st_on_ladd = false ; st_on_rope = false
	else:
		st_on_ladd = false ; st_on_rope = false
	
	#----- st_next_ladders or ropes
	if tr_top_detect:# and not (st_att_ladd or st_att_rope):
		if n_mng.tm_climb in $triggers/env_detect_top.get_overlapping_bodies():
			if not (st_next_ladd or st_next_rope):
				var tm_pos = n_mng.tm_climb.world_to_map($triggers/env_detect_top.global_position)
				if   n_mng.tm_climb.get_cell(tm_pos.x , tm_pos.y) in [0,1]: st_next_ladd = true
				elif n_mng.tm_climb.get_cell(tm_pos.x , tm_pos.y) in [2,3]: st_next_rope = true
	else:
		st_next_ladd = false ; st_next_rope = false
	
	
	if st_att_ladd and not st_next_ladd: st_att_ladd = false
	if st_att_rope and not st_next_rope: st_att_rope = false
	
	
	#----- st_attached to ladders or ropes
	if Input.is_action_pressed("ui_up"):
		if st_next_ladd and not st_att_ladd: st_att_ladd = true
		if st_next_rope and not st_att_rope: st_att_rope = true
	
	
	if Input.is_action_pressed("ui_down"):
		if (st_att_ladd or st_att_rope) and st_on_floor:
			st_att_ladd = false
			st_att_rope = false
		#-- on top of climbs
		if st_on_ladd and not st_att_ladd: st_att_ladd = true
		if st_on_rope and not st_att_rope: st_att_rope = true
		
		if (st_on_ladd and st_att_ladd) or (st_on_rope and st_att_rope):
			ignore_platforms(true,0.1)
	
	
	
#	if st_on_ladd and st_crouching: st_att_ladd = true
#	if st_on_rope and st_crouching: st_att_rope = true
	
#	if st_att_ladd or st_att_rope:  ignore_platforms(true)
#	else:                           ignore_platforms(false)
	
	#----- reached the floor after climbing down from ladders or ropes
	if (st_att_ladd or st_att_rope) and st_on_floor and vec_mov.y > 0:
		st_att_ladd = false
		st_att_rope = false
	


func _st_action_changed(val):
	if not g_mng.action_allowed and not st_action: return
	st_action = val

func _st_armed_changed(val):
	if not g_mng.action_allowed: return
	st_armed = val
	_grab_wp(!val)

func _st_aim_changed(val):
	st_aim = val

func change_speed():
	match pl_movement:
		PlMove.WALK:        max_speed = speed_walk
		PlMove.CROUCH_WALK: max_speed = speed_crouch
		PlMove.RUN:         max_speed = speed_run
		PlMove.SPRINT:      max_speed = speed_sprint
		PlMove.STEALTH:     max_speed = speed_stealth

#====================== ANIMATIONS ========================
#func swap_anim_status_action(val):
#	if !val:
#		if st_armed: self.st_armed = !st_armed
func change_animation_main():
	match pl_movement:
		PlMove.IDLE:        set_tr_main(0)
		PlMove.CROUCH_IDLE: set_tr_main(1)
		PlMove.WALK:        set_tr_main(2)
		PlMove.CROUCH_WALK: set_tr_main(5)
		PlMove.RUN:         set_tr_main(4)
		PlMove.SPRINT:      pass
		PlMove.STEALTH:     set_tr_main(3)
		PlMove.JUMP:        set_tr_main(6)

func set_tr_main(anim, xfade = 0.06):
	$anim/tree_body.transition_node_set_xfade_time("tr_main", xfade)
	$anim/tree_legs.transition_node_set_xfade_time("tr_main", xfade)
	$anim/tree_body.transition_node_set_current   ("tr_main", anim)
	$anim/tree_legs.transition_node_set_current   ("tr_main", anim)

var sight_angle
func pl_look_at(gl_pos, time = 0): #PROCESSED
	head_rot_to_be_reset = true
	
	var head = $body_parts/hips/body/link/head
	var vec_res = gl_pos - (head.global_position + head.offset)
	var angle_sign = 1 - 2*int(fl_flipped)
	var angle = ( Vector2(1,0)*angle_sign ).angle_to( vec_res ) * angle_sign
	
	#debug
	sight_angle = angle
	n_mng.gui._mouse_info()
	
	#ignore animation rotation
	free_head_rotation(true)
	
	#rotation
	var delta = get_process_delta_time()
	if abs(angle) > PI/2: head.scale.x = -1
	else:                 head.scale.x =  1
	
	if   abs(angle) > PI*8/10:
		head.rotation = PI - angle * head.scale.x ; head.texture = head_tex_nor
	elif abs(angle) < PI*2/10:
		head.rotation = angle * head.scale.x      ; head.texture = head_tex_nor
	else:
		head.rotation = 0
		if   angle < -PI*5/12 and angle > -PI*7/12 : head.texture = head_tex_up
		elif angle >  PI*5/12 and angle <  PI*7/12 : head.texture = head_tex_down
		elif angle < 0:                              head.texture = head_tex_34u
		else:                                        head.texture = head_tex_34d

func pl_look_reset(): #PROCESSED
	head_rot_to_be_reset = false
	#reset ignore animation rotation
	free_head_rotation(false)
	#reset
	var head = $body_parts/hips/body/link/head
	head.rotation = 0
	head.scale.x  = 1
	head.texture  = head_tex_nor

var head_rotation_free = false
func free_head_rotation(val): #PROCESSED
	if    val and  head_rotation_free: return
	elif !val and !head_rotation_free: return
	
	var anim_names = ["idle0"]
	
	#----- free head rotation from animations
	if val and not head_rotation_free:
		head_rotation_free = true
		for anim in anim_names:
			$anim/tree_body.animation_node_set_filter_path(anim , "body_parts/hips/body/link/head:rotation_degrees", false)
		
	#----- lock head rotation to animations
	if not val and head_rotation_free:
		head_rotation_free = false
		for anim in anim_names:
			$anim/tree_body.animation_node_set_filter_path(anim , "body_parts/hips/body/link/head:rotation_degrees", true)



func set_player_anim(d): #PROCESSED
	if pl_movement == PlMove.BUSY: return
#	var blend_idl_walk_run = inverse_lerp(0, speed_run, abs(vec_mov.x) )*2-1
#	var blend_crouch       = $anim/tree_legs.blend2_node_get_amount("blend_crouch")
#	var blend_idl_walk_run = $anim/tree_legs.blend3_node_get_amount("blend_idl_walk_run")
	
#	if st_crouching:
#		if blend_crouch < 1: blend_crouch = clamp(blend_crouch+d/0.25 , 0 , 1)
#	else:
#		if blend_crouch > 0: clamp(blend_crouch+d/0.25 , 0 , 1)
#
#	if pl_movement in [PlMove.IDLE, PlMove.CROUCH_IDLE]:
#		if blend_idl_walk_run > 0:
#			pass
#	elif pl_movement in [PlMove.WALK, PlMove.STEALTH]:
#		if blend_idl_walk_run > 0:
#			pass
#	elif pl_movement in [PlMove.RUN, PlMove.CROUCH_WALK]:
#		if blend_idl_walk_run > 0:
#			pass
	
#	$anim/tree_body.blend2_node_set_amount( "blend_crouch" , blend_crouch)
#	$anim/tree_legs.blend2_node_set_amount( "blend_crouch" , blend_crouch)
#	$anim/tree_body.blend2_node_set_amount( "bl_stealth"   , blend_crouch)
#	$anim/tree_legs.blend2_node_set_amount( "bl_stealth"   , blend_crouch)
#	$anim/tree_body.blend3_node_set_amount( "blend_idl_walk_run" , clamp( blend_idl_walk_run, -1 , 1) )
#	$anim/tree_legs.blend3_node_set_amount( "blend_idl_walk_run" , clamp( blend_idl_walk_run, -1 , 1) )
#	match pl_movement:
#		PlMove.IDLE:        $anim/tree_body.transition_node_set_current("tr_main", 0 )
#		PlMove.CROUCH_IDLE: $anim/tree_body.transition_node_set_current("tr_main", 1 )
#		PlMove.WALK:        $anim/tree_body.transition_node_set_current("tr_main", 2 )
#		PlMove.CROUCH_WALK: pass
#		PlMove.RUN:         $anim/tree_body.transition_node_set_current("tr_main", 4 )
#		PlMove.SPRINT:      pass
#		PlMove.STEALTH:     $anim/tree_body.transition_node_set_current("tr_main", 3 )
#		PlMove.JUMP:        $anim/tree_body.transition_node_set_current("tr_main", 5 )
	
	#-------- Jump and fall
	if $anim/tree_body.transition_node_get_current("jump_up") != 0:
		if vec_mov.y < 0:
			$anim/tree_body.transition_node_set_current("jump_up" , 1)
			$anim/tree_legs.transition_node_set_current("jump_up" , 1)
		else:
			$anim/tree_body.transition_node_set_current("jump_up" , 2)
			$anim/tree_legs.transition_node_set_current("jump_up" , 2)
#	if Input.is_action_just_pressed("jump"):
#		$anim/tree_body.transition_node_set_current("jump_up", 0 )
#		$anim/tree_legs.transition_node_set_current("jump_up", 0 )
#
#	var air_time = $anim/tree_legs.blend2_node_get_amount("air_time")
#	if pl_movement == PlMove.JUMP:
#		if air_time < 1:
#			$anim/tree_body.blend2_node_set_amount("air_time" , clamp(air_time+d/0.15, 0 , 1) )
#			$anim/tree_legs.blend2_node_set_amount("air_time" , clamp(air_time+d/0.15, 0 , 1) )
#	elif air_time > 0:
#		$anim/tree_body.blend2_node_set_amount("air_time" , clamp(air_time-d/0.15, 0 , 1) )
#		$anim/tree_legs.blend2_node_set_amount("air_time" , clamp(air_time-d/0.15, 0 , 1) )
	
	#-------- Aim and shot
	if st_aim:
		$anim/tree_body.blend2_node_set_amount("blend_aim",clamp($anim/tree_body.blend2_node_get_amount("blend_aim")+d/pl_stat_aim_pistol,0,1))
		set_player_aim_anim(d)
	else:
		$anim/tree_body.blend2_node_set_amount("blend_aim",clamp($anim/tree_body.blend2_node_get_amount("blend_aim")-d/pl_stat_aim_pistol,0,1))
	if st_aim and Input.is_action_just_pressed("fire"):
		pass
	

func set_player_aim_anim(delta):
	var pos_head  = $body_parts/hips/body/link/head/ctrl_head.global_position
	var pos_mouse = get_global_mouse_position()
	aim_vector = (pos_mouse - pos_head).normalized()
	if fl_flipped: aim_vector.x = -aim_vector.x
	# aim_vector.angle() va da 0 a +PI in senso orario e da 0 a -PI antiorario partendo da destra
	var aim_angle = clamp( aim_vector.angle() , -PI/2 , PI/2 )
#	print()
	var anim_pos  = inverse_lerp(PI/2, -PI/2, (aim_angle) ) * $anim/body.get_animation("aim_pistol").length
	
	$anim/tree_body.timeseek_node_seek("aim_seek",anim_pos)
#	if $anim/body.current_animation != "aim_pistol":
#		$anim/body.play("aim_pistol")
#		$anim/body.seek(anim_pos,true)
#	else:
#		var pos_anim_advance = delta * pl_stat_aim_follow_pistol
#		if $anim/body.current_animation_position - anim_pos < 0:
#			pos_anim_advance = -pos_anim_advance
#
#		if abs($anim/body.current_animation_position - anim_pos) <= 0.1:
#			$anim/body.seek(anim_pos,true)
#		else:
#			$anim/body.advance(-pos_anim_advance)

func _grab_wp(val):
	#----anim
#	if val:
#		$anim/tree_body.oneshot_node_start()
	$weapons.holster(val)

func _on_random_anim_timeout():
	if !st_action:
		$anim/tree_legs.oneshot_node_start("anxiety")
		$anim/tree_legs.animation_node_set_master_animation("random_idle","idle_relax"+str(randi()%3+1))
		$timers/random_anim.wait_time = 4 + randi()%8
	else:
		pass
	$timers/random_anim.start()

#=========================== ACTIONS ==================================
func fire():
	var obj_aimed = null
	$weapons.fire(obj_aimed , [self])

func weapon_reload():
	$weapons.reload()




#========================== UTILS ==============================
func ignore_platforms(val = true, time = 0):
	if val:
		n_mng.tm_platf.collision_layer = 0
		n_mng.tm_platf.collision_mask = 0
	else:
		n_mng.tm_platf.collision_layer = 1024
		n_mng.tm_platf.collision_mask = 2 + 4 + 8 + 16
	
	#if it's timed the timer start and at the end triggers _ ignore_platform(false) _
	if time != 0 and $timers/platform_ignore.is_stopped():
		$timers/platform_ignore.wait_time = time
		$timers/platform_ignore.start()

const centering_speed : int = 50
func center_on_tile(d): #PROCESSED
	
	if   (int(global_position.x))%32 <= 15.5:
		translate( Vector2( d*centering_speed , 0) )
	elif (int(global_position.x))%32 >= 16.5:
		translate( Vector2(-d*centering_speed , 0) )

func player_can_move():
	return true

#========================== TIMERS ==============================
func _on_key_keep_pressed_timeout():
	if key_p_reload: print("PLAYER: checking bullet left")

func _on_can_jump_timeout():
	st_can_jump = true

func _on_platform_ignore_timeout():
	ignore_platforms(false)

#========================== SFX ==============================
onready var sfx_step_water1 = preload("res://Audio/sfx_step_water1.wav")
onready var sfx_step_water2 = preload("res://Audio/sfx_step_water2.wav")
onready var sfx_step_water3 = preload("res://Audio/sfx_step_water3.wav")
onready var sfx_step_water4 = preload("res://Audio/sfx_step_water4.wav")
onready var sfx_steps_water = [sfx_step_water1, sfx_step_water2, sfx_step_water3, sfx_step_water4]
onready var sfx_step_gravel1 = preload("res://Audio/sfx_step_gravel1.wav")
onready var sfx_step_gravel2 = preload("res://Audio/sfx_step_gravel2.wav")
onready var sfx_step_gravel3 = preload("res://Audio/sfx_step_gravel3.wav")
onready var sfx_steps_gravel = [sfx_step_gravel1, sfx_step_gravel2, sfx_step_gravel3]

var tiletype = 0
enum TileType {CONCRETE, WATER, GRAVEL}

func reproduce_footstep(): #called by animations
	#----------
	return
	#---------- skipped
	#TODO
#	if $sfx/steps.playing: return
#
#	tiletype = TileType.GRAVEL
#	match tiletype:
#		TileType.WATER:  $sfx/steps.stream = sfx_steps_water[randi()%4]
#		TileType.GRAVEL: $sfx/steps.stream = sfx_steps_gravel[randi()%3]
#	$sfx/steps.play()




