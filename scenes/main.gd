extends Node

# This is the main node's script.
# The main node handles saving, loading, transition between menu and game,
# quitting the game and some debug inputs.

const CONFIG_CATEGORY := "settings"
# Paths used by the save file and config file.
const CONFIG_PATH := "user://settings.cfg"
const SAVE_PATH := "user://save.data"

# Toggle for whether running in debug mode or not.
export var debug := true

# Getting the game and menu node.
onready var game := $Game
onready var menu := $MainMenuLayer/MainMenu

# Both the config and the save data include a version integer.
# If there are changes made to data structures, this can be read to manage data
# migrations. It is good practice to include this in the files even if you
# don't use it for the current version of the game.
var config_version := 1
var save_version := 0

func _ready():
	# Randomizes the seed Godot's global random number generator.
	randomize()
	# Connect to the signal emitted when player chooses quit in the main menu.
	menu.connect("game_quit", self, "quit_game")
	# Set volume levels to half initially. Overriden after config loads.
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound"),linear2db(0.5))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(0.5))
	# When game starts, load the config and save data.
	load_config()
	load_game()

# Called when the game starts. Connected via signal through the editor.
func game_started():
	game.start_game()

# Called when the game ends. Connected via signal through the editor.
func game_ended():
	menu.start_menu()

# This method handles saving the game data.
func save_game():
	# Creating a new save file.
	var save_file = File.new()
	# Opening the file for writing to it. This creates the file if not there.
	save_file.open(SAVE_PATH, File.WRITE)
	# Setting up the saved data as a dictionary.
	var save_data = {
		# Include save version and the highscore list array.
		"version" : save_version,
		"highscores" : ScoreManager.highscore_list
	}
	# Using the store var method to store the dictionary in the file.
	# There are multiple other ways of storing data in a file, but this is a 
	# very simple way of doing it. The data will be in binary and not easily
	# editable. This can be both good or bad, depending on the use case.
	save_file.store_var(save_data)
	# Important to close the file after writing to it.
	save_file.close()

# This method handles loading the game data.
func load_game():
	# Creating a new save file.
	var save_file = File.new()
	# Check if the file exists in the path. If not, just exit the loading method.
	if not save_file.file_exists(SAVE_PATH):
		return
	# The file should exists, so open it for reading.
	save_file.open(SAVE_PATH, File.READ)
	# Getting the save data dictionary with get var method.
	var save_data = save_file.get_var()
	# Giving the global score manager the highscore list array.
	# Including a fallback to the score manager's existing array in the get method.
	ScoreManager.highscore_list = save_data.get("highscores", ScoreManager.highscore_list)
	# Important to close the file after reading it.
	save_file.close()

# This method saves a config file using Godot's built-in config file feature.
func save_config():
	# Setting up the config file.
	var config = ConfigFile.new()
	# Filling all the config data in the same category, starting with the version.
	config.set_value(CONFIG_CATEGORY, "version", config_version)
	# Reading the audio levels directly from the audio server.
	config.set_value(CONFIG_CATEGORY, "sound_volume",
		db2linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Sound"))))
	config.set_value(CONFIG_CATEGORY, "music_volume",
		db2linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))))
	# Also reading the fullscreen status directly.
	config.set_value(CONFIG_CATEGORY, "fullscreen", OS.window_fullscreen)
	config.set_value(CONFIG_CATEGORY, "language", TranslationServer.get_locale())
	config.save(CONFIG_PATH)

# This method loads a config file using Godot's built-in config file feature.
func load_config():
	# Setting up the config file.
	var config = ConfigFile.new()
	# Loading the config and checking for error's.
	var error = config.load(CONFIG_PATH)
	# If the error value is not ok, exit out of the loading method.
	if error != OK:
		return
	# Directly setting the audio mixer levels based on the config data.
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound"),
		linear2db(config.get_value(CONFIG_CATEGORY, "sound_volume", 0.5)))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),
		linear2db(config.get_value(CONFIG_CATEGORY, "music_volume", 0.5)))
	# Also setting the fullscreen value based on the config data.
	OS.window_fullscreen = config.get_value(CONFIG_CATEGORY, "fullscreen", false)
	TranslationServer.set_locale(config.get_value(CONFIG_CATEGORY, "language", "en"))

# Called when qutting the game. Saves config and game data before exiting.
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
			# Adjusting engine timescale for testing purposes.
			if event.scancode == KEY_R:
				Engine.time_scale = 25.0
			if event.scancode == KEY_T:
				Engine.time_scale = 0.1
			# Giving player score for testing purposes.
			if event.scancode == KEY_P:
				ScoreManager.score += 100
		else:
			# Reverting engine timescale adjustments.
			if event.scancode == KEY_R:
				Engine.time_scale = 1.0
			if event.scancode == KEY_T:
				Engine.time_scale = 1.0
