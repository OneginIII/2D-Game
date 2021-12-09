extends KinematicBody2D

class_name PlayerShip

const bullet_scene = preload("res://scenes/game/entity/bullet/player/player_bullet.tscn")

enum Gun {GUN_LEFT, GUN_RIGHT}

signal gun_fired(gun_position)

export var speed := 10.0
export var acceleration := 10.0
export var fire_rate := 0.5

onready var player_visual := $Visual
onready var gun_position_left := $GunPositionLeft
onready var gun_position_right := $GunPositionRight

var input_move_vector := Vector2.ZERO
var current_move_vector := Vector2.ZERO
var fire_rate_timer := Timer.new()
var last_fired: int = Gun.GUN_LEFT

func _ready():
	fire_rate_timer.one_shot = true
	add_child(fire_rate_timer)
	connect("gun_fired", player_visual, "gun_fired")

func _physics_process(delta):
	current_move_vector = current_move_vector.move_toward(input_move_vector, delta * acceleration)
	move_and_collide(current_move_vector * speed)

func _process(_delta):
	input_move_vector = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))
	input_move_vector = input_move_vector.clamped(1.0);
	if Input.is_action_pressed("fire"):
		fire()
	player_visual.reference_vector = current_move_vector

func fire():
	if fire_rate_timer.is_stopped():
		var bullet = bullet_scene.instance()
		if last_fired == Gun.GUN_LEFT:
			bullet.global_position = gun_position_right.global_position
			emit_signal("gun_fired", Gun.GUN_RIGHT)
			last_fired = Gun.GUN_RIGHT
		elif last_fired == Gun.GUN_RIGHT:
			bullet.global_position = gun_position_left.global_position
			emit_signal("gun_fired", Gun.GUN_LEFT)
			last_fired = Gun.GUN_LEFT
		get_parent().add_child(bullet)
		fire_rate_timer.start(fire_rate)
