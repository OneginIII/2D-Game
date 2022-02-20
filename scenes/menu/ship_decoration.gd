extends Node2D

const MOVE_TIME := 0.5
const MOVE_AMOUNT := Vector2(-0.8, 0.0)

onready var tween := Tween.new()

var position_ratio := Vector2()

func _ready():
	get_tree().root.connect("size_changed", self, "on_resize")
	position_ratio = position / get_viewport_rect().size
	add_child(tween)

func on_resize():
	if get_viewport_rect().has_point(position):
		position = get_viewport_rect().size * position_ratio
	else:
		position.y = get_viewport_rect().size.y * position_ratio.y

func hide_ship(state: bool):
	tween.remove_all()
	var screen_size := get_viewport_rect().size
	var target
	if state:
		target = screen_size * position_ratio + screen_size * MOVE_AMOUNT
	else:
		target = screen_size * position_ratio
	tween.interpolate_property(self, "position", null, target,
		MOVE_TIME, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()

func start_ship():
	tween.remove_all()
	var screen_size := get_viewport_rect().size
	var target = screen_size * position_ratio - screen_size * MOVE_AMOUNT
	tween.interpolate_property(self, "position", null, target,
		MOVE_TIME * 1.5, Tween.TRANS_QUAD, Tween.EASE_IN)
	tween.start()

func reset_ship():
	tween.remove_all()
	position = get_viewport_rect().size * position_ratio
