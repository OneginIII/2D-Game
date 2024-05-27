extends Control

# Script used by the main menu.

# Fade time for menu.
const MENU_FADE := 0.5

# Signals for starting and quitting the game.
signal game_started()
signal game_quit()

# Exported node paths for focus target and highscore list parent node.
export(NodePath) var default_focus_target
export(NodePath) var highscore_list_node

# References to nodes.
onready var main_node := get_node_or_null("/root/Main")
onready var main_panel := $MainPanel
onready var music := $Music
onready var ship := $ShipDecoration

# Tween used for fading the menu and music.
var tween := Tween.new()

func _ready():
	add_child(tween)
	# When ready, start the main menu with the first start boolean true.
	start_menu(true)

# This method handles entering the main menu. Optional boolean for first start.
func start_menu(first_start: bool=false):
	visible = true
	# Main panel is hidden by default. This is for menu button sound reasons.
	main_panel.visible = true
	# Reset the decorative ship in the main menu background.
	ship.reset_ship()
	# Start main menu music.
	toggle_music(true)
	# Checking and setting the default focused button at the start of the menu.
	var initial_button = null
	if default_focus_target:
			initial_button = get_node(default_focus_target)
	# If it's the first time starting the menu, just grab focus and exit method.
	if first_start:
		if initial_button != null: initial_button.grab_focus()
		return
	# If not the first time, fade the menu in and after grab focus.
	tween.interpolate_property(self, "modulate", null, Color.white, MENU_FADE)
	tween.start()
	yield (tween, "tween_all_completed")
	if initial_button != null: initial_button.grab_focus()

# This method handles exiting the main menu.
func exit_menu():
	# Signal that the game is starting.
	emit_signal("game_started")
	# Turn off main menu music.
	toggle_music(false)
	# Fade the menu out.
	tween.interpolate_property(self, "modulate", null, Color.transparent, MENU_FADE)
	tween.start()
	# Once faded out, make the menu hidden, so it won't interfere with anything.
	yield (tween, "tween_all_completed")
	visible = false

# This method toggles the main menu music on and off based on a boolean argument.
func toggle_music(on: bool):
	if on:
		# Fade the music volume in and start playing it.
		tween.interpolate_property(music, "volume_db", null, 0.0, MENU_FADE)
		music.play()
	else:
		# Fade the music volume out and stop the player once done.
		tween.interpolate_property(music, "volume_db", null, -80.0, MENU_FADE)
		# Using a scene tree timer connected to the stop method to stop the player.
		get_tree().create_timer(MENU_FADE).connect("timeout", music, "stop")
	# Start the tween setup above.
	tween.start()

# Connected to a button via editor.
func _on_Start_button_down():
	exit_menu()

# Connected to a button via editor.
func _on_Scores_button_down():
	# Update the high score list with the correct data.
	if get_node_or_null(highscore_list_node):
		get_node(highscore_list_node).update_scores(ScoreManager.highscore_list)

# Connected to a button via editor.
func _on_Quit_button_down():
	# This signal is used by the main node to quit the game.
	emit_signal("game_quit")
