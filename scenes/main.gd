extends Node

const CONFIG_CATEGORY := "settings"
const CONFIG_PATH := "user://settings.cfg"
const SAVE_PATH := "user://save.data"

export var debug := true

onready var game := $Game
onready var menu := $MainMenuLayer/MainMenu

var config_version := 0
var save_version := 0

func _ready():
	randomize()
	menu.connect("game_quit", self, "quit_game")
	load_config()
	load_game()

func game_started():
	game.start_game()

func game_ended():
	menu.start_menu()

func save_game():
	var save_file = File.new()
	save_file.open(SAVE_PATH, File.WRITE)
	var save_data = {
		"version" : save_version,
		"highscores" : ScoreManager.highscore_list
	}
	save_file.store_var(save_data)
	save_file.close()

func load_game():
	var save_file = File.new()
	if not save_file.file_exists(SAVE_PATH):
		return
	save_file.open(SAVE_PATH, File.READ)
	var save_data = save_file.get_var()
	ScoreManager.highscore_list = save_data.get("highscores", ScoreManager.highscore_list)
	save_file.close()

func save_config():
	var config = ConfigFile.new()
	config.set_value(CONFIG_CATEGORY, "version", config_version)
	config.set_value(CONFIG_CATEGORY, "sound_volume",
		db2linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Sound"))))
	config.set_value(CONFIG_CATEGORY, "music_volume",
		db2linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))))
	config.set_value(CONFIG_CATEGORY, "fullscreen", OS.window_fullscreen)
	config.save(CONFIG_PATH)

func load_config():
	var config = ConfigFile.new()
	var error = config.load(CONFIG_PATH)
	if error != OK:
		return
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound"),
		linear2db(config.get_value(CONFIG_CATEGORY, "sound_volume", 1.0)))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),
		linear2db(config.get_value(CONFIG_CATEGORY, "music_volume", 1.0)))
	OS.window_fullscreen = config.get_value(CONFIG_CATEGORY, "fullscreen", false)

func quit_game():
	save_config()
	save_game()
	get_tree().quit()

# Debug inputs for testing
func _input(event):
	if !debug:
		return
	if event is InputEventKey:
		if event.pressed:
			if event.scancode == KEY_R:
				Engine.time_scale = 25.0
			if event.scancode == KEY_T:
				Engine.time_scale = 0.1
			if event.scancode == KEY_P:
				ScoreManager.score += 100
		else:
			if event.scancode == KEY_R:
				Engine.time_scale = 1.0
			if event.scancode == KEY_T:
				Engine.time_scale = 1.0
