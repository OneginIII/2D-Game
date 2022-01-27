extends Node2D

const POWERUP_PICKUP := preload("res://scenes/game/entity/powerup/powerup_pickup.tscn")
const POWERUP_INTERVAL := 200
const SPAWN_OFFSET := Vector2(960.0 ,864.0)
const CHECKPOINT_MESSAGE := "Checkpoint Reached"
const GAME_OVER_MESSAGE := "Game Over"
const DEATH_SCORE_MULTIPLY := 0.75

signal score_updated(value)

onready var player_node := $Player
onready var gui_node := $GuiLayer/GameGui
onready var powerup_spawn_point := $PowerupSpawnPoint

export(PackedScene) var level_scene
export(Dictionary) var powerup_list
export(Array, String) var powerup_order

var level_node
var powerup_index := 0
var score_treshold := POWERUP_INTERVAL
var current_checkpoint := ""

var score: int = 0 setget set_score
func set_score(value: int):
	score = value
	if score >= score_treshold:
		spawn_powerup()
		score_treshold += POWERUP_INTERVAL
	emit_signal("score_updated", score)

func _ready():
	level_node = level_scene.instance()
	add_child(level_node)
	player_node.connect("player_death", self, "player_death")

func start_game():
	score = 0
	current_checkpoint = ""
	player_node.reset_player(true)
	reload_level()

func game_over():
	gui_node.center_message(GAME_OVER_MESSAGE)
	player_node.set_process(false)

func reload_level():
	level_node.queue_free()
	yield(get_tree(), "idle_frame")
	level_node = level_scene.instance()
	add_child(level_node)
	if current_checkpoint != "":
		level_node.position.y -= level_node.checkpoints[current_checkpoint].level_scroll
		level_node.position.y += SPAWN_OFFSET.y
		level_node.checkpoints[current_checkpoint].display_message = false
	player_node.player_gun.bullets_parent = level_node.bullets
	for checkpoint in level_node.checkpoints:
		level_node.checkpoints[checkpoint].connect("checkpoint_reached", self, "checkpoint_reached")
	level_node.running = true
	

func player_death(out_of_lives: bool):
	if out_of_lives:
		game_over()
		return
	player_node.position = SPAWN_OFFSET
	reload_level()
	player_node.reset_player()
	self.score *= DEATH_SCORE_MULTIPLY
	score_treshold = int(ceil(float(score) / float(POWERUP_INTERVAL)) * float(POWERUP_INTERVAL))

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

func checkpoint_reached(checkpoint_name: String, display_message: bool):
	current_checkpoint = checkpoint_name
	for checkpoint in level_node.checkpoints:
		level_node.checkpoints[checkpoint].active = true
	level_node.checkpoints[checkpoint_name].active = false
	if display_message:
		gui_node.center_message(CHECKPOINT_MESSAGE)
