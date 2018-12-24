#======================#
#      shards.gd       #
#======================#

extends Node2D

var shard_count      = 10
var shard_color      = Color(1,1,1)
var force            = Vector2()
var persistance_time = 4

func _ready():
	var shard   = load("res://Instances/shard.tscn")
	for i in range(shard_count):
		var new_shard = shard.instance()
		new_shard.init_dir = force
		new_shard.intensity = rand_range(0.5,2.5)
#		new_shard.global_position = self.global_position
		new_shard.color = shard_color
		add_child(new_shard)
	$timer.wait_time = persistance_time
	$timer.start()

func _on_timer_timeout():
	queue_free()
