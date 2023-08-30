extends Control

# This script manages the in-game gui.

# This is the speed of the score counter when interpolating to a new value.
const TWEEN_SPEED = 250.0

# Signal for once a highscore name has been entered.
signal highscore_entry(entry_name)

# Getting node references.
onready var health_bar := $PlayerInfo/Status/Bottom/HealthBar
onready var score := $PlayerInfo/Score/Score
onready var lives := $PlayerInfo/Status/Top/Lives
onready var power := $PlayerInfo/Power/Bottom/PowerBar
onready var center_text := $CenterText
onready var score_entry := $ScoreEntry

# A few more variables needed.
var player_node
var game_node
var tween := Tween.new()
# This score number is used for animating the score value change over time.
# It stores the last score value before animating to the new one.
var display_score: int

func _ready():
	# Getting references and connecting the necessary signals to keep the gui
	# counters up to date with player status information.
	game_node = find_parent("Game")
	if game_node:
		player_node = game_node.get_node("Player")
		if player_node:
			player_node.connect("health_updated", self, "update_health_bar")
			player_node.player_gun.connect("gun_level_set", self, "set_power")
			player_node.connect("lives_updated", self, "set_lives")
			set_lives(player_node.lives)
			set_power(player_node.player_gun.current_gun_level)
	add_child(tween)
	# Connecting and initializing the global score manager's data.
	connect("highscore_entry", ScoreManager, "set_highscore")
	ScoreManager.connect("score_updated", self, "update_score")
	set_score_text(ScoreManager.score)
	display_score = ScoreManager.score
	# Hiding the center information text.
	center_text.modulate = Color.transparent

# This method updates the health bar based on player's health.
func update_health_bar(value: int):
	# Converting the integer health value to a float for the meter.
	health_bar.value = float(value)

# This method updates the life counter based on the player's lives.
func set_lives(value: int):
	# Using an index and an array of child nodes to set the slot visibilities.
	var index := 1
	for slot in lives.get_children():
		slot.get_child(0).visible = value >= index
		index += 1

# This method updates the weapon power meter based on the player's gun level.
func set_power(value: int):
	# Plus one since the counter visually starts at one.
	power.value = float(value + 1)

# This method updates the score counter.
func update_score(value: int):
	# Calculating tween animation time to be constant per score amount.
	var time = abs(display_score - value) / TWEEN_SPEED
	# Using an interpolation method to update the score text.
	tween.remove_all()
	tween.interpolate_method(self, "set_score_text", display_score, value, time)
	tween.start()
	# Updating the display score after triggering the tween.
	display_score = value

# This method sets the score amount text.
func set_score_text(value: int):
	# Sets the score value to be padded to six zeroes.
	score.text = "%06d" % value
	# Replacing zeroes in the score text by the letter O.
	# I found the O to be visually nicer than the zero in the font I used.
	score.text = score.text.replace("0", "O")

# This method can be called to skip animating the score and instantly set it.
func set_score(value: int):
	# Remove any tweens.
	tween.remove(self, "set_score_text")
	# Set the display score value and the counter text.
	display_score = value
	set_score_text(value)

# This method displays a message at the center of the screen.
func center_message(text: String):
	# Set the text.
	center_text.get_node("Text").text = text
	# Two interpolate property calls, one for fade in and a delayed one for fade out.
	tween.interpolate_property(center_text, "modulate", Color.transparent, Color.white, 1.0)
	tween.interpolate_property(center_text, "modulate", Color.white, Color.transparent, 1.0,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 3.0)
	tween.start()

# Once entering a high score, display the entry prompt.
func enter_score():
	score_entry.visible = true
	var line_edit := get_node("ScoreEntry/Menu/LineEdit")
	# Grabbing input focus on the line edit and clearing it's last text.
	line_edit.grab_focus()
	line_edit.clear()

# This method is called once the highscore entry is exited via the confirm button.
func score_entered():
	# This signal delivers the name entered to the score manager.
	emit_signal("highscore_entry", score_entry.get_node("Menu/LineEdit").text)
	score_entry.visible = false
