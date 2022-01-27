extends KinematicBody2D

class_name PlayerShip

const FULL_HEALTH := 100
const DEFAULT_SPEED := 500.0
const MAX_SPEED := 1000.0
const FULL_LIVES := 3
const DEATH_DELAY := 3.0

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
export(PackedScene) var death_particles

onready var player_visual := $Visual
onready var player_gun := $Gun
onready var player_shape := $Shape
onready var initial_position := position
onready var tween := Tween.new()

var input_move_vector := Vector2.ZERO
var current_move_vector := Vector2.ZERO
var dead := false

func _ready():
	add_child(tween)
	player_gun.connect("gun_fired", player_visual, "gun_fired")
	reset_player()
	set_process(false)

func _process(delta):
	input_move_vector = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))
	input_move_vector = input_move_vector.clamped(1.0);
	current_move_vector = current_move_vector.move_toward(input_move_vector, delta * acceleration)
	if Input.is_action_pressed("fire") and not dead:
		player_gun.fire()
	player_visual.reference_vector = current_move_vector

func _physics_process(_delta):
	if not dead:
		move_and_slide(current_move_vector * speed)

func take_damage(amount: int, color: Color):
	if dead:
		return
	player_visual.damage_flash(color)
	self.health -= amount
	if health <= 0:
		death()

func death():
	dead = true
	player_shape.set_deferred("disabled", true)
	var particles = death_particles.instance()
	add_child(particles)
	tween.interpolate_property(player_visual, "modulate", Color.white, Color.transparent, 1.0)
	tween.start()
	yield(get_tree().create_timer(DEATH_DELAY), "timeout")
	if lives <= 0:
		emit_signal("player_death", true)
	else:
		emit_signal("player_death", false)
	self.lives -= 1

func reset_player(full_reset: bool = false):
	set_process(true)
	dead = false
	player_shape.set_deferred("disabled", false)
	player_visual.modulate = Color.white
	self.health = FULL_HEALTH
	if full_reset:
		self.lives = FULL_LIVES
		self.speed = DEFAULT_SPEED
		player_gun.current_gun_level = 0
