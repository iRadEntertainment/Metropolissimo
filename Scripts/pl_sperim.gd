extends "res://Scripts/class_human.gd"

var stop_multiplier = 0

var st_on_floor   : bool = true
var st_back_unbal : bool = false
var st_fron_unbal : bool = false

var st_action     : bool = false
var st_aim        : bool = false
var st_armed      : bool = false
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
var pl_stat_aim_pistol        = 0.08    # seconds
var pl_stat_aim_follow_pistol = 10     # multiplier

var speed_walk      = 170
var speed_run       = 400
var speed_sprint    = 550
var speed_stealth   = 80
var speed_crouch    = 140


func _ready():
	setup_ik_bones()
	
	max_speed = speed_walk
	pl_movement = PlMove.IDLE

func _input(event):
	if event.is_action_pressed("action"):
		pass
	
	if event.is_action_pressed("jump"):
		pass
	if event.is_action_released("jump"):
		pass
	
	if event.is_action_pressed("ui_left"):
		vec_mov.x = -max_speed
	elif event.is_action_pressed("ui_right"):
		vec_mov.x =  max_speed
		
	if event.is_action_released("ui_left") or event.is_action_released("ui_right"):
		vec_mov.x = 0
	
	if event.is_action_pressed("ui_down"):
		position.y += 16
	elif event.is_action_released("ui_down"):
		position.y -= 16
	
	if event.is_action_pressed("sprint"):
		pass
	if event.is_action_released("sprint"):
		pass
	
	if event.is_action_pressed("aim"):
		pass
	if event.is_action_released("aim"):
		pass
	
	if st_aim and event.is_action_pressed("fire"):
		pass
	if st_aim and event.is_action_released("fire"):
		pass
	
	if event.is_action_pressed("reload"):
		pass
	if event.is_action_released("reload"):
		pass

func _physics_process(d):
	ik_legs(d)
	move_and_collide(vec_mov*d)
#	move_and_slide(vec_mov,Vector2(0,-1), 5,4,deg2rad(46))


#===========vvv============= Inverse Kinematic ============vvv=============

var ik_leg_r = []
func setup_ik_bones():
	#getting the leg parts in arrays
	for part in $body.get_children():
		ik_leg_r.append(part)


func ik_legs(d): #PROCESSED
	#target
	var target = get_global_mouse_position()
	
	#follow to target
	for i in range(ik_leg_r.size()-1):
		if i < ik_leg_r.size()-2:
			var next_segment_pos = ik_leg_r[i+1].global_position
			ik_leg_r[i].follow(next_segment_pos , d)
		else:
			ik_leg_r[i].follow(target , d)
	
	#bring the configuration back to the fixed point
#	for i in range(ik_leg_r.size()):
#		if i == 0:
#			ik_leg_r[i].position = ik_leg_r[i].init_pos
#		else:
#			ik_leg_r[i].position = ik_leg_r[i-1].position + ik_leg_r[i-1].abs_vec2

#===========^^^================ Inverse Kinematic ============^^^=============




