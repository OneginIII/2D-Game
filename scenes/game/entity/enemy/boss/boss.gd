extends "res://scenes/game/entity/enemy/base_enemy.gd"

signal boss_defeated()

const INITIAL_DELAY := 7.5
const IDLE_TIME := 10.0
const SPIN_TIME := 10.0
const GUN_DELAY := 0.05
const GUN_AMOUNT := 12
const BEAM_DELAY := 4.0
const BEAM_LENGTH := 5.0

onready var bullet_scene := preload("res://scenes/game/entity/bullet/enemy/boss_bullet.tscn")
onready var beam_scene := preload("res://scenes/game/entity/bullet/enemy/boss_beam.tscn")
onready var rotator := $Rotator
onready var guns := $Rotator/Guns.get_children()
onready var gun_lights := $Rotator/Lights/Guns.get_children()
onready var doors := $Rotator/Doors.get_children()

var tween := Tween.new()
var gun_timer := Timer.new()
var main_timer := Timer.new()
var beam_timer := Timer.new()
var position_lock := false
var on_idle := true
var level_scroll
var gun_index := 0
var doors_open := false
var current_beam_path : NodePath
var destroyed := false

func _ready():
	level_scroll = game_node.level_node.scroll_speed
	add_child(tween)
	add_child(gun_timer)
	add_child(main_timer)
	add_child(beam_timer)
	gun_timer.one_shot = true
	main_timer.one_shot = true
	beam_timer.one_shot = true
	for light in gun_lights:
		light.modulate = Color.black
	connect("on_activate", self, "on_activate")
	main_timer.connect("timeout", self, "on_main_timer_timeout")
	gun_timer.connect("timeout", self, "on_gun_timer_timeout")
	beam_timer.connect("timeout", self, "on_beam_timer_timeout")
	connect("boss_defeated", game_node, "on_boss_defeated")

func _physics_process(delta):
	if !active and !destroyed:
		return
	if position_lock:
		translate(Vector2.UP * level_scroll * delta)
	else:
		translate(Vector2.UP * (level_scroll / 2.0) * delta)

func on_activate():
	main_timer.start(INITIAL_DELAY)

func on_main_timer_timeout():
	if destroyed:
		return
	if !position_lock:
		position_lock = true
		main_timer.start(IDLE_TIME)
		gun_timer.start(GUN_DELAY)
		return
	if on_idle:
		main_timer.start(SPIN_TIME)
		if doors_open:
			animate_doors(false)
		var rot = randi() % 8 + 1
		rot = rot * 90.0
		tween.interpolate_property(rotator, "rotation", null, deg2rad(rot),
			SPIN_TIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
		tween.start()
		on_idle = false
	else:
		main_timer.start(IDLE_TIME)
		animate_doors(true)
		guns.invert()
		gun_lights.invert()
		beam_timer.start(BEAM_DELAY)
		beam_effects()
		on_idle = true

func on_gun_timer_timeout():
	shoot()
	gun_index += 1
	gun_index = wrapi(gun_index, 0, GUN_AMOUNT)
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

func animate_doors(open: bool = true):
	if open:
		doors[get_angle_index()].get_node("Animation").play("open")
		doors_open = true
	else:
		doors[get_angle_index()].get_node("Animation").play_backwards("open")
		doors_open = false

func get_angle_index() -> int:
	var angle = wrapf(rotator.rotation_degrees, 0.0, 360.0)
	return int(angle / 90.0)

func on_beam_timer_timeout():
	beam()

func beam_effects():
	var center_shader := $Rotator/CenterEffect.material as ShaderMaterial
	var fade_time := 0.5
	tween.interpolate_property(center_shader, "shader_param/pulse_blend", 0.0, 1.0,
		BEAM_DELAY, Tween.TRANS_QUAD, Tween.EASE_IN)
	tween.interpolate_property(center_shader, "shader_param/pulse_blend", 1.0, 0.0,
		fade_time, Tween.TRANS_QUAD, Tween.EASE_IN, BEAM_DELAY + BEAM_LENGTH - fade_time)
	tween.interpolate_property(center_shader, "shader_param/rainbow_blend", 0.0, 1.0,
		fade_time, Tween.TRANS_QUAD, Tween.EASE_IN, BEAM_DELAY - fade_time)
	tween.interpolate_property(center_shader, "shader_param/rainbow_blend", 1.0, 0.0,
		fade_time, Tween.TRANS_QUAD, Tween.EASE_IN, BEAM_DELAY + BEAM_LENGTH - fade_time)
	tween.start()

func beam():
	if !active:
		return
	var beam = beam_scene.instance()
	beam.position = global_position
	beam.position -= bullets_parent.global_position
	beam.fire()
	bullets_parent.add_child(beam)
	current_beam_path = beam.get_path()

func destroy():
	.destroy()
	destroyed = true
	$Rotator/Lights.visible = false
	tween.remove_all()
	if get_node_or_null(current_beam_path):
		get_node(current_beam_path).queue_free()
	emit_signal("boss_defeated")
