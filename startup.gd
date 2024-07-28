extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	
	print(ProjectSettings.get_setting("display/window/stretch/mode"))
	
	get_window().size = Vector2(320,180);
	get_window().position = Vector2(
		DisplayServer.screen_get_size(-1).x/2-get_window().size.x/2,
		DisplayServer.screen_get_size(-1).y/2-get_window().size.y/2
		)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


var lowResModePath = "user://lowResMode.ini"



func updSizesFile(): #Файл+
	print("Save somthing in " + lowResModePath)
	var file = FileAccess.open(lowResModePath, FileAccess.WRITE)
	var content = {
		'width': %width.value,
		'height': %height.value
	};
	file.store_var(content)
	file = null


func checkLowResMode():
	if FileAccess.file_exists(lowResModePath):
		print("file exitst")
		var file = FileAccess.open(lowResModePath,FileAccess.READ)
		var lowResModeFile = file.get_var()
		print_debug(lowResModePath)
		%width.value = lowResModeFile["width"]
		%height.value = lowResModeFile["height"]

var global

func _on_button_pressed():
	if %lowRes.button_pressed:
		get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
		get_window().content_scale_size = Vector2(%width.value,%height.value)
		get_window().size = Vector2(%width.value,%height.value)
		updSizesFile()
		
	else:
		get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	
	get_tree().change_scene_to_file("res://eula.tscn")
	pass # Replace with function body.


func _on_check_button_toggled(button_pressed):
	%resEdit.visible = button_pressed
	checkLowResMode()
	pass # Replace with function body.
