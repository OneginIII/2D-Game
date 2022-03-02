extends Control

# This script is used for the sound sliders and fullscreen checkbox.
# Plays the focus and accept sounds to match the buttons of the rest of the ui.

# Focus sound, accept sound and an adjustable volume level for the focus.
export var focus_sound : AudioStream
export var accept_sound : AudioStream
export var focus_sound_volume := -6.0

# Audio player to play the audio.
onready var audio := AudioStreamPlayer.new()

func _ready():
	# Add the audio player and set the bus.
	add_child(audio)
	audio.bus = "Sound"
	# Connect the control's interaction signals just like those used for buttons.
	connect("mouse_entered", self, "grab_focus")
	connect("focus_entered", self, "highlight_enter")
	# Only the checkbox has the button down signal.
	if has_signal("button_down"):
		connect("button_down", self, "press")

# Plays the focus sound when the control is highlighted.
func highlight_enter():
	# Set the correct stream, volume and play.
	audio.stream = focus_sound
	audio.volume_db = focus_sound_volume
	audio.play()

# Plays the accept sound when the control is used. Only used for checkbox.
func press():
	# Set the correct stream, volume and play.
	audio.stream = accept_sound
	audio.volume_db = 0.0
	audio.play()
