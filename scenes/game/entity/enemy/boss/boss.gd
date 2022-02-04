extends "res://scenes/game/entity/enemy/base_enemy.gd"

const INITIAL_DELAY := 7.5
const IDLE_TIME := 10.0
const SPIN_TIME := 10.0
const GUN_DELAY := 0.1
const GUN_AMOUNT := 12

onready var bullet_scene := preload("res://scenes/game/entity/bullet/enemy/boss_bullet.tscn")
onready var beam_scene := preload("res://scenes/game/entity/bullet/enemy/boss_beam.tscn")
onready var rotator := $Rotator
onready var guns := $Rotator/Guns.get_children()
onready var gun_lights := $Rotator/Lights/Guns.get_children()
onready var beam_lights := $Rotator/Lights/Beam.get_children()

var tween := Tween.new()
var gun_timer := Timer.new()
var main_timer := Timer.new()
var position_lock := false
var on_idle := true
var level_scroll
var gun_index := 0

func _ready():
	level_scroll = game_node.level_node.scroll_speed
	add_child(tween)
	add_child(gun_timer)
	add_child(main_timer)
	gun_timer.one_shot = true
	main_timer.one_shot = true
	for light in gun_lights + beam_lights:
		light.modulate = Color.black
	connect("on_activate", self, "on_activate")
	main_timer.connect("timeout", self, "on_main_timer_timeout")
	gun_timer.connect("timeout", self, "on_gun_timer_timeout")

func _physics_process(delta):
	if !active:
		return
	if position_lock:
		translate(Vector2.UP * level_scroll * delta)
	else:
		translate(Vector2.UP * (level_scroll / 2.0) * delta)

func on_activate():
	main_timer.start(INITIAL_DELAY)

func on_main_timer_timeout():
	if !position_lock:
		position_lock = true
		main_timer.start(IDLE_TIME)
		gun_timer.start(GUN_DELAY)
		return
	if on_idle:
		main_timer.start(SPIN_TIME)
		var rot = randi() % 8 + 1
		rot = rot * 90.0
		tween.interpolate_property(rotator, "rotation", null, deg2rad(rot),
			SPIN_TIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
		tween.start()
		gun_index = 0
		on_idle = false
	else:
		main_timer.start(IDLE_TIME)
		beam()
		on_idle = true

func on_gun_timer_timeout():
	shoot()
	gun_index += 1
	gun_index = wrapi(gun_index, 0, GUN_AMOUNT - 1)
	if on_idle:
		gun_timer.start(GUN_DELAY * 4.0)
	else:
		gun_timer.start(GUN_DELAY)

func shoot():
	if !active:
		return
	var bullet = bullet_scene.instance()
	bullet.position = guns[gun_index].get_node("Position").global_position
	bullet.position -= bullets_parent.global_position
	bullet.rotation = guns[gun_index].get_node("Position").global_rotation
	bullet.direction = bullet.direction.rotated(bullet.rotation)
	bullets_parent.add_child(bullet)
	tween.interpolate_property(gun_lights[gun_index], "modulate", bullet.color, Color.black, 0.5)
	tween.start()

func beam():
	if !active:
		return
	var beam = beam_scene.instance()
	beam.position = global_position
	beam.position -= bullets_parent.global_position
	beam.fire()
	bullets_parent.add_child(beam)
