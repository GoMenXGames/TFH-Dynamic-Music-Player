extends GridContainer
#
#const BUS_LAYOUT: String = "res://default_bus_layout.tres"



var fullNames = ["Velvet", "Tianhuo", "Oleander", "Arizona", "Paprika", "Pom", "Shanty", "Texas", "Stronghoof"]
func getFullName(shortName):
	return fullNames[arrChar.split(" ").find(shortName)]
var sectionFullNames = ["Round 1","Round 2","Final Round"]

var mapBased = ["idle", "static"]
var arrChar = "velv tian ole ari pap pom shan txs stg"
var sectionNames = ["s1","s2","kc"]
var arrMaps = "ari ole pap pom tian txs velv shan"

var repeatArr = ["playOnce", "repeat", "repeatOne"]
var repeatArrText = [
	"The repeat of music is disabled, 
	when the song ends, 
	the pause will automatically turn on",
	"Music will be repeated
	on the same round",
	"Music will be cyclically repeated
	in the order of rounds"
]

var audioFiles = []

var last_btn = "none"
var map = "none"
var section = "none"

var username = OS.get_user_data_dir().split("/")[2]
var path_presetsFiles = "C:\\Users\\"+username+"\\Documents\\TFH Dynamic Music Player"
var presets = []

var time = 0
var isPlaying = false
var repeat = 0
var playTime = 160.0
var solo = 0
var minVol = -50
var speed = 1
var debuffVol = 0

var sliderIsDrag = false

var currTime = int(Time.get_unix_time_from_system())

###Генерация
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
		newBtn.tooltip_text = btn
		
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
		newBtn.tooltip_text = char
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
		var newImg = TextureButton.new()
		newImg.name = "img_" + char
		newImg.texture_normal = load("res://src/img/icons/volume/"+char+".png");
		newImg.pressed.connect(resetCharVol.bind(char))
		newVBox.add_child(newImg)
		newImg.tooltip_text = "Click to reset volume!"
		
		#Slider
		var newSlider = HSlider.new()
		newSlider.name = "volSlider_" + char
		newSlider.value_changed.connect(volumeChanged.bind(char))
		newSlider.scrollable = false
		#Volume
		newSlider.min_value = minVol
		newSlider.max_value = 10
		newSlider.step = 0.01
		
		newSlider.value = 0
		
		newVBox.add_child(newSlider)
		
		#MainConnect
		newSlider.add_to_group("volumeSliders")
		container.add_child(newVBox)



###
# Called when the node enters the scene tree for the first time.
func _ready():
	lastUpd = int(Time.get_unix_time_from_system())
	DirAccess.open("user://")
	if FileAccess.file_exists("user://settings.ini"):
		print("kek it works!")
		path_presetsFiles = loadSettings()
		reloadPresetList()
	else:
		%lineEdit_pathFolder.text = path_presetsFiles
		%popup_changeFolderPresets.visible = true
		print("fuck up!")
	getFolder()
	genMapBasedBtn() # Static and Idle
	genCharBtn() # create chars
	genCharMixer() # create chars
	loadMaps() #bg change
	getNameSect(%section_option.selected)
	checkBtns()
	if DirAccess.dir_exists_absolute(path_presetsFiles):
		print("folder exits")
#		presets = load_presets()
	else:
		print("Create folder")
		DirAccess.make_dir_recursive_absolute(path_presetsFiles)
	reloadPresetList() #old
	%LinkFolderPresets.uri = path_presetsFiles
	print_debug(getListFilePresets())
	
func getFolder():
	pass
	
func _notification(what):
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			discord_sdk.clear()
		NOTIFICATION_APPLICATION_FOCUS_IN:
			reloadPresetList()
			pass

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
	
#	#print(DirAccess.get_files_at("res://src/img/maps/" + iconName))
	var allowedMaps = DirAccess.get_files_at("res://src/img/maps/" + iconName)
#	var rngName = ".import"
##	while rngName.contains("import"):
	var rngName = allowedMaps[randi_range(0,allowedMaps.size()-1)]
#	#print(rngName)
	%bg.texture = load("res://src/img/maps/"+ iconName + "/"+ rngName.split(".import")[0])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	currTime = int(Time.get_unix_time_from_system())
	%timeNow.text = getTime()
	if isPlaying:
		if !sliderIsDrag:
			%slider_timeline.value = time
		%timeNow.text = getTime()
		if playTime <= time:
			time = 0
			if repeat == 1:
				restart()
				updDiscordRP()
			elif repeat == 2:
				_on_fast_btn_pressed()
				updDiscordRP()
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
	#print_debug(iconName)
	
	#print(DirAccess.get_files_at("res://src/img/maps/" + iconName))
	var allowedMaps = DirAccess.get_files_at("res://src/img/maps/" + iconName)
	var rngName = ".import"
#	while rngName.contains("import"):
	rngName = allowedMaps[randi_range(0,allowedMaps.size()-1)]
	#print(rngName)
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
			btn.texture_pressed = load("res://src/img/icons/"+btnName+".png");
			btn.texture_normal = load("res://src/img/icons/"+btnName+"_gray.png");
			btn.disabled = false
			continue
		else:
			path = "res://src/music/"+map+"/"+section+"/"+map+"_"+btnName+"_"+section+"_ig"+".wav.import"
		if FileAccess.file_exists(path):
			btn.texture_pressed = load("res://src/img/icons/"+btnName+"_bronze.png");
			btn.texture_normal = load("res://src/img/icons/"+btnName+"_bronze_gray.png");
			btn.disabled = false
		else: 
			btn.disabled = true

func btn_pressed (name): #При нажатии кнопки персонажа
	map = getMapName()
	section = getNameSect(%section_option.selected)
	#print(map, " ", name, " ", section)
	var state = getBtn(name)
	#print(state.button_pressed)
	if state.button_pressed:
		if solo == 1:
			#print("soloMix")
#			%playBtn.button_pressed = true
			resetBtns("none")
			clearAudio()
			#print (soloPlaylist, " + ", name)
			var _playlist = []
			#print (soloPlaylist, " + ", name)
			for song in soloPlaylist:
				_playlist.append(song)
			#print (soloPlaylist, " + ", name)
			_playlist.append(name)
			#print (soloPlaylist, " + ", name)
			loadPlaylist(_playlist)
		elif solo == 2:
			#print("solo")
#			%playBtn.button_pressed = true
			resetBtns(name)
			clearAudio()
			createAudio(name)
		else:
			#print("create")
			createAudio(name)
	else:
		if solo == 1:
			var newSoloPlaylist = []
			for song in soloPlaylist:
				if song != name:
					newSoloPlaylist.append(song)
			soloPlaylist = newSoloPlaylist
				
		#print("destroy")
		last_btn = "none"
		removeAudio(name)
	volumeChanged(getCharVol("all").value, "all")

### Sound func's

func loadPlaylist(playlist):
	#print_debug(playlist)
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
#	#print_debug(playlist)
	for song in playlist:
		#print(song.name, " | ", time)
		song.play(time)
	
func pause():
	var playlist = getPlaylist()
	for song in playlist:
		song.stop()

func restartSolo(name):
	var playlist = getPlaylist()
	#print_debug(playlist)
	for song in playlist:
		song.free()
		
	if last_btn != "none":
		createAudio(name)
	if isPlaying:
		play()
	

func createAudio(char): # [v] Создать звуковой файл 
	var newAudio = AudioStreamPlayer.new()
	var isBronze = getBtn(char).texture_pressed.resource_path.contains("_bronze")
	var addBronze = ""
	if isBronze:
		addBronze = "_ig"
	else:
		addBronze = ""
	newAudio.name = "audioPlayer_" + map + "_" + char + "_" + section + addBronze
	var path = "res://src/music/"+map+"/"+section+"/"+map+"_"+char+"_"+section+addBronze+".wav"
	newAudio.stream = load(path)
	##print_debug(newAudio.stream)
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
	var isBronze = getBtn(name).texture_pressed.resource_path.contains("_bronze")
	var addBronze = ""
	if isBronze:
		addBronze = "_ig"
	else:
		addBronze = ""
	var elem = %MasterAudio.get_node("audioPlayer_" + map + "_" + name + "_" + section + addBronze)
	#print_debug(elem," = ",typeof(elem))
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
	#print_debug(playlist)
	for song in playlist:
		#print(song.name, " | ", time)
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
	#print(newPlaylist)
	clearAudio()
	for song in newPlaylist:
		createAudio(song)


func getCharVol(char):
	var vol_sliders = get_tree().get_nodes_in_group("volumeSliders")
	for slider in vol_sliders:
		if slider.name.split("_")[1] == char:
			#print(slider.name)
			return slider

func resetCharVol(char):
	volumeChanged(0, char)
	var container = %VolumeMixer.get_children(false)
	var chars = ("all idle static "+arrChar).split(" ")
	var index = 0
	for volSlider in container:
		#print_debug(volSlider)
		if volSlider.name.split("_")[1] == char:
			volSlider.get_child(1).value = 0
			#print_debug(volSlider)
	

func volumeChanged(dbValue, char):
	if (dbValue < -49):
		dbValue = -99999
	#print("change vol:" + char)
	if char == "all":
		var countChars = %MasterAudio.get_child_count()
		#print (dbValue, " ", debuffVol, " ", countChars)
		var db = dbValue - (debuffVol * countChars)
		#print(dbValue - (debuffVol * countChars))
		AudioServer.set_bus_volume_db(0,db)
		#print(dbValue)
	else:
		var db = dbValue
		changeCharVol(char,db)

func changeCharVol(char,db):
	var playlist = getPlaylist()
	var audio
	for song in playlist:
		if (song.name.split("_")[2]) == char:
			#print(db)
			song.volume_db = db

var soloPlaylist = []
func createPlaylist():
	var playlist = getPlaylist()
	soloPlaylist = []
	for song in playlist:
		soloPlaylist.append(song.name.split("_")[2])
	#print(soloPlaylist)

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
		updDiscordRP()
	else:
		pause()
	pass # Replace with function body.


func _on_check_repeat_toggled():
	
#	#print(repeatArr.size(), ", ", repeat)
	if repeatArr.size() > repeat+1:
#		#print("+1")
		repeat = repeat + 1
	else:
#		#print("=0")
		repeat = 0
	#print(repeatArr[repeat])
	%check_repeat.texture_normal = load("res://src/img/ui/icons/"+repeatArr[repeat]+".png")
	%check_repeat.tooltip_text = repeatArrText[repeat]
	pass # Replace with function body.

var soloArr = ["lock_white", "lock_green", "lock_red"]
var soloArrText = [
	"You can choose as many
	music icons as you can",
	"Icons you have selected
	will remain active, 
	and you will be able to
	select an additional icon 
	that will already turn off 
	if you select another one",
	"You can select only one icon"
]

func _on_check_solo_pressed():
	if soloArr.size() > solo+1:
#		#print("+1")
		solo = solo + 1
	else:
#		#print("=0")
		solo = 0
	#print(soloArr[solo])
	%check_solo.tooltip_text = soloArrText[solo]
	%check_solo.texture_normal = load("res://src/img/ui/icons/"+soloArr[solo]+".png")
	if solo == 1:
		#print("btn_solo")
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
	updDiscordRP()
#	%playBtn.button_pressed = false
	pass # Replace with function body.

func _on_sect_change(index):
	setTime(0)
	checkBtns()
	switchAudio()
	updDiscordRP()
#	%playBtn.button_pressed = false

func _on_forward_btn_pressed():
	#print(%map_option.item_count, ": ", %map_option.selected)
	if %map_option.item_count > %map_option.selected+1:
		%map_option.select(%map_option.selected+1)
	else:
		%map_option.select(0)
	_on_map_option_item_selected(%map_option.selected)
	pass # Replace with function body.
	
func _on_fast_btn_pressed():
	#print(%section_option.item_count, ": ", %section_option.selected)
	if %section_option.item_count > %section_option.selected+1:
		%section_option.select(%section_option.selected+1)
	else:
		%section_option.select(0)
	_on_sect_change(%section_option.selected)
	pass # Replace with function body.

func _on_back_btn_pressed():
	#print(%map_option.item_count, ": ", %map_option.selected)
	if %map_option.selected > 0:
		%map_option.select(%map_option.selected-1)
	else:
		%map_option.select(%map_option.item_count-1)
	_on_map_option_item_selected(%map_option.selected)
	pass # Replace with function body.
	
func _on_slow_btn_pressed():
	#print(%section_option.item_count, ": ", %section_option.selected)
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
		%additionConfigContainer.offset_left = -233
	else:
		%additionConfigContainer.offset_left = 1000
	
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


func _on_btn_add_preset_pressed():
	var name = %edit_presetName.text
	var alreadyHas = false
	
	if %switchFileFolder.button_pressed:
		#Folder mode
		if DirAccess.dir_exists_absolute(path_presetsFiles + %PresetsPath.text + name):
			alreadyHas = true
			
		if alreadyHas:
			%AcceptDialog.position = get_screen_position()
			%AcceptDialog.dialog_text = "Folder with name \""+name+"\": already has!"
			%AcceptDialog.visible = true
		else:
			addFolder(path_presetsFiles + %PresetsPath.text + name)
			reloadPresetList()
			%popup_addPreset.visible = false
			%btn_listAddPreset.button_pressed = false
	else: 
		for preset in DirAccess.get_files_at(path_presetsFiles + %PresetsPath.text):
			if preset == name+".tfhp":
				alreadyHas = true
		
		if alreadyHas:
			%AcceptDialog.position = get_screen_position()
			%AcceptDialog.dialog_text = "Preset with name \""+name+"\": already has!"
			%AcceptDialog.visible = true
		else:
			addPreset(name)
			reloadPresetList()
			%popup_addPreset.visible = false
			%btn_listAddPreset.button_pressed = false
	pass # Replace with function body.

func addFolder(path):
	DirAccess.make_dir_absolute(path)
	
func removeFolder(path):
	print(path, " is removed!")
	OS.move_to_trash(path)
	reloadPresetList()

func preRemoveFolder(path):
	var countFiles = DirAccess.get_directories_at(path).size() + DirAccess.get_files_at(path).size()
	if countFiles > 0:
		var newWarnWindow = AcceptDialog.new()
		newWarnWindow.dialog_text = "This folder contain files or folders (~"+str(countFiles)+"),\n you sure are yo delete this?"
		newWarnWindow.ok_button_text = "Yes"
		newWarnWindow.get_ok_button().pressed.connect(removeFolder.bind(path))
		newWarnWindow.add_cancel_button("No")
		newWarnWindow.show()
		newWarnWindow.position = get_screen_position()
		%popup_addPreset.add_child(newWarnWindow)
	else: 
		removeFolder(path)


func addPreset(name):
	var preset = {}
	preset["name"] = name 
	#Additional settings
	preset["time"] = time 
	preset["volume"] = getVolumeArr()
	preset["speed"] = speed 
	preset["repeat"] = repeat 
	preset["solo"] = solo
	preset["debuffVol"] = debuffVol 
	#Music Layers
	preset["map"] = map
	preset["section"] = section
	preset["btns"] = getBtns()
	presets.append(preset)
	saveFile(name, preset)
	pass

func getVolumeArr():
	var volumes = {}
	var container = %VolumeMixer.get_children(false)
	var chars = ("all idle static "+arrChar).split(" ")
	var index = 0
	for char in chars:
		var volMeter = container[index].get_child(1).value
		print_debug(volMeter)
		volumes[char] = volMeter
		index+=1
	return volumes

func removePreset(name):
	#print("try remove " + name)
#	for id in range(presets.size()):
#		if preset[id].name == name:
#			#print("rem: ",id)
#			presets.remove_at(id)
#			reloadPresetList()
#			return
#	save(presets)
	removeFile(path_presetsFiles+%PresetsPath.text + name + ".tfhp")
	reloadPresetList()	

func getBtns():
	var pressedBtns = []
	print(pressedBtns)
	var btns = get_tree().get_nodes_in_group("g_music_btn")
	for btn in btns:
		if btn.button_pressed == true:
			pressedBtns.append(btn.name.split("_")[1])
	return pressedBtns

func selectPreset(name):
	#print("try select " + name)
	var preset = loadFile(name)
	if preset == null:
		return
	#print("select: ",id)
	resetBtns("none")
	clearAudio()
	#Main settings
	map = preset.map
	section = preset.section
	%map_option.select(arrMaps.split(" ").find(map))
	%section_option.select(sectionNames.find(section))
	changeLevel(arrMaps.split(" ").find(map))

	#additional settings
	loadVolumeSettings(preset.volume)
	
	speed = float(preset.speed)
	%speedLabel.text = "Speed (x"+str(speed)+")"
	%speedSlider.value = speed*100
	#
	time = float(preset.time)
	%timeNow.text = str(time)
	%slider_timeline.value = time
	#
	repeat = int(preset.repeat)
	%check_repeat.texture_normal = load("res://src/img/ui/icons/"+repeatArr[repeat]+".png")
	#
	solo = int(preset.solo)
	%check_solo.texture_normal = load("res://src/img/ui/icons/"+soloArr[solo]+".png")
	#
	debuffVol = preset.debuffVol 
	%volumeFix.button_pressed = debuffVol
	checkBtns()
	loadPlaylist(preset.btns)
	return

func loadVolumeSettings(volSettings):
	var volumes = volSettings
	var container = %VolumeMixer.get_children(false)
	var chars = ("all idle static "+arrChar).split(" ")
	var index = 0
	for char in chars:
		container[index].get_child(1).value = volumes[char]
		index+=1

###
func saveFile(name, content):
	print("Save somthing in " + path_presetsFiles+%PresetsPath.text + " as " + name + "\nContent: " + str(content))
	var file = FileAccess.open(path_presetsFiles+%PresetsPath.text+name+".tfhp",FileAccess.WRITE)
	file.store_var(content)
	file = null

func loadFile(name):
	print("Load somthing from " + path_presetsFiles+%PresetsPath.text + " as " + name)
	var file = FileAccess.open(path_presetsFiles+%PresetsPath.text+name+".tfhp",FileAccess.READ)
	if file == null:
		%AcceptDialog.position = get_screen_position()
		%AcceptDialog.dialog_text = str(path_presetsFiles+%PresetsPath.text+name+".tfhp" + " not correct!")
		%AcceptDialog.visible = true
	else:
		var content = file.get_var()
		return content
	
func removeFile(path):
	print("Remove file at " + path)
	OS.move_to_trash(path)

func getListFilePresets():
	return DirAccess.get_files_at(path_presetsFiles+%PresetsPath.text)

# Обновление списка пресетов
func reloadPresetList():
	%LinkFolderPresets.uri = path_presetsFiles+%PresetsPath.text
	var remList = %listPresets.get_child_count(false)
	#print(range(remList-1, 1 , -1))
	var remListAsObj = %listPresets.get_tree()
	for rem in range(remList-1, 0 , -1):
		print_debug(%listPresets.get_child(rem))
		%listPresets.get_child(rem).queue_free()
	print(getListFilePresets())
	#print(remList)
	for folder in DirAccess.get_directories_at(path_presetsFiles+%PresetsPath.text):
		var folderElem = HBoxContainer.new()
		
		var newFolder = Button.new()
		newFolder.text = folder
		newFolder.icon = load("res://src/img/ui/additions/folder.png")
		newFolder.name = "folder_" + folder
		newFolder.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		newFolder.button_up.connect(forwardFolder.bind(folder))
		folderElem.add_child(newFolder)
		
		
		var folder_remBtn = TextureButton.new()
		folder_remBtn.size_flags_horizontal = Control.SIZE_SHRINK_END
		folder_remBtn.texture_normal = load("res://src/img/ui/icons/circle_off.png")
		folder_remBtn.button_up.connect(preRemoveFolder.bind(path_presetsFiles+%PresetsPath.text+folder))
		folderElem.add_child(folder_remBtn)
		
		%listPresets.add_child(folderElem)
		
		
	for elem in getListFilePresets():
		var preset_elem = HBoxContainer.new()
		var name = elem.split(".tfhp")[0]
		
		var preset_button = Button.new()
		preset_button.icon = load("res://src/img/ui/additions/files.png")
		preset_button.text = name
		preset_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		preset_button.button_up.connect(selectPreset.bind(name))
		preset_elem.add_child(preset_button)
		
		var preset_editBtn = TextureButton.new()
		preset_editBtn.size_flags_horizontal = Control.SIZE_SHRINK_END
		preset_editBtn.texture_normal = load("res://src/img/ui/icons/repeat.png")
		preset_editBtn.button_up.connect(editPreset.bind(name))
		preset_elem.add_child(preset_editBtn)
		
		var preset_remBtn = TextureButton.new()
		preset_remBtn.size_flags_horizontal = Control.SIZE_SHRINK_END
		preset_remBtn.texture_normal = load("res://src/img/ui/icons/circle_off.png")
		preset_remBtn.button_up.connect(removePreset.bind(name))
		preset_elem.add_child(preset_remBtn)
		
		%listPresets.add_child(preset_elem)
	
func editPreset(name):
	removePreset(name)
	addPreset(name)
	reloadPresetList()

func saveSettings(content):
	var path = "user://settings.ini"
	var file = FileAccess.open(path,FileAccess.WRITE)
	file.store_var(content)
	file = null
	pass

func loadSettings():
	var path = "user://settings.ini"
	FileAccess.file_exists(path)
	var file = FileAccess.open(path,FileAccess.READ)
	if file == null:
		print ("error", path)
		pass
		#%AcceptDialog.position = get_screen_position()
		#%AcceptDialog.dialog_text = str(path_presetsFiles+%PresetsPath.text+name+".tfhp" + " not correct!")
		#%AcceptDialog.visible = true
	else:
		var content = file.get_var()
		return content
	pass

func _on_btn_list_add_preset_pressed(toggle):
	%popup_addPreset.visible = toggle
	%edit_presetName.text = "new_preset"
	pass # Replace with function body.


func _on_open_presets_toggled(button_pressed):
	%presets_window.visible = button_pressed
	
	reloadPresetList()
	pass # Replace with function body.


func _on_close_presets_window_pressed():
	%openPresets.button_pressed = false
	%presets_window.visible = false
	pass # Replace with function body.


func _on_back_folder_pressed():
	if %PresetsPath.text == "/":
		pass
	else:
		var oldPath = %PresetsPath.text.trim_suffix("/").split("/")
		oldPath.remove_at(oldPath.size()-1)
		var newPath = ""
		for folder in oldPath:
			if folder != "":
				newPath += "/" + folder
		%PresetsPath.text = newPath + "/"
	reloadPresetList()
	pass # Replace with function body.

func forwardFolder(folder):
	var oldPath = %PresetsPath.text
	var newPath = oldPath + folder + "/"
	%PresetsPath.text = newPath
	reloadPresetList()
	pass # Replace with function body.


func _on_btn_select_folder_pressed():
	var text = %lineEdit_pathFolder.text
	print (DirAccess.dir_exists_absolute(text))
	if text != "" and DirAccess.dir_exists_absolute(text):
		path_presetsFiles = text
		saveSettings(path_presetsFiles)
		%PresetsPath.text = "/"
		reloadPresetList()
		%popup_changeFolderPresets.visible = false
	pass # Replace with function body.


func _on_btn_change_folder_presets_pressed():
	%lineEdit_pathFolder.text = path_presetsFiles
	%popup_changeFolderPresets.visible = true
	pass # Replace with function body.


func _on_btn_close_add_preset_pressed():
	%popup_addPreset.visible = false
	pass # Replace with function body.

var lastUpd = 0

func updDiscordRP():
	if lastUpd + 30 < currTime:
		lastUpd = int(Time.get_unix_time_from_system())
	else:
		print("too time nearly!!!")
	if isPlaying:
		discordAPI()

func discordAPI():
	discord_sdk.clear()
	# Application ID
	discord_sdk.app_id = 1142132069162565682
	# this is boolean if everything worked
#	print("Discord working: " + str(discord_sdk.get_is_discord_working()))
	# Set the first custom text row of the activity here
	discord_sdk.details = "Enjoying good music!"
#	print(discord_sdk.details)
	# Set the second custom text row of the activity here
	discord_sdk.state = getFullName(map) + " | " + sectionFullNames[sectionNames.find(section)]
#	print(discord_sdk.state)
	# Image key for small image from "Art Assets" from the Discord Developer website
	discord_sdk.large_image = "albumlogo"
	# Tooltip text for the large image
	discord_sdk.large_image_text = "TFH: Dynamic Music Player"
	# Image key for large image from "Art Assets" from the Discord Developer website
	discord_sdk.small_image = map
##     # Tooltip text for the small image
	discord_sdk.small_image_text = getFullName(map)
#	print(discord_sdk.small_image_text)
##     # "02:41 elapsed" timestamp for the activity
	discord_sdk.start_timestamp = int(Time.get_unix_time_from_system()) + time
##     # Always refresh after changing the values!
	print("Upd!")
	discord_sdk.refresh()
