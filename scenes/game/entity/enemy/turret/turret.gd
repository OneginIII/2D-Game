extends "res://scenes/game/entity/enemy/base_enemy.gd"

onready var bullet_scene := preload("res://scenes/game/entity/bullet/enemy/turret_bullet.tscn")
onready var head := $Head
onready var shoot_position := $Head/ShootPosition
onready var turret_light := $Head/TurretLight

var light_tween := Tween.new()

const ANGLE_OFFSET := 90.0

func _ready():
	add_child(light_tween)
	turret_light.modulate = Color.black

func _physics_process(_delta):
	if player_node != null and active:
		head.look_at(player_node.global_position)
		head.rotate(deg2rad(ANGLE_OFFSET))

func shoot():
	if !active:
		return
	var bullet = bullet_scene.instance()
	bullet.rotation = shoot_position.global_rotation
	bullet.position = shoot_position.global_position
	bullet.position -= bullets_parent.global_position
	bullet.direction = bullet.direction.rotated(bullet.rotation)
	bullets_parent.add_child(bullet)
	light_tween.interpolate_property(turret_light, "modulate", bullet.color, Color.black, 0.5)
	light_tween.start()
	.shoot()

func _on_ShootTimer_timeout():
	shoot()
