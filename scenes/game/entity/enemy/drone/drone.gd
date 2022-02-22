extends "res://scenes/game/entity/enemy/base_enemy.gd"

# Drone enemy extending the base enemy class.

# Bullet scene constant preloaded.
const BULLET_SCENE := preload("res://scenes/game/entity/bullet/enemy/drone_bullet.tscn")

# Adjustable movement speed for the drone enemy.
export var movement_speed := 100.0

# The Position2D used for positioning bullets.
onready var shoot_position := $ShootPosition
# The light sprite used for shooting effects.
onready var gun_light := $Light

# Tween for the gun light effect.
var light_tween := Tween.new()

# Adding tween child and resetting light modulate.
func _ready():
	add_child(light_tween)
	gun_light.modulate = Color.black

# Physics process moves the drone forward based on movement_speed and angle.
func _physics_process(delta):
	if active:
		translate(Vector2.RIGHT.rotated(rotation) * movement_speed * delta)

# This is the basic shooting method used by the drone.
func shoot():
	if !active:
		return
	# Setting up bullet instance transformation.
	var bullet = BULLET_SCENE.instance()
	bullet.position = shoot_position.global_position
	# This is to compensate for level scrolling.
	bullet.position -= bullets_parent.global_position
	bullet.rotation = shoot_position.global_rotation
	# Setting the bullet direction based on it's rotation.
	bullet.direction = bullet.direction.rotated(bullet.rotation)
	bullets_parent.add_child(bullet)
	# Animating the "muzzle flash".
	light_tween.interpolate_property(gun_light, "modulate", bullet.color, Color.black, 0.5)
	light_tween.start()
	# Base enemy class shoot method used for sound.
	.shoot()

# The drone enemy has a repeating timer that's signal calls the shooting method.
func _on_ShootTimer_timeout():
	shoot()
