extends Node

const MAX_HIGHSCORES := 8

export var debug := true

var highscore_list : Array

func _ready():
	randomize()

func game_started():
	$Game.start_game()

func game_ended():
	$MainMenuLayer/MainMenu.start_menu()

func update_highscore(new_score: Array):
	highscore_list.append(new_score)
	highscore_list.sort_custom(self, "sort_highscore")
	if highscore_list.size() > MAX_HIGHSCORES:
		highscore_list.remove(MAX_HIGHSCORES)

func check_highscore(new_score: int):
	if new_score <= 0:
		return false
	if highscore_list.size() < MAX_HIGHSCORES:
		return true
	for score in highscore_list:
		if score[1] < new_score:
			return true
	return false

func sort_highscore(a: Array, b: Array):
	if a[1] > b[1]:
		return true
	else:
		return false

func _input(event):
	if !debug:
		return
	if event is InputEventKey:
		if event.pressed:
			if event.scancode == KEY_R:
				Engine.time_scale = 25.0
			if event.scancode == KEY_T:
				Engine.time_scale = 0.1
			if event.scancode == KEY_P:
				$Game.score += 100
		else:
			if event.scancode == KEY_R:
				Engine.time_scale = 1.0
			if event.scancode == KEY_T:
				Engine.time_scale = 1.0
