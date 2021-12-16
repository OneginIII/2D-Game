extends Node2D

const explosion_scene := preload("res://scenes/game/entity/effect/explosion/explosion.tscn")

export var health : int = 100
export (Array, NodePath) var flashing_sprites

onready var shape := $Shape

var active := true
var flash_tween := Tween.new()
var effects_parent

const FLASH_MULTIPLY = 2.5
const FLASH_TIME = 0.2
const DESTROY_DELAY = 0.5

func _ready():
	effects_parent = get_tree().root.find_node("Effects", true, false)
	add_child(flash_tween)

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
	shape.set_deferred("disabled", true)
	var explosion = explosion_scene.instance()
	explosion.position = position
	effects_parent.add_child(explosion)
	yield(get_tree().create_timer(DESTROY_DELAY), "timeout")
	queue_free()
