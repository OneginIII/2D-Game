extends Container

export var direction_multiplier := 1.0
export var transition_duration := 0.5
export(NodePath) var initial_focus_target

onready var tween := Tween.new()

var button_hidden_from = null
var hidden := false

func _ready():
	add_child(tween)
	if get_node_or_null(initial_focus_target) and visible:
		get_node(initial_focus_target).grab_focus()
	hidden = !visible

func hide_panel():
	hidden = true
	tween.interpolate_property(
		self, "rect_position",
		Vector2.ZERO, Vector2(get_viewport_rect().size.x * direction_multiplier, 0.0),
		transition_duration, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()
	if self.is_a_parent_of(get_focus_owner()):
		button_hidden_from = get_focus_owner()
	else:
		button_hidden_from = null
	yield(tween, "tween_all_completed")
	if hidden:
		visible = false
		rect_position = Vector2.ZERO

func show_panel():
	hidden = false
	visible = true
	tween.interpolate_property(
		self, "rect_position",
		Vector2(get_viewport_rect().size.x * direction_multiplier, 0.0), Vector2.ZERO,
		transition_duration, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()
	if button_hidden_from:
		button_hidden_from.grab_focus()
	elif get_node_or_null(initial_focus_target):
		get_node(initial_focus_target).grab_focus()
