extends Control

onready var score_entries := get_children()

func update_scores(score_list: Array):
	for i in range(score_entries.size()):
		if score_list.size() < i + 1:
			score_entries[i].get_child(0).text = "-"
			score_entries[i].get_child(1).text = "OOOOOOOO"
			continue
		score_entries[i].get_child(0).text = score_list[i][0]
		var score = score_entries[i].get_child(1)
		score.text = "%08d" % score_list[i][1]
		score.text = score.text.replace("0", "O")
