extends Node2D

signal checkpoint_reached(checkpoint_name)

var active := true
var level_scroll := 0.0

func _ready():
	level_scroll = position.y

func _on_Checkpoint_body_entered(body):
	if active:
		emit_signal("checkpoint_reached", name)
