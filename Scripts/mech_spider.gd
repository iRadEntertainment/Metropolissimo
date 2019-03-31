#======================#
#    mech_spider.gd    #
#======================#

extends KinematicBody2D

var patrol_x_left  = 200
var patrol_x_right = 200

var ik_script_leg_r # Script
var ik_script_leg_l # Script


func _ready():
	set_process(false)
	ik_script_leg_r = load("res://Scripts/ik.gd").new()
	ik_script_leg_l = load("res://Scripts/ik.gd").new()
	setup_ik_bones()
	set_process(true)


var t = 0
func _process(d):
	t += d
	ik_legs(d)
	move_and_collide(Vector2(sin(t)*50*d,0))



var ciccio
var ciccio2
func setup_ik_bones():
	#getting the leg parts in arrays
	var fk_leg_r = [$body/leg_low_f , \
					$body/leg_low_f/piston1 , \
					$body/leg_low_f/piston1/leg_f , \
					$body/leg_low_f/piston1/leg_f/foot_f , \
					$body/leg_low_f/piston1/leg_f/foot_f/ctrl]
	
	var fk_leg_l = [$body/leg_low_b , \
					$body/leg_low_b/piston1 , \
					$body/leg_low_b/piston1/leg_b , \
					$body/leg_low_b/piston1/leg_b/foot_b , \
					$body/leg_low_b/piston1/leg_b/foot_b/ctrl]
	
	ik_script_leg_r.set_nodes(fk_leg_r)
	ik_script_leg_l.set_nodes(fk_leg_l)
	
	ciccio  = global_position
	ciccio2 = global_position + Vector2(128,0)

var res = []
func ik_legs(d): #PROCESSED
	#target
	var target = get_global_mouse_position()
	
	res = ik_script_leg_r.reach_target(ciccio2)
	ik_script_leg_l.reach_target(ciccio)
	

func draw_stuff():
	n_mng.tools.draw_circles(res)


# tadaa
