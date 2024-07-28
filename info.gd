extends Control

var language = ["en_US","ru_RU"]

var btnArr = [
	[ "Buy soundtracks in Steam","Buy soundtracks in bandcamp.com"],
	["Купить саундтреки в Steam","Купить саундтреки в bandcamp.com"]
]

var textArr = [
	["All the music used in this app is entirely owned by RainbowCrash88 aka Stuart Ferguson & Whitetail.",
"This application was created in order to show how much work was done by the composers in Them's Fightin' Herds, in terms of dynamic music. It will be a discovery for new listeners, and for those who already know about it, they will be able to use this application to listen to their favorite tracks. You can also combine character themes. We recommend using headphones.

P.S.
This application was built strictly on the use of game files to achieve maximum purity of tracks.
In this application, the locks on the icons mean that there are no such tracks in the game files, or I just didn't find it :/

P.P.S. 
Bronze icons means that track was recorded in game.

NOT AN OFFICIAL Them's Fightin' Herds PRODUCT.
NOT APPROVED BY OR ASSOCIATED WITH MANE6 OR MODUS AKA MAXIMUM ENTERTAIMENT."],

["Вся музыка использованная в этом приложении полностью принадлежит RainbowCrash88 аля Стюарт Фергюсон и Whitetail.",

"Данное приложение было создано для того, чтобы показать, насколько сильно была проделана работа композиторов в Them’s Fightin' Herds, в плане динамической музыки. Для новых слушателей это будет открытием, а для тех, кто уже знает про это, сможет использовать данное приложение для прослушивания своих любимых треков. Вы так же можете комбинировать темы персонажей. Рекомендуем использовать наушники.

P.S.
Данное приложении было построено строго на использовании файлов игры, чтобы достичь максимальной чистоты треков.
В данном приложение замочки на иконках означают, что таких треков в файлах игры нет, или же я просто не доглядел :/

P.P.S. 
Бронзовые иконки означают, что треки были записаны в игре.

НЕ ЯВЛЯЕТСЯ ОФИЦИАЛЬНЫМ ПРОДУКТОМ Them's Fightin' Herds.
НЕ ОДОБРЕНО И НЕ СВЯЗАНО С КОМПАНИЕЙ MANE6 ИЛИ MODUS АЛЯ MAXIMUM ENTERTAIMENT."]]


# Called when the node enters the scene tree for the first time.
func _ready():
	get_window().position = Vector2(
		DisplayServer.screen_get_size(-1).x/2-get_window().size.x/2,
		DisplayServer.screen_get_size(-1).y/2-get_window().size.y/2
		)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_texture_button_pressed():
	get_tree().change_scene_to_file("res://mainmenu.tscn")
	pass # Replace with function body.


func _on_lang_switch_toggled(button_pressed):
	var labels = [%Label1,%Label2]
	var btns = [%btnBuySteam,%btnBuyMane6]
	for i in [0,1]:
		btns[i].text = btnArr[int(button_pressed)][i]
		labels[i].text = textArr[int(button_pressed)][i]
	pass # Replace with function body.


func _on_btn_buy_steam_pressed():
	OS.shell_open("https://store.steampowered.com/app/1144180/Thems_Fightin_Herds__Official_Soundtrack/")
	pass # Replace with function body.


func _on_btn_buy_mane_6_pressed():
	OS.shell_open("https://rc88.bandcamp.com/music")
	pass # Replace with function body.
