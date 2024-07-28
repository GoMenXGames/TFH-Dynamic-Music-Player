extends Tree


# Called when the node enters the scene tree for the first time.
func _ready():
	var tree = %Tree
	var root = tree.create_item()
	tree.hide_root = true
	var child1 = tree.create_item(root)
	var child2 = tree.create_item(root)
	var subchild1 = tree.create_item(child1)
	subchild1.set_text(0, "Subchild1")

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
