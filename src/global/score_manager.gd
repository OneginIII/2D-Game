extends Node

# This is the singleton global score manager class.
# Manages score during game session and the list of highscores.

# Limited to 8 highscores.
const MAX_HIGHSCORES := 8
# Interval for spawning powerups every nth score reached.
const POWERUP_INTERVAL := 250
# When the respective powerup boosts are maxed, gives this bonus score.
const POWERUP_MAXED_BONUS := 100
# The score penalty multiplier when dying.
const DEATH_SCORE_MULTIPLY := 3.0 / 4.0

# Signal for updating gui when score changes.
signal score_updated(value)

# Getting the node references needed. Just using fixed node paths here.
onready var game_node := get_node("/root/Main/Game")
onready var gui_node := get_node("/root/Main/Game/GuiLayer/GameGui")

# The score value. Has a setget method for handling powerups and emitting signal.
var score: int = 0 setget set_score
func set_score(value: int):
	# Setting the value. Remember to do this whenever using setget.
	score = value
	# If the score treshold has been reached, spawn powerup and raise treshold.
	if score >= score_treshold:
		game_node.spawn_powerup()
		score_treshold += POWERUP_INTERVAL
	# Emit score update signal.
	emit_signal("score_updated", score)
# Score threshold value for when to spawn next powerup.
var score_treshold := POWERUP_INTERVAL
# Score at last checkpoint for resetting
var checkpoint_score := 0
# Array for the list of highscores. This array is two dimensional, i.e. an array
# of arrays. You can think of the columns as the entries and the rows as being
# the name and score amount of each entry respectively.
var highscore_list : Array

# This method resets the score amount and also the gui score counter.
func reset_score():
	# Calling score as self.score to make sure setget method is called also.
	self.score = 0
	score_checkpoint()
	gui_node.set_score(score)

func score_checkpoint():
	checkpoint_score = score

# Applies the death penalty multiplier to the score. Called when player dies.
func death_penalty():
	# Revert the score to checkpoint value and multiply it.
	# This line gives a narrowing conversion warning for converting
	# from multiplied float back to integer. Works as intended.
	checkpoint_score = checkpoint_score * DEATH_SCORE_MULTIPLY
	self.score = checkpoint_score
	# This formula calculates the new score treshold. As the player loses 1/3
	# of score on each death, the next powerup treshold is adjusted to always
	# land on the next increment of the treshold (the next 250 in this case).
	score_treshold = int(ceil(float(score) / float(POWERUP_INTERVAL)) * float(POWERUP_INTERVAL))
	# If the treshold is below the interval (below 250),
	# make the treshold the interval.
	if score_treshold < POWERUP_INTERVAL:
		score_treshold = POWERUP_INTERVAL

# When collecting an extra powerup, this method gives bonus points.
func on_bonus_powerup():
	# Calling score as self.score to make sure setget method is called also.
	self.score += POWERUP_MAXED_BONUS

# Setting a highscore in the list. Takes in the name of the entry.
func set_highscore(entered_name: String):
	# Calling update highscore method with name and current score.
	update_highscore([entered_name, score])
	# Exits the game. The game waits for highscore entry to finish.
	game_node.exit_game()

# Updates highscore list array. Takes an array of the new name and score.
func update_highscore(new_score: Array):
	# Add the new entry array to the highscore list array.
	highscore_list.append(new_score)
	# Sort the list array with a custom sort method for the highscores.
	highscore_list.sort_custom(self, "sort_highscore")
	# If the now high to low ordered list of highscores is more than the maximum
	# allowed, remove the last and lowest score entry.
	if highscore_list.size() > MAX_HIGHSCORES:
		highscore_list.remove(MAX_HIGHSCORES)

# Check if the current score is a new highscore. If not, highscore entry prompt
# will not be displayed.
func check_highscore() -> bool:
	# A score of zero does not give a new highscore.
	if score <= 0:
		return false
	# If the list of highscores is not at the maximum yet, every new (>0) score
	# is a new highscore.
	if highscore_list.size() < MAX_HIGHSCORES:
		return true
	# If the list is full, iterate through to find if this new score is higher
	# than any in the list. I think you could just check the lowest score, since
	# the array should be correctly sorted, but leaving in this implementation.
	for score_entry in highscore_list:
		# The index 1 of the score entry is the score amount, 0 is the name.
		if score_entry[1] < score:
			return true
	# If can't find a lower score, return false.
	return false

# Custom sort method for the highscores. Takes in two arrays of highscore entries.
# Check the Godot class reference for Array's sort_custom for more information.
func sort_highscore(a: Array, b: Array) -> bool:
	# Checks which of the index 1s, the score amount, is higher.
	if a[1] > b[1]:
		return true
	else:
		return false
