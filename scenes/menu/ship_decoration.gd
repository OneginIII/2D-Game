extends Node2D

var position_ratio := Vector2()

func _ready():
	get_tree().root.connect("size_changed", self, "on_resize")
	position_ratio = position / get_viewport_rect().size

func on_resize():
	position = get_viewport_rect().size * position_ratio
