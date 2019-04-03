extends Control

onready var crow_instance = preload("res://Instances/crow.tscn")

var spawn = Vector2(-100,200)
#var noise = OpenSimplexNoise.new()
onready var noise

func _ready():
	setup_noise()
	create_flock()
	

func setup_noise():
	noise = self.material.get_shader_param("noise_text").noise

func create_flock():
	noise.seed = randi()%500
	var flock_size = randi()%20+5
	var scale = rand_range(0.3,1)
	for i in range (flock_size):
		var randx = rand_range(-80 , 80)
		var randy = rand_range(-80 , 80)
		var cr = crow_instance.instance()
		var this_scale = scale * rand_range(0.8,1.2)
		cr.global_position = spawn + Vector2(randx, randy) * this_scale
		cr.scale = Vector2( this_scale, this_scale )
		add_child(cr)


var t = 15
func _process(dt):
	t -= dt
	if t <= 0:
		t = randi()%25+32
		create_flock()