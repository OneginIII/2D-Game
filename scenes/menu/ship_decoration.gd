extends Node2D

# This script is used by the decorative ship in the main menu's background.
# The ship decoration is a Node2D and not a Control node. It is fine to mix
# them since both inherit from CanvasItem.

# Constants for transition effects.
const MOVE_TIME := 0.5
const MOVE_AMOUNT := Vector2(-0.8, 0.0)

onready var tween := Tween.new()

# A ratio for the position to hold for the ship.
var position_ratio := Vector2()

func _ready():
	# Connecting a signal for when the viewport size is changed.
	get_tree().root.connect("size_changed", self, "on_resize")
	# Calculating the position ratio based on current position and viewport size.
	# Since the viewport size might change while the ship should stay fixed at
	# a relative position (like the rest of the menus) using a ratio is sensible.
	position_ratio = position / get_viewport_rect().size
	add_child(tween)

# This method is called whenever the viewport is resized.
func on_resize():
	# Check if the ship is currently inside the viewport. If not you are likely
	# not in the main menu screen where the ship should be visible.
	if get_viewport_rect().has_point(position):
		# If inside, adjust the full position of the ship to match the ratio.
		position = get_viewport_rect().size * position_ratio
	else:
		# If not, adjust just the vertical position to match the ratio.
		position.y = get_viewport_rect().size.y * position_ratio.y

# This method is called by certain buttons to either show or hide the ship.
func hide_ship(state: bool):
	# Remove any ongoing tweens. Handles changing menus quickly.
	tween.remove_all()
	# Get the screen size.
	var screen_size := get_viewport_rect().size
	# Set a target position based on whether hiding or showing ship.
	var target : Vector2
	if state:
		# When hiding the ship. Use the position ratio, along with the constant
		# move amount, which determines by which screen size ratio the ship
		# should move out of the screen. Set currently to a bit less than full,
		# the ship parallaxes slightly when moving out of frame.
		target = screen_size * position_ratio + screen_size * MOVE_AMOUNT
	else:
		# When showing the ship, just move it back to the correct ratio of the
		# screen size.
		target = screen_size * position_ratio
	# The interpolation is set to match the ones used by menu panels.
	tween.interpolate_property(self, "position", null, target,
		MOVE_TIME, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()

# When the game starts the ship has a small animation of flying off screen.
func start_ship():
	# Reset any tweens.
	tween.remove_all()
	# Do similar ratio calculation as in the hide ship method. This time the
	# target and interpolation is slightly different to slide the ship
	# out of the screen on the right.
	var screen_size := get_viewport_rect().size
	var target = screen_size * position_ratio - screen_size * MOVE_AMOUNT
	tween.interpolate_property(self, "position", null, target,
		MOVE_TIME * 1.5, Tween.TRANS_QUAD, Tween.EASE_IN)
	tween.start()

# Resets the ship decoration to it's normal position when returning to menu.
func reset_ship():
	tween.remove_all()
	position = get_viewport_rect().size * position_ratio
