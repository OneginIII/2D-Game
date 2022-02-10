extends Control

export var focus_sound : AudioStream
export var accept_sound : AudioStream
export var focus_sound_volume := -6.0

onready var audio := AudioStreamPlayer.new()

func _ready():
	add_child(audio)
	audio.bus = "Sound"
	connect("mouse_entered", self, "grab_focus")
	connect("focus_entered", self, "highlight_enter")
	if has_signal("button_down"):
		connect("button_down", self, "press")

func highlight_enter():
	audio.stream = focus_sound
	audio.volume_db = focus_sound_volume
	audio.play()

func press():
	audio.stream = accept_sound
	audio.volume_db = 0.0
	audio.play()
