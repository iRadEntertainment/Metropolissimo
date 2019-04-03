extends KinematicBody2D


var t      = 0
var t_rand = 0
var fl_flap = true

const SPEED = 50 # px/sec
onready var des_dir_norm = Vector2(1,0)


var noise

func _ready():
	$anm.play("flapp")
	$anm.seek(rand_range(0,2))
	t_rand = rand_range(1.5,2.5)
	noise = get_parent().noise
	des_dir_norm.x = scale.x

func _process(dt):
	# animation
	t += dt
	if t >= t_rand:
		t = 0
		if fl_flap:
			fl_flap = false
			t_rand = rand_range(2.5,3.5)
			$anm.play("plane")
		else:
			fl_flap = true
			t_rand = rand_range(1.5,2.5)
			$anm.play("flapp")
	
	# movement
	des_dir_norm.y += noise.get_noise_2dv(Vector2(global_position.x , global_position.y)) *dt*0.01*scale.x
	des_dir_norm.x += (noise.get_noise_2dv(Vector2(global_position.x , global_position.y))+0.5) *dt*0.1*scale.x
	
	move_and_collide(des_dir_norm * SPEED * dt)
	
	
	# auto_kill
	if global_position.x < -300 or global_position.x > OS.window_size.x + 300 \
		or global_position.y < -300 or global_position.y > OS.window_size.y + 300:
		set_process(false)
		queue_free()