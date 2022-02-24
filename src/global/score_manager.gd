extends Node

const MAX_HIGHSCORES := 8
const POWERUP_INTERVAL := 250
const POWERUP_MAXED_BONUS := 100
const DEATH_SCORE_MULTIPLY := (1.0 / 3.0) * 2.0

signal score_updated(value)

onready var game_node := get_node("/root/Main/Game")
onready var gui_node := get_node("/root/Main/Game/GuiLayer/GameGui")

var score: int = 0 setget set_score
func set_score(value: int):
	score = value
	if score >= score_treshold:
		game_node.spawn_powerup()
		score_treshold += POWERUP_INTERVAL
	emit_signal("score_updated", score)
var score_treshold := POWERUP_INTERVAL
var highscore_list : Array

func set_highscore(entered_name: String):
	update_highscore([entered_name, score])
	game_node.exit_game()

func reset_score():
	self.score = 0
	gui_node.set_score(score)

func death_penalty():
	self.score *= DEATH_SCORE_MULTIPLY
	score_treshold = int(ceil(float(score) / float(POWERUP_INTERVAL)) * float(POWERUP_INTERVAL))
	if score_treshold < POWERUP_INTERVAL:
		score_treshold = POWERUP_INTERVAL

func on_bonus_powerup():
	print("Bonus score")
	self.score += POWERUP_MAXED_BONUS

func update_highscore(new_score: Array):
	highscore_list.append(new_score)
	highscore_list.sort_custom(self, "sort_highscore")
	if highscore_list.size() > MAX_HIGHSCORES:
		highscore_list.remove(MAX_HIGHSCORES)

func check_highscore():
	if score <= 0:
		return false
	if highscore_list.size() < MAX_HIGHSCORES:
		return true
	for score_entry in highscore_list:
		if score_entry[1] < score:
			return true
	return false

func sort_highscore(a: Array, b: Array):
	if a[1] > b[1]:
		return true
	else:
		return false
