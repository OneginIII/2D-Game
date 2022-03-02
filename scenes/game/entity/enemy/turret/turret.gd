extends "res://scenes/game/entity/enemy/base_enemy.gd"

# Turret enemy extending base enemy class.
# The turret is the only enemy that aims at the player.

# This offset is to account for the initial rotation of the turret head.
const ANGLE_OFFSET := 90.0

# Preloading bullet scene.
onready var bullet_scene := preload("res://scenes/game/entity/bullet/enemy/turret_bullet.tscn")
# Getting the turret head, for rotating it toward the player.
onready var head := $Head
# The shoot position and light are children of the head to rotate along with it.
onready var shoot_position := $Head/ShootPosition
onready var turret_light := $Head/TurretLight

# Tween for muzzle flashes.
var light_tween := Tween.new()

func _ready():
	add_child(light_tween)
	# Resetting gun light.
	turret_light.modulate = Color.black

func _physics_process(_delta):
	# Every frame, check if the player node is available and the turret is active.
	if player_node != null and active:
		# Rotate the head to look at the player. The look at method of Node2D
		# makes this very simple.
		head.look_at(player_node.global_position)
		# Account for the initial offset.
		head.rotate(deg2rad(ANGLE_OFFSET))

# This method makes the turret shoot.
func shoot():
	# Can't shoot while inactive.
	if !active:
		return
	# Instance the bullet node and adjust it's transform.
	var bullet = bullet_scene.instance()
	bullet.rotation = shoot_position.global_rotation
	bullet.position = shoot_position.global_position
	bullet.position -= bullets_parent.global_position
	# Set the bullet's movement direction to match it's rotation.
	bullet.direction = bullet.direction.rotated(bullet.rotation)
	bullets_parent.add_child(bullet)
	# Gun light flash effect.
	light_tween.interpolate_property(turret_light, "modulate", bullet.color, Color.black, 0.5)
	light_tween.start()
	# Parent class shoot method for sound.
	.shoot()

# This method is connected to a repeating timer node on the turret.
func _on_ShootTimer_timeout():
	shoot()
