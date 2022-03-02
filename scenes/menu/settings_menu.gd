extends Control

# Script for the settings menu in main menu and pause menu.
# Manages the controls and adjusting audio and fullscreen settings.

# Getting the controls of the settings menu.
onready var sound_slider := $SettingsList/Sound/Slider
onready var music_slider := $SettingsList/Music/Slider
onready var fullscreen_box := $SettingsList/Fullscreen/CheckBox

func _ready():
	# Connecting the signals of the controls to the right methods.
	sound_slider.connect("value_changed", self, "sound_value_changed")
	music_slider.connect("value_changed", self, "music_value_changed")
	fullscreen_box.connect("toggled", self, "fullscreen_toggled")

# Connected to the visibility changed signal of this control node.
# Each time the settings menu visibility is changed, the controls are synced
# with values from the audio levels and fullscreen status.
func on_visibility_changed():
	# Reading audio volume levels from AudioServer. Converting between the
	# linear values of the sliders and the decibel levels used by AudioServer.
	sound_slider.value = db2linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Sound")))
	music_slider.value = db2linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")))
	# Reading fullscreen status from OS.
	fullscreen_box.pressed = OS.window_fullscreen

func sound_value_changed(value: float):
	# Sets the sound bus volume level. Converted from linear to decibel.
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound"), linear2db(value))

func music_value_changed(value: float):
	# Sets the music bus volume level. Converted from linear to decibel.
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(value))

func fullscreen_toggled(state: bool):
	# Sets the fullscreen state.
	OS.window_fullscreen = state
