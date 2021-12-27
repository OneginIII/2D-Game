tool
extends Node2D

export(int) var level_length = 20 setget update_level_size
export(float) var scroll_speed = 1.0

var level_rect := Rect2()

const TILE_SIZE := 128.0
const LEVEL_WIDTH := 15

func update_level_size(value):
	level_length = value
	level_rect = Rect2(Vector2.ZERO, Vector2(TILE_SIZE * LEVEL_WIDTH, TILE_SIZE * value))
	level_rect.position.y -= level_rect.size.y - ProjectSettings.get_setting("display/window/size/height")
	update()

func _ready():
	update_level_size(level_length)
	if Engine.editor_hint:
		set_physics_process(false)

func _physics_process(delta):
	translate(Vector2.DOWN * scroll_speed * delta)

func _draw():
	if Engine.editor_hint:
		draw_rect(level_rect, Color.red, false, 10.0)
