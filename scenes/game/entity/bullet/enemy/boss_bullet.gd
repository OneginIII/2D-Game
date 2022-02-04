extends "res://scenes/game/entity/bullet/base_bullet.gd"

var direction := Vector2.RIGHT

func _physics_process(delta):
	translate(direction * speed * delta)
