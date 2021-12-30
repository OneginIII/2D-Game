extends "res://scenes/game/entity/bullet/base_bullet.gd"

func _physics_process(delta):
	translate(Vector2.DOWN * speed * delta)
