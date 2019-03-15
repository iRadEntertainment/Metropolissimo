#++++++++++++++++++++++#
#   AUDIO MANAGER.gd   #
#++++++++++++++++++++++#

extends Node

onready var btn_interr1 = preload("res://Audio/fx_tick_1.wav")
onready var btn_interr2 = preload("res://Audio/fx_tick_2.wav")
onready var btn_interr3 = preload("res://Audio/fx_interr_1.wav")
onready var btn_interr4 = preload("res://Audio/fx_interr_2.wav")
onready var btn_interr5 = preload("res://Audio/fx_interr_3.wav")
onready var btn_interr6 = preload("res://Audio/fx_interr_4.wav")

onready var n_music = $music

var pik1 = "res://Audio/music/PiK_01_Aaaaa.ogg"
var pik2 = "res://Audio/music/PiK_02_Soundscapes_vol7.ogg"
var pik3 = "res://Audio/music/PiK_03_Messa_for_the_grandfather.ogg"
var pik4 = "res://Audio/music/PiK_04_Spin8.ogg"
var pik5 = "res://Audio/music/PiK_05_Fleek_Rin.ogg"
var pik6 = "res://Audio/music/PiK_06_Journey_on_Foot_in_the_Hyperuranium.ogg"
var pik7 = "res://Audio/music/PiK_07_Pistifalia.ogg"
var pik8 = "res://Audio/music/PiK_08_Esparianto.ogg"

#----------- headphones
signal track_changed
var now_playing
var song_name = ""
var track_length
var fl_loop_track = false
var fl_shuffle    = false

func _ready():
#	AudioServer.set_bus_volume_db( 1, -24 )
	pass

#============= MENU
func start_menu_music():
	randomize()
	$menu/intro_music.stream = load([pik1,pik2,pik3,pik4,pik5,pik6,pik7,pik8][randi()%8])
	$menu/intro_music.volume_db = -12
	$menu/intro_music.play()

func music_fade_out(): $menu/music_fade.play("music_fade")
func stop_intro_music():
	$menu/intro_music.stop()

func play_btn(val): #plays button sounds
	var switches_sfx = [btn_interr3 , btn_interr4 , btn_interr5 , btn_interr6, btn_interr1 , btn_interr2]
	match val:
		0: $menu/btn.stream = switches_sfx[randi()%4]
		1: $menu/btn.stream = switches_sfx[randi()%2+4]
		2: $menu/btn.stream = null
	$menu/btn.play()

func _on_intro_music_finished(): start_menu_music()


#============= IN GAME
func set_ingame_music(val, fl_play = true):
	if val == 0:
		$music.stream = load("res://Audio/music/first_0_intro.ogg") ; song_name = "Theme song 1"
		now_playing = 0
	else:
		now_playing = val
		$music.stream = load([pik1,pik2,pik3,pik4,pik5,pik6,pik7,pik8][val-1])
		match val:
			1: song_name = "1-PiK - Aaaaa"
			2: song_name = "2-PiK - Soundscapes vol.7"
			3: song_name = "3-PiK - Messa for the grandfather"
			4: song_name = "4-PiK - Spin8"
			5: song_name = "5-PiK - Fleek Rin"
			6: song_name = "6-PiK - Journey on Foot in the Iperuranium"
			7: song_name = "7-PiK - Pistifalia"
			8: song_name = "8-PiK - Esparianto"
	
	track_length = $music.stream.get_length()
	prints("AUDIO_MNG: strem resource name =",song_name,"- Lenght:",track_length)
	if fl_play: $music.play()
	$music
	
	emit_signal("track_changed",song_name)

func quick_menu(goes_in):
	$quick_menu_out.playing = !goes_in
	$quick_menu_in.playing  =  goes_in

func _on_music_finished():
	var next = now_playing
	if fl_shuffle:
		randomize()
		next = randi()%8+1
	elif !fl_loop_track:
		next = now_playing+1
		if next > 8: next = 1
	set_ingame_music(next)
