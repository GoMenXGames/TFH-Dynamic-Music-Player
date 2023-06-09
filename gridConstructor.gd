extends GridContainer
#
#const BUS_LAYOUT: String = "res://default_bus_layout.tres"


var mapBased = ["idle", "static"]
var arrChar = "velv tian ole ari pap pom shan txs stg"
var sectionNames = ["s1","s2","kc"]
var arrMaps = "ari ole pap pom tian txs velv shan"

var repeatArr = ["playOnce", "repeat", "repeatOne"]

var audioFiles = []

var last_btn = "none"
var map = "none"
var section = "none"

var time = 0
var isPlaying = false
var repeat = 0
var playTime = 160.0
var solo = 0
var minVol = -50
var speed = 1
var debuffVol = 0

var sliderIsDrag = false

### Генерация
#Static & Idle buttons
func genMapBasedBtn():
	var btns = mapBased
	for btn in btns:
		var newBtn = TextureButton.new()
		#Технический
		newBtn.toggle_mode = true
		newBtn.disabled = true
		newBtn.name = "btn_" + btn
		newBtn.pressed.connect(btn_pressed.bind(btn))
		#Визуал
		newBtn.texture_pressed = load("res://src/img/icons/"+btn+".png");
		newBtn.texture_normal = load("res://src/img/icons/"+btn+"_gray.png");
		newBtn.texture_disabled = load("res://src/img/icons/"+btn+"_lock.png");
		newBtn.add_to_group("g_music_btn")
		%map_based.add_child(newBtn)

#All char's buttons
func genCharBtn():
	var chars = arrChar.split(" ")
	for char in chars:
		var newBtn = TextureButton.new()
		#Технический
		newBtn.toggle_mode = true
		newBtn.disabled = true
		newBtn.name = "btn_" + char
		newBtn.pressed.connect(btn_pressed.bind(char))
		#Визуал
		newBtn.texture_pressed = load("res://src/img/icons/"+char+".png");
		newBtn.texture_normal = load("res://src/img/icons/"+char+"_gray.png");
		newBtn.texture_disabled = load("res://src/img/icons/"+char+"_lock.png");
		newBtn.add_to_group("g_music_btn")
		self.add_child(newBtn)

#All char's buttons
func genCharMixer():
	var container = %VolumeMixer
	var chars = ("all idle static "+arrChar).split(" ")
	for char in chars:
		#VBoxContainer
		var newVBox = VBoxContainer.new()
		newVBox.name = "vbox_" + char
		
		#Image
		var newImg = TextureRect.new()
		newImg.name = "img_" + char
		newImg.texture = load("res://src/img/icons/volume/"+char+".png");
		newVBox.add_child(newImg)
		
		#Slider
		var newSlider = HSlider.new()
		newSlider.name = "volSlider_" + char
		newSlider.value_changed.connect(volumeChanged.bind(char))
		newSlider.scrollable = false
		#Volume
		newSlider.min_value = minVol
		newSlider.max_value = 0
		newSlider.step = 0.01
		
		newSlider.value = 0
		
		newVBox.add_child(newSlider)
		
		#MainConnect
		newSlider.add_to_group("volumeSliders")
		container.add_child(newVBox)



###
# Called when the node enters the scene tree for the first time.
func _ready():
	genMapBasedBtn() # Static and Idle
	genCharBtn() # create chars
	genCharMixer() # create chars
	loadMaps() #bg change
	getNameSect(%section_option.selected)
	checkBtns()

func loadMaps(): # BG change 
	var maps = arrMaps.split(" ")
	for map in maps:
		#Визуал
		var img = load("res://src/img/icons/mini/" + map + ".png");
		%map_option.add_icon_item(img, "")
	
	var mapIcon = %map_option.get_item_icon(%map_option.selected)
	var iconPath = mapIcon.resource_path.split("/")
	var size = iconPath.size()
	var iconName = iconPath[size-1].split(".")[0]
	
	print(DirAccess.get_files_at("res://src/img/maps/" + iconName))
	var allowedMaps = DirAccess.get_files_at("res://src/img/maps/" + iconName)
#	var rngName = ".import"
##	while rngName.contains("import"):
	var rngName = allowedMaps[randi_range(0,allowedMaps.size()-1)]
	print(rngName)
	%bg.texture = load("res://src/img/maps/"+ iconName + "/"+ rngName.split(".import")[0])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	%timeNow.text = getTime()
	if isPlaying:
		if !sliderIsDrag:
			%slider_timeline.value = time
		%timeNow.text = getTime()
		if playTime <= time:
			time = 0
			if repeat == 1:
				restart()
			elif repeat == 2:
				_on_fast_btn_pressed()
#				restart()
			else:
				%playBtn.button_pressed = false
				
		time = time + (delta * speed)
	
	pass

###Tech

func changeLevel(id):
	var mapIcon = %map_option.get_item_icon(id)
	var iconPath = mapIcon.resource_path.split("/")
	var size = iconPath.size()
	var iconName = iconPath[size-1].split(".")[0]
	print_debug(iconName)
	
	print(DirAccess.get_files_at("res://src/img/maps/" + iconName))
	var allowedMaps = DirAccess.get_files_at("res://src/img/maps/" + iconName)
	var rngName = ".import"
#	while rngName.contains("import"):
	rngName = allowedMaps[randi_range(0,allowedMaps.size()-1)]
	print(rngName)
	%bg.texture = load("res://src/img/maps/"+ iconName + "/"+ rngName.split(".import")[0])
	

func getTime():
	var sec = fmod(time, 60.0)
	var min = (time - sec) / 60
	var strTime = str(min) + ":" + str(floor(sec)).pad_zeros(2)
	return strTime

func getNameSect(id): #Получить имя перса по имини
	return sectionNames[id]

func getMapName(): #Получить имя карты
	var mapIcon = %map_option.get_item_icon(%map_option.get_selected_id())
	var iconPath = mapIcon.resource_path.split("/")
	var size = iconPath.size()
	var mapName = iconPath[size-1].split(".")[0]
	return mapName

func getBtn(name): #Получить кнопку по имени
	var btns = get_tree().get_nodes_in_group("g_music_btn")
	for btn in btns:
		if btn.name.split("_")[1] == name:
			return btn

func resetBtns(name):
	map = getMapName()
	section = getNameSect(%section_option.selected)
	var btns = get_tree().get_nodes_in_group("g_music_btn")
	for btn in btns:
		var btnName = btn.name.split("_")[1]
		var path = "res://src/music/"+map+"/"+section+"/"+map+"_"+btnName+"_"+section+".wav.import"
		if  not btn.name.split("_")[1] == name:
			btn.button_pressed = false 

func checkBtns():
	map = getMapName()
	section = getNameSect(%section_option.selected)
	var btns = get_tree().get_nodes_in_group("g_music_btn")
	for btn in btns:
		var btnName = btn.name.split("_")[1]
		var path = "res://src/music/"+map+"/"+section+"/"+map+"_"+btnName+"_"+section+".wav.import"
		if FileAccess.file_exists(path):
			btn.disabled = false
		else: 
			btn.disabled = true

func btn_pressed (name): #При нажатии кнопки персонажа
	map = getMapName()
	section = getNameSect(%section_option.selected)
	print(map, " ", name, " ", section)
	var state = getBtn(name)
	print(state.button_pressed)
	if state.button_pressed:
		if solo == 1:
			print("soloMix")
			%playBtn.button_pressed = true
			resetBtns("none")
			clearAudio()
			print (soloPlaylist, " + ", name)
			var _playlist = []
			print (soloPlaylist, " + ", name)
			for song in soloPlaylist:
				_playlist.append(song)
			print (soloPlaylist, " + ", name)
			_playlist.append(name)
			print (soloPlaylist, " + ", name)
			loadPlaylist(_playlist)
		elif solo == 2:
			print("solo")
			%playBtn.button_pressed = true
			resetBtns(name)
			clearAudio()
			createAudio(name)
		else:
			print("create")
			createAudio(name)
	else:
		if solo == 1:
			var newSoloPlaylist = []
			for song in soloPlaylist:
				if song != name:
					newSoloPlaylist.append(song)
			soloPlaylist = newSoloPlaylist
				
		print("destroy")
		last_btn = "none"
		removeAudio(name)
	volumeChanged(getCharVol("all").value, "all")

### Sound func's

func loadPlaylist(playlist):
	print_debug(playlist)
	for song in playlist:
		var btns = get_tree().get_nodes_in_group("g_music_btn")
		for btn in btns:
			if btn.name.split("_")[1] == song:
				btn.button_pressed = true
		createAudio(song)

func restart():
	play()

func play():
	var playlist = getPlaylist()
#	print_debug(playlist)
	for song in playlist:
		print(song.name, " | ", time)
		song.play(time)
	
func pause():
	var playlist = getPlaylist()
	for song in playlist:
		song.stop()

func restartSolo(name):
	var playlist = getPlaylist()
	print_debug(playlist)
	for song in playlist:
		song.free()
		
	if last_btn != "none":
		createAudio(name)
	play()
	

func createAudio(char): # [v] Создать звуковой файл 
	var newAudio = AudioStreamPlayer.new()
	newAudio.name = "audioPlayer_" + map + "_" + char + "_" + section
	var path = "res://src/music/"+map+"/"+section+"/"+map+"_"+char+"_"+section+".wav"
	newAudio.stream = load(path)
	#print_debug(newAudio.stream)
	if !newAudio.stream: #Проверка на существование файла
		var dialog = %AcceptDialog
		dialog.dialog_text = path + " \n Is not exist!"
#		dialog.show()
		getBtn(char).button_pressed = false
	else:
		last_btn = char
		playTime = newAudio.stream.get_length() #Получить время трека
		var volume = getCharVol(char).value
		newAudio.volume_db = volume
		newAudio.pitch_scale = speed
		
		%slider_timeline.max_value = playTime
		%MasterAudio.add_child(newAudio) #Создать
		newAudio.add_to_group("playlist")
		#addPlaylist(path) #Добавить в плэйлист
		if isPlaying:
			restart()
		
	pass

func removeAudio(name): #Удалить файл
	var elem = %MasterAudio.get_node("audioPlayer_" + map + "_" + name + "_" + section)
	print_debug(elem," = ",typeof(elem))
	if typeof(elem) != 24:
		print("fuck")
	else:
		elem.free()

func rewind(value): #Rewind all playlist on value
	var playlist = getPlaylist()
	for song in playlist:
		song.seek(value)
	pass

func getPlaylist(): #Получаем список музыкальных нодов
	var playlist = %MasterAudio.get_tree().get_nodes_in_group("playlist")
	return playlist

func clearAudio():
	var playlist = getPlaylist()
	for song in playlist:
		song.free()
		

func changePlaySpeed():
	var playlist = getPlaylist()
	for song in playlist:
		song.pitch_scale = speed 

func changeVolume(db):
	var playlist = getPlaylist()
	print_debug(playlist)
	for song in playlist:
		print(song.name, " | ", time)
		song.volume_db = db 

func setTime(value):
	time = value
	%timeNow.text = getTime()
	%slider_timeline.value = time

func switchAudio():
	var playlist = getPlaylist()
	var newPlaylist = []
	for song in playlist:
		newPlaylist.append(song.name.split("_")[2])
	print(newPlaylist)
	clearAudio()
	for song in newPlaylist:
		createAudio(song)


func getCharVol(char):
	var vol_sliders = get_tree().get_nodes_in_group("volumeSliders")
	for slider in vol_sliders:
		if slider.name.split("_")[1] == char:
			print(slider.name)
			return slider

func volumeChanged(dbValue, char):
	if (dbValue < -49):
		dbValue = -99999
	print("change vol:" + char)
	if char == "all":
		var countChars = %MasterAudio.get_child_count()
		print (dbValue, " ", debuffVol, " ", countChars)
		var db = dbValue - (debuffVol * countChars)
		print(dbValue - (debuffVol * countChars))
		AudioServer.set_bus_volume_db(0,db)
		print(dbValue)
	else:
		var db = dbValue
		changeCharVol(char,db)

func changeCharVol(char,db):
	var playlist = getPlaylist()
	var audio
	for song in playlist:
		if (song.name.split("_")[2]) == char:
			print(db)
			song.volume_db = db

var soloPlaylist = []
func createPlaylist():
	var playlist = getPlaylist()
	soloPlaylist = []
	for song in playlist:
		soloPlaylist.append(song.name.split("_")[2])
	print(soloPlaylist)

### clickble

func _on_slider_timeline_value_changed(value):
	sliderIsDrag = false
	time = %slider_timeline.value
	rewind(time)
	pass # Replace with function body.

func _on_play_btn_toggled(button_pressed):
	isPlaying = button_pressed
	if isPlaying:
		play()
	else:
		pause()
	pass # Replace with function body.


func _on_check_repeat_toggled():
#	print(repeatArr.size(), ", ", repeat)
	if repeatArr.size() > repeat+1:
#		print("+1")
		repeat = repeat + 1
	else:
#		print("=0")
		repeat = 0
	print(repeatArr[repeat])
	%check_repeat.texture_normal = load("res://src/img/ui/icons/"+repeatArr[repeat]+".png")
	pass # Replace with function body.

var soloArr = ["lock_white", "lock_green", "lock_red"]

func _on_check_solo_pressed():
	if soloArr.size() > solo+1:
#		print("+1")
		solo = solo + 1
	else:
#		print("=0")
		solo = 0
	print(soloArr[solo])
	%check_solo.texture_normal = load("res://src/img/ui/icons/"+soloArr[solo]+".png")
	if solo == 1:
		print("btn_solo")
		createPlaylist()
	if solo == 2:
		resetBtns(last_btn)
		restartSolo(last_btn)
	pass # Replace with function body.


func _on_slider_timeline_drag_started():
	sliderIsDrag = true
	pass # Replace with function body.


func _on_mute_btn_toggled(button_pressed):
	if button_pressed:
		%volumeMixContainer.show()
	else:
		%volumeMixContainer.hide()
	pass # Replace with function body.


func _on_map_option_item_selected(index):
	setTime(0)
	changeLevel(index)
	checkBtns()
	switchAudio()
#	%playBtn.button_pressed = false
	pass # Replace with function body.

func _on_sect_change(index):
	setTime(0)
	checkBtns()
	switchAudio()
#	%playBtn.button_pressed = false

func _on_forward_btn_pressed():
	print(%map_option.item_count, ": ", %map_option.selected)
	if %map_option.item_count > %map_option.selected+1:
		%map_option.select(%map_option.selected+1)
	else:
		%map_option.select(0)
	_on_map_option_item_selected(%map_option.selected)
	pass # Replace with function body.
	
func _on_fast_btn_pressed():
	print(%section_option.item_count, ": ", %section_option.selected)
	if %section_option.item_count > %section_option.selected+1:
		%section_option.select(%section_option.selected+1)
	else:
		%section_option.select(0)
	_on_sect_change(%section_option.selected)
	pass # Replace with function body.

func _on_back_btn_pressed():
	print(%map_option.item_count, ": ", %map_option.selected)
	if %map_option.selected > 0:
		%map_option.select(%map_option.selected-1)
	else:
		%map_option.select(%map_option.item_count-1)
	_on_map_option_item_selected(%map_option.selected)
	pass # Replace with function body.
	
func _on_slow_btn_pressed():
	print(%section_option.item_count, ": ", %section_option.selected)
	if %section_option.selected > 0:
		%section_option.select(%section_option.selected-1)
	else:
		%section_option.select(%section_option.item_count-1)
	_on_sect_change(%section_option.selected)
	pass # Replace with function body.



func _on_stop_btn_pressed():
	resetBtns("none")
	clearAudio()
	%playBtn.button_pressed = false
	setTime(0)
	pass # Replace with function body.


func _on_quit_btn_pressed():
	get_tree().change_scene_to_file("res://mainmenu.tscn")
	pass # Replace with function body.


func _on_option_btn_toggled(button_pressed):
	if button_pressed:
		%additionConfigContainer.show()
	else:
		%additionConfigContainer.hide()
	
	pass # Replace with function body.


func _on_volume_fix_toggled(button_pressed):
	if button_pressed:
		debuffVol = 1
	else:
		debuffVol = 0
	volumeChanged(getCharVol("all").value, "all")
	pass # Replace with function body.


func _on_speed_slider_value_changed(value):
	speed = value/100
	%speedLabel.text = "Speed (x"+str(speed)+")"
	%MasterAudio.pitch_scale = speed
	changePlaySpeed()
	pass # Replace with function body.
