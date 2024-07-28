extends TextureButton

var modes = [Window.MODE_WINDOWED, Window.MODE_FULLSCREEN]

# Called when the node enters the scene tree for the first time.
func _ready():
	button_pressed = get_window().mode == modes[1]
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_toggled(button_pressed):
	get_window().mode = modes[int(button_pressed)] 
	
	pass # Replace with function body.
