extends Control

onready var health_bar := $PlayerInfo/Status/Bottom/HealthBar
onready var score := $PlayerInfo/Score/Score
onready var lives := $PlayerInfo/Status/Top/Lives
onready var power := $PlayerInfo/Power/Bottom/PowerBar

var player_node
var game_node
var score_tween := Tween.new()
var display_score: int

const SCORE_TWEEN_SPEED = 50.0

func _ready():
	player_node = get_tree().root.find_node("Player", true, false)
	player_node.connect("health_updated", self, "update_health_bar")
	player_node.player_gun.connect("gun_level_set", self, "set_power")
	game_node = get_tree().root.find_node("Game", true, false)
	game_node.connect("score_updated", self, "update_score")
	game_node.connect("lives_updated", self, "set_lives")
	set_score_text(game_node.score)
	set_lives(game_node.lives)
	set_power(player_node.player_gun.current_gun_level)
	add_child(score_tween)

func update_health_bar(value: int):
	health_bar.value = float(value)

func set_lives(value: int):
	var index := 1
	for slot in lives.get_children():
		slot.get_child(0).visible = value >= index
		index += 1

func set_power(value: int):
	power.value = float(value + 1)

func update_score(value: int):
	display_score = int(score.text)
	var time = abs(display_score - value) / SCORE_TWEEN_SPEED
	score_tween.interpolate_method(self, "set_score_text", display_score, value, time)
	score_tween.start()

func set_score_text(value: int):
	score.text = "%08d" % value
	score.text = score.text.replace("0", "O")
