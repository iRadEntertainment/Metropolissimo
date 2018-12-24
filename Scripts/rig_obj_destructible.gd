#=============================#
# rigid body destructible.gd  #
#=============================#


extends RigidBody2D

signal just_hit

var life              = 4
var destroyed         = false

#--------- debris ----------
var fragment_emission      = false
var shards_tscn
var shards_color           = Color(1,1,1)
var shards_count           = 4
var shards_variation       = 2
var shard_persistance_time = 4

func _ready():
	add_to_group("can_be_hit")
	yield(get_tree(),"idle_frame")
	sleeping = true

func get_hit( damage= 0, force_dir_normalized = Vector2(0,0), hit_spot_global = Vector2(0,0) ):
	var hit_spot_local = get_transform().xform_inv(hit_spot_global)
	var force = force_dir_normalized * 100 * damage
	
	if not destroyed:
		life -= damage
		apply_impulse(hit_spot_local, force)
		if life <= 0:
			destroy(hit_spot_global, force_dir_normalized)
		
		emit_signal("just_hit")

func destroy(hit_spot_global, force):
	destroyed = true
	if fragment_emission:
		var shards = shards_tscn.instance()
		shards.global_position  = hit_spot_global
		shards_count += randi()%(shards_variation+1)
		shards.shard_count      = shards_count
		shards.shard_color      = shards_color
		shards.force            = force
		shards.persistance_time = shard_persistance_time
		
		var cnt_shards = utl.n_base().get_node("cnt/debris")
		cnt_shards.add_child(shards)
	$anim.play("fade")