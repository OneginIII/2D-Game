extends KinematicBody2D

class_name PlayerShip

const FULL_HEALTH := 100
const DEFAULT_SPEED := 500.0
const MAX_SPEED := 1000.0
const FULL_LIVES = 3

signal health_updated(value)
signal player_death(out_of_lives)
signal lives_updated(value)

export var health := FULL_HEALTH setget set_health
func set_health(value: int):
	health = int(min(value, FULL_HEALTH))
	emit_signal("health_updated", health)
export var speed := DEFAULT_SPEED setget set_speed
func set_speed(value: float):
	speed = min(value, MAX_SPEED)
export var lives: int = FULL_LIVES setget set_lives
func set_lives(value: int):
	lives = int(min(value, FULL_LIVES))
	emit_signal("lives_updated", lives)
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
	if health <= 0:
		if lives <= 0:
			emit_signal("player_death", true)
		else:
			emit_signal("player_death", false)

func reset_player(full_reset: bool = false):
	self.health = FULL_HEALTH
	position = initial_position
	if full_reset:
		self.lives = FULL_LIVES
		self.speed = DEFAULT_SPEED
		player_gun.current_gun_level = 0
