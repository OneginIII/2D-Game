extends Button

export var hover_offset := Vector2(30.0, 0.0)
export var tween_duration := 0.2

var tween := Tween.new()
var initial_position := Vector2()

func _ready():
	add_child(tween)
	initial_position = rect_position

func highlight_enter():
	tween.interpolate_property(
		self, "rect_position", rect_position, initial_position + hover_offset, 
		tween_duration, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()

func highlight_exit():
	tween.interpolate_property(
		self, "rect_position", rect_position, initial_position, 
		tween_duration, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()
