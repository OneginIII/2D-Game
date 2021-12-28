extends Node2D

signal score_updated(value)
signal lives_updated(value)

const DEFAULT_LIVES = 3

onready var player_node := $Player

var score: int = 0 setget set_score
func set_score(value: int):
	score = value
	emit_signal("score_updated", score)
var lives: int = 3 setget set_lives
func set_lives(value: int):
	lives = value
	emit_signal("lives_updated", lives)

func _ready():
	pass

func start_game():
	lives = DEFAULT_LIVES
	score = 0
	player_node.health = player_node.MAX_HEALTH
