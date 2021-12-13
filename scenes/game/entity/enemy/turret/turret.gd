extends "res://scenes/game/entity/enemy/base_enemy.gd"

onready var bullet_scene := preload("res://scenes/game/entity/bullet/enemy/turret_bullet.tscn")
onready var head := $Head
onready var shoot_position := $Head/ShootPosition

var player_node

const ANGLE_OFFSET := 90.0

func _ready():
	player_node = get_tree().root.find_node("Player", true, false)

func _physics_process(delta):
	if player_node != null:
		head.look_at(player_node.global_position)
		head.rotate(deg2rad(ANGLE_OFFSET))

func shoot():
	var bullet = bullet_scene.instance()
	bullet.rotation = shoot_position.global_rotation
	bullet.global_position = shoot_position.global_position
	bullet.direction = bullet.direction.rotated(bullet.rotation)
	get_parent().add_child(bullet)

func _on_ShootTimer_timeout():
	shoot()
