extends "res://scenes/game/entity/enemy/base_enemy.gd"

onready var bullet_scene := preload("res://scenes/game/entity/bullet/enemy/drone_bullet.tscn")
onready var shoot_position := $ShootPosition
onready var gun_light := $Light

export var movement_speed := -75.0

var bullets_parent
var light_tween := Tween.new()

func _ready():
	bullets_parent = get_tree().root.find_node("Bullets", true, false)
	add_child(light_tween)
	gun_light.modulate = Color.black

func _physics_process(delta):
	if active:
		translate(Vector2.DOWN * movement_speed * delta)

func shoot():
	if !active:
		return
	var bullet = bullet_scene.instance()
	bullet.global_position = shoot_position.global_position
	bullets_parent.add_child(bullet)
	light_tween.interpolate_property(gun_light, "modulate", bullet.color, Color.black, 0.5)
	light_tween.start()

func _on_ShootTimer_timeout():
	shoot()