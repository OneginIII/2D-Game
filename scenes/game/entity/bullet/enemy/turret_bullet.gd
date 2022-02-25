extends "res://scenes/game/entity/bullet/base_bullet.gd"

var direction := Vector2.UP
var compensation := 0.0

func _ready():
	compensation = get_parent().movement_compensation

func _physics_process(delta):
	# Parent physics process checks if the bullet is still on screen.
	._physics_process(delta)
	translate(direction * speed * delta)
	translate(Vector2.UP * compensation * delta)
