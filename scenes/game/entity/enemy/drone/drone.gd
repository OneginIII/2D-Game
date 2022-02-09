extends "res://scenes/game/entity/enemy/base_enemy.gd"

onready var bullet_scene := preload("res://scenes/game/entity/bullet/enemy/drone_bullet.tscn")
onready var shoot_position := $ShootPosition
onready var gun_light := $Light

export var movement_speed := 0.0

var light_tween := Tween.new()

func _ready():
	add_child(light_tween)
	gun_light.modulate = Color.black

func _physics_process(delta):
	if active:
		translate(Vector2.RIGHT.rotated(rotation) * movement_speed * delta)

func shoot():
	if !active:
		return
	var bullet = bullet_scene.instance()
	bullet.position = shoot_position.global_position
	bullet.position -= bullets_parent.global_position
	bullet.rotation = shoot_position.global_rotation
	bullet.direction = bullet.direction.rotated(bullet.rotation)
	bullets_parent.add_child(bullet)
	light_tween.interpolate_property(gun_light, "modulate", bullet.color, Color.black, 0.5)
	light_tween.start()

func _on_ShootTimer_timeout():
	shoot()
