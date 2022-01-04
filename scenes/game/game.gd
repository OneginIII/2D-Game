extends Node2D

const POWERUP_PICKUP := preload("res://scenes/game/entity/powerup/powerup_pickup.tscn")
const POWERUP_INTERVAL := 200

signal score_updated(value)

onready var player_node := $Player
onready var powerup_spawn_point := $PowerupSpawnPoint

export(NodePath) var level_path
export(Dictionary) var powerup_list
export(Array, String) var powerup_order

var level_node
var powerup_index := 0
var score_treshold := POWERUP_INTERVAL

var score: int = 0 setget set_score
func set_score(value: int):
	score = value
	if score >= score_treshold:
		spawn_powerup()
		score_treshold += POWERUP_INTERVAL
	emit_signal("score_updated", score)

func _ready():
	level_node = get_node(level_path)
	player_node.connect("player_death", self, "player_death")

func start_game():
	score = 0
	player_node.health = player_node.MAX_HEALTH
	player_node.lives = player_node.DEFAULT_LIVES

func player_death(out_of_lives: bool):
	pass

func spawn_powerup():
	var powerup_node = POWERUP_PICKUP.instance()
	var powerup_type = powerup_order[powerup_index]
	powerup_node.powerup_resource = load(powerup_list[powerup_type])
	powerup_node.position = powerup_spawn_point.position
	powerup_node.position -= level_node.global_position
	level_node.call_deferred("add_child", powerup_node)
	if powerup_index < powerup_order.size() - 1:
		powerup_index += 1
	else:
		powerup_index = 0
