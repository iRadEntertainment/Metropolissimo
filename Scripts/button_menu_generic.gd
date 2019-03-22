
# button_menu_generic

extends Button

func _ready():
	connect("mouse_entered",self,"_mouse_in")
	connect("mouse_exited",self,"_mouse_out")
	connect("focus_entered",self,"_focus")
	connect("pressed",self,"custom_pressed")
	setup_button()

#to be defined eventually in the button inheriting
func setup_button(): pass 

func _mouse_in():      audio_mng.play_btn(1)
func _mouse_out():     audio_mng.play_btn(2)
func _focus():         if not pressed: audio_mng.play_btn(1)
func custom_pressed(): audio_mng.play_btn(0) #in this way buttons script can use _pressed() without override the audio