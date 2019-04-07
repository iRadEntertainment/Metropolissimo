extends KinematicBody2D

var life = 10
var fl_alive = true

var start_glob_pos
var max_distance = 800
var vec_mov = Vector2()
var desired_mov = Vector2()
var target  = Vector2()


var speed_walk = 64
var speed_run  = 450
var acc = 100

# flags
var enemy_spotted  = false
var enemy_danger   = false
var dist_danger    = 256
var enemy_in_range = false

func _ready():
	start_glob_pos = global_position

#===================== ACTIONS =====================

func get_hit(val, hit_norm, hit_pos):
	if fl_alive: life -= val
	if life <= 0:
		die()
		return
	$anm["parameters/attack/active"] = true
	vec_mov += hit_norm*val*50

func die():
	fl_alive = false
	$anm["parameters/die/blend_amount"] = 1
	collision_layer = 0
	set_process(false)
	$anm/anim.play("dissolve_corpse") #queue_free at the end of the animation

func try_to_hit():
	if n_mng.pl in $trigger/attack.get_overlapping_bodies():
		n_mng.pl.get_hit(1)

#===================== STATUS =====================

func check_status(d): #processed
	#flip
	if vec_mov.x < 0 and scale.x != -1: scale.x = -1
	if vec_mov.x > 0 and scale.x !=  1: scale.x =  1
	
	#obstacles or pits
	if  $trigger/ray_front.is_colliding() or !$trigger/ray_dw.is_colliding(): vec_mov.x = -vec_mov.x
	
	#enemy spotted / danger / in attack range
	enemy_spotted = n_mng.pl in $trigger/detect.get_overlapping_bodies()
	if enemy_spotted and !enemy_danger:
		scale.x = 1 if (global_position.x - n_mng.pl.global_position.x < 0) else -1
		target = global_position
	
	if enemy_spotted:
		enemy_danger = (global_position - n_mng.pl.global_position).length() < dist_danger
	else:
		enemy_danger = false
	
	# enemy_in_attack_range
	if enemy_danger:
		enemy_in_range = n_mng.pl in $trigger/attack.get_overlapping_bodies()
	
	
	# animations
	if !enemy_spotted and !enemy_danger:
		if vec_mov.x == 0 and $anm["parameters/wal_idl_run/blend_amount"] != 0:
			$anm["parameters/wal_idl_run/blend_amount"] = 0
		if vec_mov.x != 0 and $anm["parameters/wal_idl_run/blend_amount"] != -1:
			$anm["parameters/wal_idl_run/blend_amount"] = -1
	
	if enemy_spotted:
		if $anm["parameters/wal_idl_run/blend_amount"] != 1:
			$anm["parameters/wal_idl_run/blend_amount"]  = 1
	
	if enemy_in_range:
		if !$anm["parameters/attack/active"]:
			$anm["parameters/attack/active"] = true
	else:
		if  $anm["parameters/attack/active"]:
			$anm["parameters/attack/active"] = false

#===================== PROCESS =====================

func _process(d):
	if !fl_alive:
		return
	
	check_status(d)
	
	if   not enemy_spotted or not enemy_danger:
		move_randomly(d)  # sets vec_mov.x and desired target
	elif enemy_spotted and not enemy_danger:
		pass
	else:
		follow_enemy(d)
	move_on_slopes(d) # sets vec_mov.y and rotation
	global_position += vec_mov*d

var t_rand = 0
func move_randomly(d):
	if vec_mov.x == 0:
		t_rand -= d
	if t_rand <= 0:
		t_rand = rand_range(2,6)
		match randi()%3:
			0: target = global_position
			1: target = global_position + Vector2( (randi()%5+4)*32 , 0 )
			2: target = global_position + Vector2(-(randi()%5+4)*32 , 0 )
	
	if (target - start_glob_pos).length() > max_distance:
		target = start_glob_pos
	desired_mov = (target - global_position).normalized() * speed_walk
	
	
	vec_mov.x = lerp(vec_mov.x, desired_mov.x, d*10)
	vec_mov.x = floor(vec_mov.x)
	if abs(target.x - global_position.x) < 1:
		global_position.x = target.x
		vec_mov.x = 0


func follow_enemy(d):
	if enemy_in_range:
		vec_mov.x /= 10
		return
	target.x = n_mng.pl.global_position.x
	desired_mov = (target - global_position).normalized() * speed_run
	
	vec_mov.x = lerp(vec_mov.x, desired_mov.x, d*10)
	if abs(target.x - global_position.x) < 1:
		global_position.x = target.x
		vec_mov.x = 0

func move_on_slopes(d):
	#set_rotation
	var norm = $trigger/ray_dw.get_collision_normal()
	var des_ang = $trigger/ray_dw.cast_to.angle_to(-norm)
	if des_ang > 180: des_ang -= 2*PI
	if abs(rotation)+abs(des_ang) > 0.1:
		rotation = lerp(rotation, des_ang, d*8)
#	rotation = des_ang
	
	#set vec_mov.y (up or down)
	var vert_distance = ($trigger/ray_dw.get_collision_point() - $trigger/ray_dw.global_position).length()
	global_position.y += vert_distance-10
#	if vert_distance > 11:
#		vec_mov.y += 8
#	elif vert_distance < 9:
#		vec_mov.y -= 8
#	else:
#		vec_mov.y  = 0

# ==================================================






