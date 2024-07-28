extends MenuButton

var struct = {
	'text': "title",
	'submenus': [
		{
			'title': 'fullDMS',
			'submenus': [],
			'items': ["ari", "ole", "pap", "pom", "tian", "txs", "velv", "shan"]
		},
		{
			'title': 'semiDMS',
			'submenus': [],
			'items': ["stg", "hwf", "training"]
		},
		{
			'title': 'other',
			'submenus': [],
			'items': ["canyon", "cave", "temple", "salt_mine", "bear"]
		}
	]
}


func _ready():
	genMenu()

func genMenu():
	var popup = get_popup()
	text = struct.text
	for submenu in struct.submenus:
		var temp = PopupMenu.new()
		temp.set_name(submenu.title)
		var index = 0
		for item in submenu.items:
			var img = load("res://src/img/icons/mini/" + item + ".png");
			var title = ""
			if img == null:
				title = item
			temp.add_icon_item(img, title)
			index += 1
		popup.add_child(temp)
		popup.add_submenu_item(submenu.title, submenu.title)
		print(submenu.title)
	
func changeName(name):
	pass
