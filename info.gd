extends Control

var language = ["en_US","ru_RU"]

var textArr = ["All the music used in this app is entirely owned by RainbowCrash88 & Whitetail.

This application was created in order to show how much work was done by the composers in Them's Fightin' Herds, in terms of dynamic music. It will be a discovery for new listeners, and for those who already know about it, they will be able to use this application to listen to their favorite tracks. You can also combine character themes. We recommend using headphones.

P.S.
This application was built strictly on the use of game files to achieve maximum purity of tracks.
In this application, the locks on the icons mean that there are no such tracks in the game files, or I just didn't find it :/", "Вся музыка использованная в этом приложении полностью принадлежит RainbowCrash88 и Whitetail.

Данное приложение было создано для того, чтобы показать, насколько сильно была проделана работа композиторов в Them’s Fightin' Herds, в плане динамической музыки. Для новых слушателей это будет открытием, а для тех, кто уже знает про это, сможет использовать данное приложение для прослушивания своих любимых треков. Вы так же можете комбинировать темы персонажей. Рекомендуем использовать наушники.

P.S.
Данное приложении было построено строго на использовании файлов игры, чтобы достичь максимальной чистоты треков.
В данном приложение замочки на иконках означают, что таких треков в файлах игры нет, или же я просто не доглядел :/"]


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_texture_button_pressed():
	get_tree().change_scene_to_file("res://mainmenu.tscn")
	pass # Replace with function body.


func _on_lang_switch_toggled(button_pressed):
	var text = %Label
	print(text.language)
	%Label.text = textArr[int(button_pressed)]
	pass # Replace with function body.
