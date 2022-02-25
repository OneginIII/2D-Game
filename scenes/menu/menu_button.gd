extends Button

# This script is used by the menu buttons for effects and sounds.

# The button text offsets when hovered.
export var hover_offset := Vector2(40.0, 0.0)
export var tween_duration := 0.2
# Sounds for focus/hover and accepting/pressing.
export var focus_sound : AudioStream
export var accept_sound : AudioStream
# Volume adjustment for the focus sound.
export var focus_sound_volume := -6.0
# Some buttons, like the quit button, don't play the accept sound.
export var play_accept_sound := true

# Node references.
onready var icon_node := $Icon
onready var sound := $Sound

var tween := Tween.new()
# Initial position before animations.
var initial_position := Vector2()
# These booleans are used to manage sounds.
var accepted := false
var just_visible := false

func _ready():
	add_child(tween)
	# Setting initial position.
	initial_position = rect_position
	# Hiding focus icon.
	icon_node.modulate = Color.transparent

# This method handles entering a highlighted state.
# Triggered by both the mouse and focus entering events.
func highlight_enter():
	# If the tween is not animating, reset the initial position.
	if !tween.is_active():
		initial_position = rect_position
	# Interpolate the rect position of the button forward.
	tween.interpolate_property(
		self, "rect_position", null, initial_position + hover_offset, 
		tween_duration, Tween.TRANS_QUAD, Tween.EASE_OUT)
	# Keep the icon in place by moving it backwards.
	tween.interpolate_property(
		icon_node, "rect_position", null, -hover_offset, 
		tween_duration, Tween.TRANS_QUAD, Tween.EASE_OUT)
	# Fade in the icon.
	tween.interpolate_property(
		icon_node, "modulate", null, Color.white,
		tween_duration / 2.0, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()
	# If the button was not accepted and just visible, play the focus sound.
	if !accepted and !just_visible:
		sound.stream = focus_sound
		sound.volume_db = focus_sound_volume
		sound.play()

# This method handles exiting a highlighted state.
# Triggered by both the mouse and focus exiting events.
func highlight_exit():
	# Interpolate the position back to the initial value.
	tween.interpolate_property(
		self, "rect_position", null, initial_position, 
		tween_duration, Tween.TRANS_QUAD, Tween.EASE_OUT)
	# Keep the icon in place by moving it forward.
	tween.interpolate_property(
		icon_node, "rect_position", null, Vector2.ZERO, 
		tween_duration, Tween.TRANS_QUAD, Tween.EASE_OUT)
	# Fade the icon away.
	tween.interpolate_property(
		icon_node, "modulate", null, Color.transparent,
		tween_duration / 2.0, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()
	# The button is not accepted anymore.
	accepted = false

# Triggered when the button is pressed.
func press():
	# If not playing the sound, exit the method.
	if !play_accept_sound:
		return
	# Set the accepted state as true here to prevent focus sound from playing.
	accepted = true
	# Setup and play the accept sound.
	sound.stream = accept_sound
	sound.volume_db = 0.0
	sound.play()

# This method is called whenever the visibility of the button changes.
func visibility_changed():
	# Set just visible to true for one frame and then back to false.
	# What this helps with is fixing some instances where the focus sound would
	# play unnecessarily, for example when changing between menus.
	just_visible = true
	yield(get_tree(), "idle_frame")
	just_visible = false
