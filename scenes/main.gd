extends Node

const GAME_SCENE := preload("res://scenes/game/game.tscn")

func _ready():
	var game = GAME_SCENE.instance()
	add_child(game)
