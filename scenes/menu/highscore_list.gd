extends Control

# This script is used by the high score list in the main menu.

# Manipulates the array of score ui entries that are it's children.
onready var score_entries := get_children()

# Called upon entering the high score menu. Updates the labels to contain the
# correct name and score number. The high score list array is passed on to it.
func update_scores(score_list: Array):
	for i in range(score_entries.size()):
		# If there are not enough entries in the array, display empty defaults.
		if score_list.size() < i + 1:
			# Using child order instead of names to access the labels here.
			score_entries[i].get_child(0).text = "-"
			score_entries[i].get_child(1).text = "OOOOOO"
			continue
		# For the existing entries, setting the name label's text first.
		score_entries[i].get_child(0).text = score_list[i][0]
		# For the score, first getting the correct child label.
		var score = score_entries[i].get_child(1)
		# Padding the score number to six zeroes.
		score.text = "%06d" % score_list[i][1]
		# Replacing zeroes with the letter O, just like for the in-game counter.
		score.text = score.text.replace("0", "O")
