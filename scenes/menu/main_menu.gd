extends Control

signal game_started()

const MENU_FADE := 0.5

export(NodePath) var default_focus_target
export(NodePath) var highscore_list_node

onready var main_node := get_node_or_null("/root/Main")
onready var music := $Music

var tween := Tween.new()

func _ready():
	add_child(tween)
	music.volume_db = -80.0
	tween.interpolate_property(music, "volume_db", null, 0.0, MENU_FADE)
	tween.start()
	music.play()

func start_menu():
	visible = true
	tween.interpolate_property(self, "modulate", null, Color.white, MENU_FADE)
	music.play()
	tween.interpolate_property(music, "volume_db", null, 0.0, MENU_FADE)
	tween.start()
	yield(tween, "tween_all_completed")
	if default_focus_target:
		get_node(default_focus_target).grab_focus()

func exit_menu():
	tween.interpolate_property(self, "modulate", null, Color.transparent, MENU_FADE)
	tween.interpolate_property(music, "volume_db", null, -80.0, MENU_FADE)
	tween.start()
	emit_signal("game_started")
	yield(tween, "tween_all_completed")
	music.stop()
	visible = false

func _on_Start_button_down():
	exit_menu()

func _on_Scores_button_down():
	if main_node and get_node_or_null(highscore_list_node):
		get_node(highscore_list_node).update_scores(main_node.highscore_list)

func _on_Quit_button_down():
	get_tree().quit()
