tool
extends Node2D

# Base class for levels.
# The tool hint makes this script run in the editor.

const TILE_SIZE := 128.0
const LEVEL_WIDTH := 15

# Level doesn't scroll by default.
export var running := false
# This value and setget is only used for reference in the editor.
export(int) var level_length = 20 setget update_level_size
export(float) var scroll_speed = 1.0

# Variables for references.
onready var bullets := $Bullets
onready var powerups := $Powerups
# Storing the checkpoints in a dictionary.
onready var checkpoints : Dictionary

var level_rect := Rect2()

# Updating the rect for level boundary reference.
func update_level_size(value):
	level_length = value
	level_rect = Rect2(Vector2.ZERO, Vector2(TILE_SIZE * LEVEL_WIDTH, TILE_SIZE * value))
	# Using the project settings window size instead of the viewport size here
	# so that window scaling doesn't matter.
	level_rect.position.y -= level_rect.size.y - ProjectSettings.get_setting("display/window/size/height")
	# The CanvasItem's update method queues a redraw for the object.
	update()

func _ready():
	update_level_size(level_length)
	# Stop the level from scrolling in the editor.
	if Engine.editor_hint:
		set_physics_process(false)
	bullets.movement_compensation = scroll_speed
	# Filling the checkpoint dictionary with nodes.
	for node in $Checkpoints.get_children():
		checkpoints[node.name] = node

# Scrolling the level when appropriate.
func _physics_process(delta):
	if running:
		translate(Vector2.DOWN * scroll_speed * delta)

# This method draws the reference rect visible only in the editor.
func _draw():
	if Engine.editor_hint:
		draw_rect(level_rect, Color.red, false, 10.0)
