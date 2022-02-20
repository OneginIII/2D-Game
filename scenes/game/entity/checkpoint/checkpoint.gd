extends Node2D

# Class for the checkpoints in the level.

# The main signal for reaching a checkpoint.
signal checkpoint_reached(checkpoint_name, display, music)

# Displaying the checkpoint reaching message can be disabled.
# Used by the very first checkpoint and also checkpoints respawned at.
export var display_message := true
# Whether hitting the checkpoint should stop the music. Used before the boss.
export var stop_music := false

var active := true
# Stores the scroll position of the checkpoint at the start to scroll
# the level correctly when respawning at the checkpoint.
var level_scroll := 0.0

func _ready():
	# Setting scroll value at the start of the level.
	level_scroll = position.y

# This is called by the Area2D's body entered signal. Emits the main signal.
func _on_Checkpoint_body_entered(_body):
	if active:
		emit_signal("checkpoint_reached", name, display_message, stop_music)
