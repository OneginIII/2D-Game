extends "res://scenes/game/entity/bullet/base_bullet.gd"

# Class for the boss's regular bullet. Extends base bullet.
# Basic bullet like most others in the game.

var direction := Vector2.RIGHT

func _physics_process(delta):
	translate(direction * speed * delta)
