extends Node2D

signal score_updated(value)

var score: int = 0 setget set_score
func set_score(value: int):
	score = value
	emit_signal("score_updated", score)

func _ready():
	pass
