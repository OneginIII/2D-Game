extends KinematicBody2D

class_name PlayerShip

const FULL_HEALTH := 100
const DEFAULT_SPEED := 500.0
const MAX_SPEED := 1000.0
const FULL_LIVES := 3
const DEATH_DELAY := 3.0
const SPAWN_OFFSET := Vector2(0.5, 0.75)
const SPAWN_LENGTH := 2.0
const INVUL_TIME := 0.1

signal health_updated(value)
signal player_destroyed()
signal player_death(out_of_lives)
signal lives_updated(value)
signal bonus_upgrade()

export var health := FULL_HEALTH setget set_health
func set_health(value: int):
	if value > FULL_HEALTH:
		emit_signal("bonus_upgrade")
	health = int(min(value, FULL_HEALTH))
	emit_signal("health_updated", health)
export var speed := DEFAULT_SPEED setget set_speed
func set_speed(value: float):
	if value > MAX_SPEED:
		emit_signal("bonus_upgrade")
	speed = min(value, MAX_SPEED)
export var lives: int = FULL_LIVES setget set_lives
func set_lives(value: int):
	if value > FULL_LIVES:
		emit_signal("bonus_upgrade")
	lives = int(min(value, FULL_LIVES))
	emit_signal("lives_updated", lives)
export var acceleration := 10.0
export(PackedScene) var death_particles
export var invulnerable := false
export var damage_sound : AudioStream
export var damage_volume := 0.0

onready var player_visual := $Visual
onready var player_gun := $Gun
onready var player_shape := $Shape
onready var initial_position := position
onready var tween := Tween.new()
onready var invul_timer := Timer.new()
onready var audio := AudioStreamPlayer2D.new()

var input_move_vector := Vector2.ZERO
var current_move_vector := Vector2.ZERO
var dead := false
var controllable := false

func _ready():
	visible = false
	add_child(tween)
	add_child(invul_timer)
	invul_timer.one_shot = true
	player_gun.connect("gun_fired", player_visual, "gun_fired")
	player_gun.connect("gun_level_bonus", self, "on_gun_level_bonus")
	controllable = false
	position += SPAWN_OFFSET
	add_child(audio)
	audio.bus = "Sound"

func _process(delta):
	input_move_vector = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))
	input_move_vector = input_move_vector.clamped(1.0);
	current_move_vector = current_move_vector.move_toward(input_move_vector, delta * acceleration)
	if Input.is_action_pressed("fire") and controllable:
		player_gun.fire()
	if controllable:
		player_visual.reference_vector = current_move_vector

func _physics_process(_delta):
	if controllable:
		move_and_slide(current_move_vector * speed)

func take_damage(amount: int, color: Color):
	if dead:
		return
	if not invul_timer.is_stopped():
		return
	invul_timer.start(INVUL_TIME)
	player_visual.damage_flash(color)
	audio.stream = damage_sound
	audio.volume_db = damage_volume
	audio.play()
	if invulnerable:
		return
	self.health -= amount
	if health <= 0:
		death()

func death():
	emit_signal("player_destroyed")
	dead = true
	controllable = false
	player_shape.set_deferred("disabled", true)
	var particles = death_particles.instance()
	add_child(particles)
	tween.interpolate_property(player_visual, "modulate", Color.white, Color.transparent, 1.0)
	tween.start()
	yield(get_tree().create_timer(DEATH_DELAY), "timeout")
	player_visual.modulate = Color.white
	visible = false
	if lives <= 0:
		emit_signal("player_death", true)
	else:
		emit_signal("player_death", false)
	self.lives -= 1

func reset_player(full_reset: bool = false):
	tween.remove_all()
	visible = true
	player_visual.modulate = Color.white
	dead = false
	player_shape.set_deferred("disabled", false)
	if full_reset:
		self.lives = FULL_LIVES
		self.speed = DEFAULT_SPEED
		player_gun.current_gun_level = 0
	# Animating player ship arrival
	position = get_viewport_rect().size * SPAWN_OFFSET
	var reset_position := position
	position.y += get_viewport_rect().size.y * SPAWN_OFFSET.y
	tween.interpolate_property(self, "position", null, reset_position,
		SPAWN_LENGTH, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.interpolate_property(self, "health", null, FULL_HEALTH,
		SPAWN_LENGTH, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()
	# Enable controls only after animation
	yield(tween, "tween_all_completed")
	controllable = true

func player_victory():
	tween.interpolate_property(self, "position", null,
		position - Vector2(0.0, 2000.0), 3.0, Tween.TRANS_QUAD, Tween.EASE_IN)
	tween.start()

func on_gun_level_bonus():
	emit_signal("bonus_upgrade")
