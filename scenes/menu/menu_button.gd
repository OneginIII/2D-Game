extends Button

export var hover_offset := Vector2(40.0, 0.0)
export var tween_duration := 0.2

onready var icon_node := $Icon

var tween := Tween.new()
var initial_position := Vector2()

func _ready():
	add_child(tween)
	initial_position = rect_position
	icon_node.modulate = Color.transparent

func highlight_enter():
	if !tween.is_active():
		initial_position = rect_position
	tween.interpolate_property(
		self, "rect_position", null, initial_position + hover_offset, 
		tween_duration, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.interpolate_property(
		icon_node, "rect_position", null, -hover_offset, 
		tween_duration, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.interpolate_property(
		icon_node, "modulate", null, Color.white,
		tween_duration / 2.0, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()

func highlight_exit():
	tween.interpolate_property(
		self, "rect_position", null, initial_position, 
		tween_duration, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.interpolate_property(
		icon_node, "rect_position", null, Vector2.ZERO, 
		tween_duration, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.interpolate_property(
		icon_node, "modulate", null, Color.transparent,
		tween_duration / 2.0, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()
