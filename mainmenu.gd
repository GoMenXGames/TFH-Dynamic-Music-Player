extends Control



# Called when the node enters the scene tree for the first time.
func _ready():
	print_debug(get_window().mode)
	
	if get_window().mode == Window.MODE_WINDOWED: 
		if get_window().content_scale_mode == Window.CONTENT_SCALE_MODE_DISABLED:
			get_window().size = Vector2(534, 880)
		get_window().position = Vector2(
		DisplayServer.screen_get_size(-1).x/2-get_window().size.x/2,
		DisplayServer.screen_get_size(-1).y/2-get_window().size.y/2
		)
	
	var userfolder = OS.get_user_data_dir()
	print (userfolder)
	var user = userfolder.split("/")[2]
	print (user)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_texture_button_pressed():
	if get_window().mode == Window.MODE_WINDOWED:
		if get_window().content_scale_mode == Window.CONTENT_SCALE_MODE_DISABLED:
			get_window().size = Vector2(850, 880)
	get_tree().change_scene_to_file("res://control.tscn")
	pass # Replace with function body.


func _on_info_btn_pressed():
	if get_window().mode == Window.MODE_WINDOWED:
		if get_window().content_scale_mode == Window.CONTENT_SCALE_MODE_DISABLED:
			get_window().size = Vector2(880, 880)
	get_tree().change_scene_to_file("res://info.tscn")
	pass # Replace with function body.ace with function body.


func _on_back_btn_pressed():
	%exitPanel.visible = true
	pass # Replace with function body.


func _on_button_pressed():
	get_tree().quit()
	pass # Replace with function body.


func _on_button_2_pressed():
	%exitPanel.visible = false
	pass # Replace with function body.
