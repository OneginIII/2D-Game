extends "res://scenes/game/entity/bullet/base_bullet.gd"

# Player's bullet. Second level type. No special behaviour. Visually different
# and fires simultaneusly.

export var direction := Vector2.UP

func _physics_process(delta):
	# Parent physics process checks if the bullet is still on screen.
	._physics_process(delta)
	translate(direction * speed * delta)
