extends "res://scenes/game/entity/bullet/base_bullet.gd"

# Player's bullet. Third level type. Has some special behaviour.

export var direction := Vector2.UP
# This bullet has a sinewave effect using a float "timer".
var sine_timer := PI / 2.0
# Variables passed in by the player gun, based on the gun level resource.
var index: int
var on_right: bool

func _ready():
	# If the bullet index is even, make it smaller and half as damaging.
	if index % 2 == 0:
		scale = Vector2(0.5, 0.5)
		damage /= 2

func _physics_process(delta):
	# Parent physics process checks if the bullet is still on screen.
	._physics_process(delta)
	# If the bullet index is even, set the direction with a sinewave pattern.
	if index % 2 == 0:
		# Also check if it is on the right or the left for altering directions.
		if on_right:
			direction.x = sin(sine_timer)
		else:
			direction.x = -sin(sine_timer)
	# Otherwise the direction is straight.
	else:
		direction.x = 0.0
	# Move the bullet.
	translate(direction * speed * delta)
	# Increment the timer based on a speed value.
	sine_timer += delta * 20.0
	# Rotate the bullet to face it's movement direction.
	rotation = direction.angle() + (PI / 2.0)
