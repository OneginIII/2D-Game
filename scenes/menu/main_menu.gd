extends Control

signal game_started()

export(NodePath) var default_focus_target
export(NodePath) var highscore_list_node

onready var main_node := get_node_or_null("/root/Main")

var tween := Tween.new()

func start_menu():
	visible = true
	tween.interpolate_property(self, "modulate", null, Color.white, 0.5)
	tween.start()
	yield(tween, "tween_all_completed")
	if default_focus_target:
		get_node(default_focus_target).grab_focus()

func _ready():
	add_child(tween)

func _on_Start_button_down():
	tween.interpolate_property(self, "modulate", null, Color.transparent, 0.5)
	tween.start()
	emit_signal("game_started")
	yield(tween, "tween_all_completed")
	visible = false

func _on_Scores_button_down():
	if main_node and get_node_or_null(highscore_list_node):
		get_node(highscore_list_node).update_scores(main_node.highscore_list)

func _on_Quit_button_down():
	get_tree().quit()
