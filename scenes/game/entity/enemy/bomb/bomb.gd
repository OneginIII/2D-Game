extends "res://scenes/game/entity/enemy/base_enemy.gd"

const BULLET_SCENE := preload("res://scenes/game/entity/bullet/enemy/bullet_bomb.tscn")

const RANGE_START := 640.0
const RANGE_END := 256.0
const BLINK_FAST := 5.0
const BLINK_SLOW := 0.5
const ROTATION_ANGLE := PI / 4.0

onready var animation := $Animation
onready var shoot_arm := $ShootArm
onready var shoot_point := $ShootArm/ShootPoint

var triggered := false

func _physics_process(_delta):
	if active:
		var distance := global_position.distance_to(player_node.global_position)
		if distance < RANGE_END:
			trigger()
		elif distance < RANGE_START:
			var normal_distance = inverse_lerp(RANGE_END, RANGE_START, distance)
			if !animation.is_playing():
				animation.play("Blink")
			animation.playback_speed = lerp(BLINK_FAST, BLINK_SLOW, normal_distance)
		else:
			animation.play("RESET", 0.25)

func trigger(destroyed: bool = false):
	if triggered:
		return
	triggered = true
	var rotations := 4 if destroyed else 8
	var rotation_increment := ROTATION_ANGLE * 2.0 if destroyed else ROTATION_ANGLE
	for i in range(rotations):
		var bullet = BULLET_SCENE.instance()
		bullet.position = shoot_point.global_position
		bullet.position -= bullets_parent.global_position
		bullet.direction = Vector2.UP.rotated(rotation_increment * i + ROTATION_ANGLE)
		bullets_parent.call_deferred("add_child", bullet)
		shoot_arm.rotate(rotation_increment)
	if !destroyed:
		score_value = 0
	.destroy()

func destroy():
	trigger(true)
