extends "res://scenes/game/entity/bullet/base_bullet.gd"

# Class for the bomb's bullet. Extends base bullet.
# Basic bullet like most others in the game.

var direction := Vector2.UP

func _physics_process(delta):
	translate(direction * speed * delta)
