extends "res://scenes/game/entity/bullet/base_bullet.gd"

# Bullet used by the drone enemy. Based on base bullet.

# This direction vector will be overriden by the drone enemy during shooting.
var direction := Vector2.UP

func _physics_process(delta):
	translate(direction * speed * delta)
