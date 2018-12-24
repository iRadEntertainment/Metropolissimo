#shard.gd

extends RigidBody2D

var type      = 0
var init_dir  = Vector2(0,-1)
var intensity = 1
var color = Color(1,1,1,1)

func _ready():
	var frame_max = $sprite.get("vframes") * $sprite.get("hframes") - 1
	modulate = color
	type = randi()%frame_max
	$sprite.set("frame", type)
	scatter()
	
	$anim.playback_speed = rand_range(0.8,1.2)

func scatter():
	var random_point = Vector2()
	random_point.x = rand_range(-6,6)
	random_point.y = rand_range(-6,6)
	
	apply_impulse(random_point,(init_dir + Vector2(0,-1.5)) * intensity * 50)
