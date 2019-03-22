extends Node2D


func _ready():
	pass

func generate_pickups():
	var pickup = load("res://Instances/bottle.tscn")
	var tm       = n_mng.tm_solid
	var tile_dim = tm.cell_size.x
	var gridrect = tm.get_used_rect()

	for i in range(gridrect.position.x, gridrect.end.x):
		for j in range(gridrect.position.y, gridrect.end.y):
			if tm.get_cell(i,j) in [0,5,15]:
				if tm.get_cell(i,j-1) in [-1,9,10,11,12,13,14]:
					if randi()%5 < 2:
						var bottle = pickup.instance()
						var offset_bottle = Vector2(16,-8)
						bottle.global_position = Vector2(i,j) * tile_dim + offset_bottle
						add_child(bottle)