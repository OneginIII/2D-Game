extends Container

# This script is on the main menu panels to manage showing and hiding them.

# The direction in which to transition the panels. Reverse for the main panel.
export var direction_multiplier := 1.0
export var transition_duration := 0.5
# This node path points to the button to be focused when the panel shows.
export(NodePath) var initial_focus_target

onready var tween := Tween.new()

# Saves the button which hid this panel, to focus it when returning.
var button_hidden_from = null
# Extra hidden toggle to avoid problems with the yield in hide panel method.
var hidden := false

func _ready():
	add_child(tween)
	# If the initial focus target exists and is visible, grab focus on it.
	if get_node_or_null(initial_focus_target) and visible:
		get_node(initial_focus_target).grab_focus()
	# Initialize hidden to the inverse of visibility.
	hidden = !visible

# This method hides the panel. Called by buttons connected via signals.
func hide_panel():
	hidden = true
	# Interpolate the position of the panel to horizontally exit the screen.
	tween.interpolate_property(
		self, "rect_position",
		Vector2.ZERO, Vector2(get_viewport_rect().size.x * direction_multiplier, 0.0),
		transition_duration, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()
	# If this panel is a parent of the button this triggered from, save it as
	# the button to refocus after coming back.
	if self.is_a_parent_of(get_focus_owner()):
		button_hidden_from = get_focus_owner()
	else:
		button_hidden_from = null
	# Wait for the tween to complete, and if the panel is still "hidden",
	# properly hide it and reset it's transform. The extra hidden variable 
	# helps here in case the menus are toggled quickly multiple times.
	yield(tween, "tween_all_completed")
	if hidden:
		visible = false
		rect_position = Vector2.ZERO

# This method shows the panel. Called by buttons connected via signals.
func show_panel():
	# Show the panel.
	hidden = false
	visible = true
	# Interpolate the position of the panel to horizontally enter the screen.
	tween.interpolate_property(
		self, "rect_position",
		Vector2(get_viewport_rect().size.x * direction_multiplier, 0.0), Vector2.ZERO,
		transition_duration, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()
	# If there is a button saved as the return focus target, focus it.
	if button_hidden_from:
		button_hidden_from.grab_focus()
	# Otherwise focus the initial focus target.
	elif get_node_or_null(initial_focus_target):
		get_node(initial_focus_target).grab_focus()
