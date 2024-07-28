extends Control

var version = "2.0"

var eulaPath = "user://eula"+version+".ini"
var enableLabel = LabelSettings.new()
var disableLabel = LabelSettings.new()
var LabelDisigns = [disableLabel, enableLabel]

# Called when the node enters the scene tree for the first time.
func _ready():
	
	enableLabel.font_color = Color.WHITE
	disableLabel.font_color = Color.WEB_GRAY
	%CheckBoxAgreeLabel.label_settings = LabelDisigns[0]
	%CheckBoxReShowLabel.label_settings = LabelDisigns[0]
	
	
	if checkEula():
		print("EULA TRUE!")
		_on_button_approve_pressed()
	
	get_window().size_changed.connect(resized);
	%TextDisclaimer.get_v_scroll_bar().scrolling.connect(v_scroll)
	getMaxLines()
	scroller.visibleLines = %TextDisclaimer.get_visible_line_count()
	
	print_debug(get_viewport().size)
	if get_window().content_scale_mode == Window.CONTENT_SCALE_MODE_DISABLED:
		get_window().size = Vector2(880, 600)
	get_window().position = Vector2(
		DisplayServer.screen_get_size(-1).x/2-get_window().size.x/2,
		DisplayServer.screen_get_size(-1).y/2-get_window().size.y/2
		)
	_on_lang_switch_toggled(false)
	pass # Replace with function body.

func checkEula():
	if FileAccess.file_exists(eulaPath):
		print("file exitst")
		var file = FileAccess.open(eulaPath,FileAccess.READ)
		var eulaFile = file.get_var()
		print(eulaFile)
		if eulaFile.contains("true"):
			print("true")
			return true
	else:
		return false

func _on_button_approve_pressed():
	
	if %CheckBoxReShow.button_pressed:
		var file = FileAccess.open(eulaPath,FileAccess.WRITE)
		file.store_var("eula = true")
		file = null
	get_tree().change_scene_to_file("res://mainmenu.tscn")
	pass # Replace with function body.


func _on_button_deny_pressed():
	get_tree().quit()
	pass # Replace with function body.



var scroller = {
  'maxLines': 0,
  'visibleLines':0,
  'vScrollPos':0
}

func _unhandled_input(event):
	if (event is InputEventMouseButton):
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				print("up")
				v_scroll()
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				print("down")
				v_scroll()

func getMaxLines():
	scroller.maxLines = 0
	for line in %TextDisclaimer.get_line_count():
		var curLine = %TextDisclaimer.get_line_wrap_count(line)
		scroller.maxLines += curLine+1

func v_scroll():
	getMaxLines()
	scroller.visibleLines = %TextDisclaimer.get_visible_line_count()
	var __temp = %TextDisclaimer.get_visible_line_count()
	print_debug("test1:", scroller.maxLines, " < " , __temp)
	print_debug("test2:", scroller.maxLines, "<=", scroller.vScrollPos + scroller.visibleLines)
	scroller.vScrollPos = %TextDisclaimer.scroll_vertical
#  output, " " , output[1]-output[0]+1
#  output = [get_visible_line_count(), get_last_unhidden_line(), get_line_count(), scroll_vertical]
	print_debug(scroller)
	if true or scroller.maxLines <= scroller.vScrollPos + scroller.visibleLines or scroller.maxLines <= __temp:
#		print("You on bottom!!!")
		%CheckBoxAgree.disabled = false
		%CheckBoxAgreeLabel.label_settings = LabelDisigns[int(!false)]
	else:
		%CheckBoxAgree.disabled = true
		%CheckBoxAgreeLabel.label_settings = LabelDisigns[int(!true)]
		%CheckBoxAgree.button_pressed = false
  
func resized():
	print("resize! ", %TextDisclaimer.get_visible_line_count())
	getMaxLines()
	scroller.visibleLines = %TextDisclaimer.get_visible_line_count()
	v_scroll()
	wait(3)

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds)
	v_scroll()

func _on_caret_changed():
	v_scroll()


func _on_check_box_agree_toggled(button_pressed):
	%CheckBoxReShow.disabled = !button_pressed
	%CheckBoxReShowLabel.label_settings = LabelDisigns[int(button_pressed)]
	%ButtonApprove.disabled = !button_pressed
	
	if !button_pressed:
		%CheckBoxReShow.button_pressed = false
	pass # Replace with function body.


func _on_lang_switch_toggled(button_pressed): #TRUE is RUS | FALSE is ENG
	%ButtonApprove.text = language[0][int(!button_pressed)]
	%ButtonDeny.text = language[1][int(!button_pressed)]
	%Label.text = language[2][int(!button_pressed)]
	%CheckBoxAgreeLabel.text = language[3][int(!button_pressed)]
	%CheckBoxReShowLabel.text = language[4][int(!button_pressed)]
	%ButtonDeny.tooltip_text = language[5][int(!button_pressed)]
	%TextDisclaimer.text = language[6][int(!button_pressed)]
	%ButtonApprove.tooltip_text = language[7][int(!button_pressed)]
	pass # Replace with function body.




var eulaENG = "1. This program does not steal these soundtracks, and they do not relate in any way and do not belong to the developers of this program, because everything was purchased on the Steam and used from the licensed digital version of the game, which belongs to Mane6, published by Modus aka Maximum Entertainment, in addition to the licensed official soundtrack, which belong to RainbowCrash88 aka Stuart Ferguson & Whitetail.
2. This program does not use these soundtracks for its own benefit. The developers of this program are only trying to show people the concept of good dynamic music, and in no case are they trying to make money on it, all so that you can enjoy the work of RainbowCrash88 aka Stuart Ferguson & Whitetail, and most importantly show other games what they need to strive for.
3. This program tries to show this hard work on the soundtrack, so that it will be noticed by many people, because this work deserves more attention, and can compete with many composers. But due to the fact that the game is not very popular and is at the stage of “fading out”, it becomes very sad for that hard work that they done.
4. The developers of this program will not receive a legal action because this program does not illegally distribute music from Them’s Fightin’ Herds, we will only be glad if you officially buy their soundtrack, we have made a websites button in “INFO” where you can purchase them.
5. The developers of this program love Them's Fightin’ Herds and most importantly appreciate the hard work done on it. The developers of this program are the most ordinary players and part of the Them's Fightin’ Herds community, who are trying to prolong the life of this game in any possible way!
"

var eulaRUS = "1. Эта программа не ворует данные саундтреки, и они никак не относятся и не принадлежат разработчикам данной программы, т.к. всё было приобретено на Steam площадке и использовано из лицензионной цифровой версии игры, которая принадлежит Mane6, издательством которой являются Modus аля Maximum Entertainment, в придачу с лицензионным официальным саундтреком, которые принадлежат RainbowCrash88 аля Стюарт Фергюсон и Whitetail.
2. Эта программа не использует данные саундтреки в целях своей выгоды. Разработчики данной программы лишь пытаются показать людям, сам концепт хорошей динамической музыки, и ни в коем случае не пытаются заработать на этом, всё ради того, чтобы можно было наслаждаться творчеством RainbowCrash88 аля Стюарт Фергюсон и Whitetail, и что самое главное показать другим играм, к чему нужно стремиться.
3. Эта программа пытается показать эту усердную работу над саундтреком, для того, чтобы она была замечена многим людям, т.к. данная работа заслуживает большего внимания, и может тягаться со многими композиторами. Но в силу того, что игра не слишком популярна и находится на этапе “затухания”, становится очень грустно за ту усердную работу, которую они проделали.
4. Разработчики этой программы не получат судебного иска т.к. эта программа не незаконно распространяет музыку из Them’s Fightin’ Herds, мы будем только рады если вы официально купите их саундтрек, мы сделали кнопку сайтов в “INFO”, где вы можете их приобрести.
5. Разработчики данной программы любят Them’s Fightin’ Herds и что самое главное ценят проделанную усердную работу над ней. Разработчики данной программы являются самыми обычными игроками и частью комьюнити Them’s Fightin’ Herds, которые пытаются продлить жизнь данной игре любыми всеми возможными способами!
"

var language = [
	["Принять" , "Accept"], #0
	["Отказаться" ,"Refuse"], #1
	["ДИСКЛЕЙМЕР" ,"DISCLAIMER"], #2
	["Я согласен со всем вышесказанным" , "I agree with all of the above"], #3
	["Не показывать это снова" , "Don't show this again"], #4
	["и закрыть программу", "and close program"], #5
	[eulaRUS, eulaENG], #6
	["и насладиться хорошей музыкой", "and enjoy good music"], #7
]




func _on_size_flags_changed():
	resized()
	pass # Replace with function body.
