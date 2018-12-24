#pick_up_bottle

extends "res://Scripts/rig_obj_destructible.gd"

var type      = 0
var status    = 0
var frame_max = 1
var in_reach  = false setget in_reach_changed

func _ready():
	connect("just_hit",self,"just_hit")
	add_to_group("pickups")
	add_to_group("passable")
	
	life              = randi()%5+1
	fragment_emission = true
	shards_tscn       = load("res://Instances/shards.tscn")
	frame_max = ( $sprite.vframes * $sprite.hframes) -1
	
	type = randi()%6
	status = type
	$sprite.set("frame",type)

func _process(delta):
	
	pass

func just_hit():
	if not destroyed:
		status += 6
		status  = int( clamp(status, 0, frame_max) )
		$sprite.set("frame",status)
		$audio/clink.play()
		
	else:
		$audio/shatter.play()
	if life <= 1:
		$mentos.emitting = true


func _on_reach_body_entered(body):
	if body.is_in_group("player"): self.in_reach = true

func _on_reach_body_exited(body):
	if body.is_in_group("player"): self.in_reach = false

func in_reach_changed(val):
	in_reach = val

func save():
	var save_dict = {
		"filename" : get_filename(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
	}
	return save_dict