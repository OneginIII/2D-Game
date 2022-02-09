extends Control

onready var sound_slider := $SettingsList/Sound/Slider
onready var music_slider := $SettingsList/Music/Slider
onready var fullscreen_box := $SettingsList/Fullscreen/CheckBox

func _ready():
	sound_slider.connect("value_changed", self, "sound_value_changed")
	music_slider.connect("value_changed", self, "music_value_changed")
	fullscreen_box.connect("toggled", self, "fullscreen_toggled")

func on_visibility_changed():
	sound_slider.value = db2linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Sound")))
	music_slider.value = db2linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")))
	fullscreen_box.pressed = OS.window_fullscreen

func sound_value_changed(value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound"), linear2db(value))

func music_value_changed(value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(value))

func fullscreen_toggled(state: bool):
	OS.window_fullscreen = state
