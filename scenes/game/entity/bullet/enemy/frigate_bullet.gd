extends "res://scenes/game/entity/bullet/base_bullet.gd"

# Basic bullet used by the frigate enemy. Based on base bullet class.

var direction := Vector2.DOWN

func _physics_process(delta):
	# Parent physics process checks if the bullet is still on screen.
	._physics_process(delta)
	translate(direction * speed * delta)
