
# button_menu_generic

extends Button

func _ready():
	connect("mouse_entered",self,"_mouse_in")
	connect("mouse_exited",self,"_mouse_out")
	connect("focus_entered",self,"_focus")
#	if has_method("setup_button"):
#		setup_button()


func _mouse_in():  audio_mng.play_btn(1)
func _mouse_out(): audio_mng.play_btn(2)
func _focus():     audio_mng.play_btn(1)