#wp_assault_rifle.gd

extends KinematicBody2D

onready var impact_tscn = preload("res://Instances/impact_pistol.tscn")
onready var ray_tscn    = preload("res://Instances/trail_electric.tscn")
onready var shell_tscn  = preload("res://Instances/empty_shell_pistol.tscn")

var damage        = 1
var max_passes    = 1 # max number of traversable objects if in group "passable"
var burst_bullets = 4 # number of shots fired during a burst shot

var object_to_shoot    = null
var objects_to_exclude = []

func _ready():
	$nozzle/muzzle.hide()
	$sound_decay.connect ("timeout",self,"_stop_sound")
	$burst.connect       ("timeout",self,"burst_count_down")


func fire(obj_aimed , arr_obj_excluded):
	
	object_to_shoot    = obj_aimed
	objects_to_exclude = arr_obj_excluded
	
	var ray    = $nozzle/ray
	var p1     = $nozzle.global_position
	var p2      # collision point
	var ray_res # resulting vector p1 -> p2
	
	for node in arr_obj_excluded:
		ray.add_exception(node)
	
	var normal = ray.get_collision_normal()
	if ray.is_colliding():
		for i in range(max_passes):
			
			p2      = ray.get_collision_point()
			normal  = ray.get_collision_normal()
			ray_res = p2-p1
			
			var obj_temp = ray.get_collider()
#			prints("WP_ASSAULT_RIFLE: obj hit =",obj_temp)
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
	$sfx/fire.stop()
	$sfx/fire.play()
	$sound_decay.start() # connected to time to func _stop_sound()
	
	#------ burst shot
	$burst.stop()
	$burst.start()

func _stop_sound():      $sfx/fire.stop()
func reload():           $sfx/reload.play()
func sfx_holster(val):   $sfx/holster.play()
func burst_count_down():
	burst_bullets -= 1
	if burst_bullets == 0:
		burst_bullets = 4
	else:
		fire(object_to_shoot, objects_to_exclude)