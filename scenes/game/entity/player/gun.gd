extends Node2D

signal gun_fired(gun_position, gun_color)
signal gun_level_set(gun_level)

const BULLET_INDEX_LIMIT := 100

enum GunPosition {GUN_LEFT, GUN_RIGHT, GUN_BOTH}

onready var gun_position_left := $GunPositionLeft
onready var gun_position_right := $GunPositionRight

export(Array, Resource) var gun_levels
export var current_gun_level := 0 setget set_gun_level
func set_gun_level(level: int):
	current_gun_level = level
	emit_signal("gun_level_set", current_gun_level)

var bullet_scene
var fire_rate_timer := Timer.new()
var last_fired_position: int = GunPosition.GUN_LEFT
var bullet_index: int = 0
var bullets_parent

func _ready():
	bullet_scene = gun_levels[0].bullet_scene
	bullets_parent = get_tree().root.find_node("Bullets", true, false)
	add_child(fire_rate_timer)
	fire_rate_timer.one_shot = true

func fire():
	if fire_rate_timer.is_stopped():
		var gun = gun_levels[current_gun_level]
		if gun.alternating:
			var bullet = gun.bullet_scene.instance()
			bullet.speed = gun.bullet_speed
			bullet.damage = gun.damage
			if last_fired_position == GunPosition.GUN_LEFT:
				bullet.global_position = gun_position_right.global_position
				emit_signal("gun_fired", GunPosition.GUN_RIGHT, bullet.color)
				last_fired_position = GunPosition.GUN_RIGHT
			elif last_fired_position == GunPosition.GUN_RIGHT:
				bullet.global_position = gun_position_left.global_position
				emit_signal("gun_fired", GunPosition.GUN_LEFT, bullet.color)
				last_fired_position = GunPosition.GUN_LEFT
			bullets_parent.add_child(bullet)
		else:
			var bullet_left = gun.bullet_scene.instance()
			bullet_left.speed = gun.bullet_speed
			bullet_left.damage = gun.damage
			var bullet_right = gun.bullet_scene.instance()
			bullet_right.speed = gun.bullet_speed
			bullet_right.damage = gun.damage
			bullet_left.global_position = gun_position_left.global_position
			bullet_right.global_position = gun_position_right.global_position
			if gun.give_index:
				bullet_left.index = bullet_index
				bullet_right.index = bullet_index
				bullet_index += 1
				bullet_index %= BULLET_INDEX_LIMIT
			if gun.give_side:
				bullet_left.on_right = false
				bullet_right.on_right = true
			bullets_parent.add_child(bullet_left)
			bullets_parent.add_child(bullet_right)
			emit_signal("gun_fired", GunPosition.GUN_BOTH, bullet_left.color)
		fire_rate_timer.start(gun.fire_rate)
