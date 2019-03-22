#dummy.gd

extends "res://Scripts/rig_obj_destructible.gd"

var status      = 0

func _ready():
	connect("just_hit",self,"just_hit")
	add_to_group("enemies")
	add_to_group("passable")
	
	life                   = 8
	fragment_emission      = true
	shards_tscn            = load("res://Instances/shards.tscn")
	shards_color           = Color(1,1,1)
	shards_count           = 4
	shards_variation       = 2
	shard_persistance_time = 4

func just_hit():
	status += 0.5
	status = min (status, 3)
	$body.texture = load( "res://Sprites/enemies/dummy_%s.png"% (int(floor(status))) )
	if randi()%7 < 3:
		$anim.play("hit")

func _on_anim_finished():
	if destroyed: return
	$anim.play("idle")