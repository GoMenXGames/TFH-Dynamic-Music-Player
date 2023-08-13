extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	var userfolder = OS.get_user_data_dir()
	print (userfolder)
	var user = userfolder.split("/")[2]
	print (user)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_texture_button_pressed():
	get_tree().change_scene_to_file("res://control.tscn")
	pass # Replace with function body.


func _on_info_btn_pressed():
	get_tree().change_scene_to_file("res://info.tscn")
	pass # Replace with function body.
