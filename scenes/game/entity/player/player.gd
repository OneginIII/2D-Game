extends KinematicBody2D

class_name PlayerShip

const DEFAULT_HEALTH := 100
const DEFAULT_SPEED := 500.0

signal health_updated(value)

export var health := 100 setget set_health
func set_health(value: int):
	health = value
	emit_signal("health_updated", health)
export var speed := 500.0
export var acceleration := 10.0

onready var player_visual := $Visual
onready var player_gun := $Gun
onready var initial_position := position

var input_move_vector := Vector2.ZERO
var current_move_vector := Vector2.ZERO

func _ready():
	player_gun.connect("gun_fired", player_visual, "gun_fired")
	reset_player()

func _process(delta):
	input_move_vector = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))
	input_move_vector = input_move_vector.clamped(1.0);
	current_move_vector = current_move_vector.move_toward(input_move_vector, delta * acceleration)
	if Input.is_action_pressed("fire"):
		player_gun.fire()
	player_visual.reference_vector = current_move_vector

func _physics_process(_delta):
	move_and_slide(current_move_vector * speed)

func take_damage(amount: int, color: Color):
	player_visual.damage_flash(color)
	self.health -= amount

func reset_player():
	health = DEFAULT_HEALTH
	speed = DEFAULT_SPEED
	# player_gun.gun_level = 0
	position = initial_position
