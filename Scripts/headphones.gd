#headphones.gd

extends Container

var is_in    = true
var margin_top_left
var margin_bt_right

var btn_color_nor = Color(1,1,1,1)
var btn_color_hov = Color(0.8,0,0,1)
var btn_color_prs = Color(1,0,0,1)

func _ready():
	hide()
	$sld_music.value = AudioServer.get_bus_volume_db( 1 )
	$lb_vol.text = str($sld_music.value)
	connect_signals()
	
	margin_top_left = Vector2(margin_top    , margin_left)
	margin_bt_right = Vector2(margin_bottom , margin_right)
	
	show_panel(true)

func _change_music_volume(val):
	AudioServer.set_bus_volume_db( 1, val )

func update_track(track):
	$track_name.text = track
	$progress.max_value = audio_mng.track_length

var tick = 0.02
func _process(delta):
#	tick -= delta
#	if tick < 0:
#		tick = 0.2
	update_bars()

func update_bars():
	#$progress
	$progress.value = audio_mng.n_music.get_playback_position()
	$progress/time_elaps.text = utl.format_time($progress.value)
	$audio_lv_l.value = AudioServer.get_bus_peak_volume_left_db(1,0)
	$audio_lv_r.value = AudioServer.get_bus_peak_volume_right_db(1,0)

func reset_bars():
	$progress.value   = $progress.min_value
	$progress/time_elaps.text = utl.format_time($progress.value)
	$audio_lv_l.value = $audio_lv_l.min_value
	$audio_lv_r.value = $audio_lv_r.min_value

func _input(event):
	if event.is_action_pressed("headphones"):
		is_in = !is_in
		show_panel(is_in)

func show_panel(entering):
	show()
	var speed  = 1
	var trans  = Tween.TRANS_EXPO
	var easing = Tween.EASE_OUT
	if entering:
		$move_in_out.interpolate_property(self,"margin_top",margin_top      , 0                 , speed, trans, easing)
		$move_in_out.interpolate_property(self,"margin_left",margin_left    , 0                 , speed, trans, easing)
		$move_in_out.interpolate_property(self,"margin_bottom",margin_bottom,-margin_top_left.x , speed, trans, easing)
		$move_in_out.interpolate_property(self,"margin_right",margin_right  ,-margin_top_left.y , speed, trans, easing)
	else:
		$move_in_out.interpolate_property(self,"margin_top",margin_top      , margin_top_left.x , speed, trans, easing)
		$move_in_out.interpolate_property(self,"margin_left",margin_left    , margin_top_left.y , speed, trans, easing)
		$move_in_out.interpolate_property(self,"margin_bottom",margin_bottom, margin_bt_right.x , speed, trans, easing)
		$move_in_out.interpolate_property(self,"margin_right",margin_right  , margin_bt_right.y , speed, trans, easing)
	
	$move_in_out.start()


#------------------ SIGNALS
func connect_signals():
	#------------ slider
	$sld_music.connect("value_changed",self,"_change_music_volume")
	audio_mng.connect("track_changed",self,"update_track")


func _on_move_in_out_tween_completed(object, key):
	visible = !is_in

func _on_loop_toggled(button_pressed):
	audio_mng.fl_loop_track = !audio_mng.fl_loop_track


func _on_shuffle_toggled(button_pressed):
	audio_mng.fl_shuffle = !audio_mng.fl_shuffle


func _on_play_pressed():
	audio_mng.n_music.play()
	set_process(true)

func _on_stop_pressed():
	audio_mng.n_music.stop()
	reset_bars()
	set_process(false)

func _on_prew_pressed():
	var val = audio_mng.now_playing-1
	if val == -1: val = 8
	audio_mng.set_ingame_music(val, audio_mng.n_music.playing)


func _on_next_pressed():
	var val = audio_mng.now_playing+1
	if val == 9: val = 0
	audio_mng.set_ingame_music(val, audio_mng.n_music.playing)
