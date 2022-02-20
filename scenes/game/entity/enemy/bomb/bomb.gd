extends "res://scenes/game/entity/enemy/base_enemy.gd"

# Bomb enemy extending the base enemy class.

const BULLET_SCENE := preload("res://scenes/game/entity/bullet/enemy/bullet_bomb.tscn")
const RANGE_START := 640.0
const RANGE_END := 256.0
const BLINK_FAST := 5.0
const BLINK_SLOW := 0.5
# Rotations in Godot are handled as radians. This constant equals 45 degrees.
const ROTATION_ANGLE := PI / 4.0

onready var animation := $Animation
onready var shoot_arm := $ShootArm
onready var shoot_point := $ShootArm/ShootPoint
# This variable is used to prevent multiple triggerings.
var triggered := false

# Each physics frame, the bomb checks it's distance to the player for triggering
# and additional visual effects.
func _physics_process(_delta):
	if active:
		# Checking distance with the distance_to is not as performant as
		# the distance_squared_to method, but since we're using non-squared
		# values for the ranges it is necessary. Just a few checks a frame
		# should be fine in terms of performance as well.
		var distance := global_position.distance_to(player_node.global_position)
		# Once close enough, trigger.
		if distance < RANGE_END:
			trigger()
		elif distance < RANGE_START:
			# This inverse_lerp returns a normalized value of the relative distance
			# position between the start and end ranges.
			var normal_distance = inverse_lerp(RANGE_END, RANGE_START, distance)
			if !animation.is_playing():
				animation.play("Blink")
			# The speed of the animation is interpolated between the min and max speed
			# based on the normalized distance value.
			animation.playback_speed = lerp(BLINK_FAST, BLINK_SLOW, normal_distance)
		else:
			# The RESET animation can be automatically created by AnimationPlayer nodes.
			# It's handy for resetting the animation to the default pre-animation values.
			animation.play("RESET", 0.25)

# The trigger method of the bomb. Note that being triggered is different than just
# being destroyed like other enemies. This method uses a bool to differentiate between
# these two behaviours that ultimately still lead to the bombs destruction.
func trigger(destroyed: bool = false):
	# Can't be triggered multiple times.
	if triggered:
		return
	triggered = true
	# The bomb shoots 4 or 8 bullets depending on whether shot or triggered.
	# These two ternary if/else statements manage the amount and angle of rotations.
	var rotations := 4 if destroyed else 8
	var rotation_increment := ROTATION_ANGLE * 2.0 if destroyed else ROTATION_ANGLE
	# Looping through the rotations to shoot the right amount and angle of bullets.
	for i in range(rotations):
		# Instancing the preloaded bullet scene.
		var bullet = BULLET_SCENE.instance()
		# Setting up the position, rotation and direction of the bullet.
		bullet.position = shoot_point.global_position
		bullet.position -= bullets_parent.global_position
		# The addition of the ROTATION_ANGLE constant here is to start the
		# rotations at 45 degrees. This along with rotating the ShootArm
		# node to 45 degrees initially is to make the 4 bullets shoot diagonally.
		bullet.direction = Vector2.UP.rotated(rotation_increment * i + ROTATION_ANGLE)
		# Not calling the add_child as deferred caused an area_set_shape_disabled
		# related error. Don't really know why. Also only when triggered (4 bullets).
		bullets_parent.call_deferred("add_child", bullet)
		# Rotate the shoot arm ready for the next shot angle.
		shoot_arm.rotate(rotation_increment)
	# If the bomb was triggered and not shot, don't give any score.
	if !destroyed:
		score_value = 0
	# Call the base enemy destroy method for the normal enemy destruction logic.
	.destroy()

# If the bomb is destroyed by shooting, call trigger method with appropriate boolean.
# This method is overriding the destroy method of the base enemy class.
func destroy():
	trigger(true)
