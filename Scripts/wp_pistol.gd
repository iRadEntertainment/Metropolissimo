extends KinematicBody2D

onready var impact_tscn = preload("res://Instances/impact_pistol.tscn")
onready var ray_tscn    = preload("res://Instances/trail_electric.tscn")
onready var shell_tscn  = preload("res://Instances/empty_shell_pistol.tscn")

var damage     = 1
var max_passes = 5 # max number of traversable objects if in group "passable"

func _ready():
	$nozzle/muzzle.hide()

func fire(obj_aimed , arr_obj_excluded):
	var ray    = $nozzle/ray
	var p1 = $nozzle.global_position
	var p2
	var ray_res
	
	for node in arr_obj_excluded:
		ray.add_exception(node)
	
	var normal = ray.get_collision_normal()
	if ray.is_colliding():
		for i in range(max_passes):
			
			p2      = ray.get_collision_point()
			normal  = ray.get_collision_normal()
			ray_res = p2-p1
			
			var obj_temp = ray.get_collider()
#			prints("WP_PISTOL: obj hit =",obj_temp)
			if obj_temp == null: return
			#-----impact
			var impact_inst = impact_tscn.instance()
			get_parent().add_child(impact_inst)
			impact_inst.global_position = p2
			impact_inst.rotation = PI/2 - atan2(normal.x , normal.y)
			
			#-----obj_hit
			if obj_temp.has_method("get_hit"):
				obj_temp.get_hit(damage, ray_res.normalized(), p2)
			
			if not obj_temp.is_in_group("passable"):
				break
			ray.add_exception(obj_temp)
			ray.force_raycast_update()
		ray.clear_exceptions()
		ray_res = p2-p1
	else:
		p2      = $nozzle/direct.global_position
		normal = null
		ray_res = (p2-p1).normalized()*4000
		p2 = p1 + ray_res
	
	
	#-----trail
#	var ray_inst = ray_tscn.instance()
#	ray_inst.rotation = -atan2(ray_res.x , ray_res.y) + PI
#	ray_inst.scale.x = 15
#	ray_inst.scale.y = ray_res.length()
#	n_mng.cnt.get_node("bullets").add_child(ray_inst)
#	ray_inst.global_position = ((p2 - p1) / 2 + p1)
	
	#-----shells
	var shell_inst = shell_tscn.instance()
	shell_inst.global_position = $bullet_eject.global_position
	shell_inst.rotation = $bullet_eject.global_rotation
#	prints("WP_PISTOL: shell chase, bullet_eject.global_rotation =", $bullet_eject.global_rotation)
	n_mng.cnt.get_node("bullets").add_child(shell_inst)
	#-----muzzle
	var frame_num = randi()%20
	$nozzle/muzzle.set("frame",frame_num)
	$nozzle/muzzle/anim.play("anim")
	
	#------- recoil
#	global_rotation = get_parent().global_rotation
#	$recoil.interpolate_property(self, "global_rotation", rotation -PI/16, rotation, 0.1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
#	$recoil.start()
	
	#------sfx
	$sfx/fire.play()

func reload():
	$sfx/reload.play()

func sfx_holster(val):
	$sfx/holster.play()