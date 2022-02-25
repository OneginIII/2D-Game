extends Node2D

# This is the script for the player's gun.
# Since the gun behaviour is pretty complex, it is delegated to this node.

# A bullet index is used by the third level gun.
const BULLET_INDEX_LIMIT := 100
# Maximum level of the gun.
const MAX_GUN_LEVEL := 6

# Signals used by the gun light effects, gui and score calculations.
signal gun_fired(gun_position, gun_color)
signal gun_level_set(gun_level)
signal gun_level_bonus()
# This enum describes which gun is firing.
enum GunPosition {GUN_LEFT, GUN_RIGHT, GUN_BOTH}

# This exported array contains custom resources for the different gun levels.
export(Array, Resource) var gun_levels
# This exported integer determines the gun level. Includes a setget method.
export var current_gun_level := 0 setget set_gun_level
func set_gun_level(level: int):
	# If the new gun level is more than the max level, signal bonus and cap it.
	if level > MAX_GUN_LEVEL:
		emit_signal("gun_level_bonus")
	current_gun_level = int(min(level, MAX_GUN_LEVEL))
	# Emits signal for gui updates on level changes.
	emit_signal("gun_level_set", current_gun_level)

# Shoot positions.
onready var gun_position_left := $GunPositionLeft
onready var gun_position_right := $GunPositionRight

var bullet_scene
# Timer for firing rate control.
var fire_rate_timer := Timer.new()
var audio := AudioStreamPlayer2D.new()
# The last fired gun for alternating firing order.
var last_fired_position: int = GunPosition.GUN_LEFT
# Incrementing bullet index used by the third level bullet.
var bullet_index: int = 0
var bullets_parent

func _ready():
	# Setting the bullet scene initially as the first level bullet.
	bullet_scene = gun_levels[0].bullet_scene
	add_child(fire_rate_timer)
	# Fire rate timer is not repeating, instead starts running after firing.
	fire_rate_timer.one_shot = true
	# Setting up for audio.
	add_child(audio)
	audio.bus = "Sound"

# The fire method can be called by the player's input every frame.
func fire():
	# If the timer is not running, the gun is not on cooldown and can fire.
	if fire_rate_timer.is_stopped():
		# Read the gun resource from the array based on the current gun level.
		var gun = gun_levels[current_gun_level]
		# The gun has two main methods of firing, alternating and simultaneous.
		if gun.alternating:
			# Setup the bullet instance, speed and damage.
			var bullet = gun.bullet_scene.instance()
			bullet.speed = gun.bullet_speed
			bullet.damage = gun.damage
			# Depending on which gun is next to fire, set position and emit signal.
			if last_fired_position == GunPosition.GUN_LEFT:
				bullet.position = gun_position_right.global_position
				bullet.position -= bullets_parent.global_position
				emit_signal("gun_fired", GunPosition.GUN_RIGHT, bullet.color)
				# Update the last fired position.
				last_fired_position = GunPosition.GUN_RIGHT
			elif last_fired_position == GunPosition.GUN_RIGHT:
				bullet.position = gun_position_left.global_position
				bullet.position -= bullets_parent.global_position
				emit_signal("gun_fired", GunPosition.GUN_LEFT, bullet.color)
				last_fired_position = GunPosition.GUN_LEFT
			bullets_parent.add_child(bullet)
		else:
			# The simultaneous firing needs to setup two bullet instances.
			var bullet_left = gun.bullet_scene.instance()
			bullet_left.speed = gun.bullet_speed
			bullet_left.damage = gun.damage
			var bullet_right = gun.bullet_scene.instance()
			bullet_right.speed = gun.bullet_speed
			bullet_right.damage = gun.damage
			bullet_left.position = gun_position_left.global_position
			bullet_left.position -= bullets_parent.global_position
			bullet_right.position = gun_position_right.global_position
			bullet_right.position -= bullets_parent.global_position
			# If the gun level needs an index value it is determined here.
			if gun.give_index:
				bullet_left.index = bullet_index
				bullet_right.index = bullet_index
				bullet_index += 1
				# Once the index limit is reached, wrap the value with modulo.
				bullet_index %= BULLET_INDEX_LIMIT
			# If the gun level needs a firing side value it is set here.
			if gun.give_side:
				bullet_left.on_right = false
				bullet_right.on_right = true
			# Add both bullet children and emit the fired signal.
			bullets_parent.add_child(bullet_left)
			bullets_parent.add_child(bullet_right)
			emit_signal("gun_fired", GunPosition.GUN_BOTH, bullet_left.color)
		# Setup and play firing audio based on the gun resource.
		audio.stream = gun.audio_stream
		audio.volume_db = gun.audio_volume
		audio.play()
		# After firing, start the gun cooldown based on the current level value.
		fire_rate_timer.start(gun.fire_rate)
