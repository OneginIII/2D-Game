extends Node2D

const explosion_scene := preload("res://scenes/game/entity/effect/explosion/explosion.tscn")

export var health : int = 100
export (Array, NodePath) var flashing_sprites
export var activation_margin : float = 64.0
export var score_value := 10

onready var shape := $Shape

var player_node
var game_node
var active := false
var flash_tween := Tween.new()
var effects_parent
var activation_timer := Timer.new()

const FLASH_MULTIPLY = 2.5
const FLASH_TIME = 0.2
const DESTROY_DELAY = 0.5
const ACTIVATION_INTERVAL = 0.1

func _ready():
	player_node = get_tree().root.find_node("Player", true, false)
	game_node = get_tree().root.find_node("Game", true, false)
	effects_parent = get_tree().root.find_node("Effects", true, false)
	add_child(flash_tween)
	add_child(activation_timer)
	activation_timer.connect("timeout", self, "check_activation")
	activation_timer.start(ACTIVATION_INTERVAL)

func take_damage(amount: int, color: Color):
	health -= amount
	if !active:
		return
	if health <= 0:
		destroy()
		return
	var flash_color := color * FLASH_MULTIPLY
	flash_color.a = 1.0
	for path in flashing_sprites:
		var sprite = get_node(path)
		flash_tween.interpolate_property(sprite, "modulate", flash_color, Color.white, FLASH_TIME)
	flash_tween.start()

func destroy():
	active = false
	game_node.score += score_value
	shape.set_deferred("disabled", true)
	var explosion = explosion_scene.instance()
	explosion.position = position
	effects_parent.add_child(explosion)
	yield(get_tree().create_timer(DESTROY_DELAY), "timeout")
	queue_free()

func check_activation():
	if global_position.y > -activation_margin and not active:
		active = true
	elif global_position.y > get_viewport_rect().size.y + activation_margin and active:
		active = false
		activation_timer.stop()
