extends Node2D

signal gun_fired(gun_position, gun_color)
signal gun_level_set(gun_level)

const BULLET_LVL1 := preload("res://scenes/game/entity/bullet/player/player_bullet.tscn")
const BULLET_LVL2 := preload("res://scenes/game/entity/bullet/player/player_bullet_lvl2.tscn")
const BULLET_LVL3 := preload("res://scenes/game/entity/bullet/player/player_bullet_lvl3.tscn")
const LEVEL_1_FIRE_RATE := 0.2
const LEVEL_2_FIRE_RATE := 0.2
const LEVEL_3_FIRE_RATE := 0.1

enum Gun {GUN_LEFT, GUN_RIGHT, GUN_BOTH}
enum GunLevel {LVL1, LVL2, LVL3}

onready var gun_position_left := $GunPositionLeft
onready var gun_position_right := $GunPositionRight

export var fire_rate := LEVEL_1_FIRE_RATE
export var gun_level := 0 setget set_gun_level
func set_gun_level(level: int):
	gun_level = level
	if gun_level >= 6:
		fire_rate = LEVEL_3_FIRE_RATE
		current_gun_mode = GunLevel.LVL3
		bullet_scene = BULLET_LVL3
	elif gun_level >= 3:
		fire_rate = LEVEL_2_FIRE_RATE
		current_gun_mode = GunLevel.LVL2
		bullet_scene = BULLET_LVL2
	else:
		fire_rate = LEVEL_1_FIRE_RATE
		current_gun_mode = GunLevel.LVL1
		bullet_scene = BULLET_LVL1
	emit_signal("gun_level_set", gun_level)

var bullet_scene := BULLET_LVL1
var fire_rate_timer := Timer.new()
var last_fired: int = Gun.GUN_LEFT
var current_gun_mode: int = GunLevel.LVL1
var bullet_index: int = 0
var bullets_parent

func _ready():
	bullets_parent = get_tree().root.find_node("Bullets", true, false)
	add_child(fire_rate_timer)
	fire_rate_timer.one_shot = true

func fire():
	if fire_rate_timer.is_stopped():
		# Condition for level 1 gun's alternating fire style
		if gun_level == GunLevel.LVL1:
			var bullet = bullet_scene.instance()
			if last_fired == Gun.GUN_LEFT:
				bullet.global_position = gun_position_right.global_position
				emit_signal("gun_fired", Gun.GUN_RIGHT, bullet.color)
				last_fired = Gun.GUN_RIGHT
			elif last_fired == Gun.GUN_RIGHT:
				bullet.global_position = gun_position_left.global_position
				emit_signal("gun_fired", Gun.GUN_LEFT, bullet.color)
				last_fired = Gun.GUN_LEFT
			bullets_parent.add_child(bullet)
		else:
			var bullet_left = bullet_scene.instance()
			var bullet_right = bullet_scene.instance()
			bullet_left.global_position = gun_position_left.global_position
			bullet_right.global_position = gun_position_right.global_position
			if bullet_scene == BULLET_LVL3:
				bullet_left.index = bullet_index
				bullet_left.on_right = false
				bullet_right.index = bullet_index
				bullet_right.on_right = true
				bullet_index += 1
				bullet_index %= 100
			bullets_parent.add_child(bullet_left)
			bullets_parent.add_child(bullet_right)
			emit_signal("gun_fired", Gun.GUN_BOTH, bullet_left.color)
		fire_rate_timer.start(fire_rate)
