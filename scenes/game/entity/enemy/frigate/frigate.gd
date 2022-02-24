extends "res://scenes/game/entity/enemy/base_enemy.gd"

# Frigate enemy extending base enemy class.
# The frigate is a basic slow moving "tank" enemy.

# Preloading bullet scene.
onready var bullet_scene := preload("res://scenes/game/entity/bullet/enemy/frigate_bullet.tscn")
# Positions and lights of the two cannons that fire in alternating order.
onready var shoot_pos_left := $ShootPosLeft
onready var shoot_pos_right := $ShootPosRight
onready var light_left := $LightLeft
onready var light_right := $LightRight

# Negative movement speed makes the enemy move against the level's scrolling.
export var movement_speed := -50.0

# Using a boolean to alterante between the left and right gun.
var last_shot_left := false
# Tween for lighting effects.
var light_tween := Tween.new()

func _ready():
	add_child(light_tween)
	# Resetting gun lights.
	light_left.modulate = Color.black
	light_right.modulate = Color.black

# Frigate has very basic scrolling movement applied in physics process.
func _physics_process(delta):
	if active:
		translate(Vector2.DOWN * movement_speed * delta)

# Shooting method for the frigate.
func shoot():
	# Can't shoot when inactive.
	if !active:
		return
	var bullet = bullet_scene.instance()
	# Depending on the last shot boolean use different gun positions and tween
	# different gun light sprites.
	if last_shot_left:
		bullet.position = shoot_pos_right.global_position
		light_tween.interpolate_property(light_right, "modulate", bullet.color, Color.black, 0.5)
	else:
		bullet.position = shoot_pos_left.global_position
		light_tween.interpolate_property(light_left, "modulate", bullet.color, Color.black, 0.5)
	# This line inverses the last shot boolean.
	last_shot_left = !last_shot_left
	# Level scrolling compensation.
	bullet.position -= bullets_parent.global_position
	bullets_parent.add_child(bullet)
	# Starting the light effect tween setup in the if/else earlier.
	light_tween.start()
	# Base class shoot method for sound.
	.shoot()

# The frigate has a timer node that is connected to this method, triggering shooting.
func _on_ShootTimer_timeout():
	shoot()
