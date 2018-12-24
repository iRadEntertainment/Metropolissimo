#street_entrance.gd

extends Node2D

var street_width = 32*6 #setget _street_width_changed
export(Texture) var text_left          #setget _texture_left_changed


func _ready():
	var l_text_size = $left.texture.get_size()
	$left.position  = Vector2(-street_width/2 , 0)
	$left.offset    = Vector2(l_text_size.x/2 , -l_text_size.y/2)
	var r_text_size = $right.texture.get_size()
	$right.position  = Vector2(street_width/2 , 0)
	$right.offset    = Vector2(-r_text_size.x/2 , -r_text_size.y/2)


func _on_vsn_screen_entered(): set_process(true)
func _on_vsn_screen_exited(): set_process(false)

func _process(delta):
	update_tool()
	pass


func _street_width_changed(val):
	street_width = val
#	$label.text    = str($left.get_global_transform_with_canvas().origin)
	update_tool()

func _texture_left_changed(tex):
	$left.texture  = tex
	update_tool()

func update_tool():
	var w_size = OS.get_real_window_size()
	var l_orig = $left.get_global_transform_with_canvas().origin.x
	var r_orig = $right.get_global_transform_with_canvas().origin.x
	$left.scale.x  = clamp( (w_size.x/2-l_orig)*0.5 / w_size.x , -1 , 1 )
	$right.scale.x = clamp( (r_orig-w_size.x/2)*0.5 / w_size.x , -1 , 1 )