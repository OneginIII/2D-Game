extends "res://scenes/game/entity/enemy/base_enemy.gd"

onready var bullet_scene := preload("res://scenes/game/entity/bullet/enemy/frigate_bullet.tscn")
onready var shoot_pos_left := $ShootPosLeft
onready var shoot_pos_right := $ShootPosRight
onready var light_left := $LightLeft
onready var light_right := $LightRight

export var movement_speed := -100.0

var last_shot_left := false
var light_tween := Tween.new()

func _ready():
	add_child(light_tween)
	light_left.modulate = Color.black
	light_right.modulate = Color.black

func _physics_process(delta):
	if active:
		translate(Vector2.DOWN * movement_speed * delta)

func shoot():
	if !active:
		return
	var bullet = bullet_scene.instance()
	if last_shot_left:
		bullet.position = shoot_pos_right.global_position
		light_tween.interpolate_property(light_right, "modulate", bullet.color, Color.black, 0.5)
	else:
		bullet.position = shoot_pos_left.global_position
		light_tween.interpolate_property(light_left, "modulate", bullet.color, Color.black, 0.5)
	last_shot_left = !last_shot_left
	bullet.position -= bullets_parent.global_position
	bullets_parent.add_child(bullet)
	light_tween.start()

func _on_ShootTimer_timeout():
	shoot()
