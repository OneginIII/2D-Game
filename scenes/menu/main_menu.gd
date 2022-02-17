extends Control

signal game_started()
signal game_quit()

const MENU_FADE := 0.5

export(NodePath) var default_focus_target
export(NodePath) var highscore_list_node

onready var main_node := get_node_or_null("/root/Main")
onready var main_panel := $MainPanel
onready var music := $Music

var tween := Tween.new()

func _ready():
	add_child(tween)
	start_menu(true)

func start_menu(first_start: bool = false):
	visible = true
	main_panel.visible = true
	toggle_music(true)
	var initial_button = null
	if default_focus_target:
			initial_button = get_node(default_focus_target)
	if first_start:
		if initial_button != null: initial_button.grab_focus()
		return
	tween.interpolate_property(self, "modulate", null, Color.white, MENU_FADE)
	tween.start()
	yield(tween, "tween_all_completed")
	if initial_button != null: initial_button.grab_focus()

func exit_menu():
	emit_signal("game_started")
	toggle_music(false)
	tween.interpolate_property(self, "modulate", null, Color.transparent, MENU_FADE)
	tween.start()
	yield(tween, "tween_all_completed")
	visible = false

func toggle_music(on: bool):
	if on:
		tween.interpolate_property(music, "volume_db", null, 0.0, MENU_FADE)
		music.play()
	else:
		tween.interpolate_property(music, "volume_db", null, -80.0, MENU_FADE)
		get_tree().create_timer(MENU_FADE).connect("timeout", music, "stop")
	tween.start()

func _on_Start_button_down():
	exit_menu()

func _on_Scores_button_down():
	if main_node and get_node_or_null(highscore_list_node):
		get_node(highscore_list_node).update_scores(main_node.highscore_list)

func _on_Quit_button_down():
	emit_signal("game_quit")
