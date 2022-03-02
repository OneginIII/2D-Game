extends "res://scenes/game/entity/bullet/base_bullet.gd"

# Bullet used by the turret enemy. Based on base bullet class.

var direction := Vector2.UP
# This bullet has to compensate for the screen scrolling.
var compensation := 0.0

func _ready():
	# Getting scroll value from the bullet's parent node.
	compensation = get_parent().movement_compensation

func _physics_process(delta):
	# Parent physics process checks if the bullet is still on screen.
	._physics_process(delta)
	# Translate the bullet in the fired direction multiplied by speed and delta.
	translate(direction * speed * delta)
	# Compensate for the level scrolling. This makes the turret enemy's aim
	# accurate, so that it would always hit a non-moving player.
	# This has the side effect of making the bullet's rotation slightly mismatch
	# it's movement direction.
	translate(Vector2.UP * compensation * delta)
