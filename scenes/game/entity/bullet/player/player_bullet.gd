extends "res://scenes/game/entity/bullet/base_bullet.gd"

export var direction := Vector2.UP

func _physics_process(delta):
	._physics_process(delta)
	translate(direction * speed)