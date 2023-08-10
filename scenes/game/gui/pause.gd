extends Control

# This is the script for the in-game pause menu.

var game_node

func _ready():
	# Get game node reference and hide the pause menu.
	game_node = find_parent("Game")
	visible = false

# This method toggles showing the panel and pausing the game.
func pause(state: bool):
	# Godot has a simple way of pausing the game using the scene tree.
	get_tree().paused = state
	visible = state
	if state == true:
		# If pause state is true, also focus the resume button and hide the
		# pause menu submenus.
		$Menu/Menu/Resume.grab_focus()
		$Menu/.visible = true
		$QuitConfirm.visible = false
		$Settings.visible = false

# This method is called when the quit confirmation panel is opened or closed.
func quit_confirm(state: bool):
	# Set visibilities and focus the correct buttons.
	$Menu.visible = !state
	$QuitConfirm.visible = state
	if state == true:
		$QuitConfirm/QuitConfirm/Buttons/Back.grab_focus()
	else:
		$Menu/Menu/Quit.grab_focus()

# This method is called once the game exit confirmation is made.
func quit_game():
	game_node.exit_game()
	pause(false)

# This input method hides the pause menu if still visible.
func _unhandled_input(event):
	if visible:
		if event.is_action_pressed("pause"):
			pause(false)
			# Important to handle the input so the game doesn't pause again.
			get_tree().set_input_as_handled()

# This method shows and hides the settings menu.
func settings(state: bool):
	# Set visibilities and focus the correct buttons.
	$Menu.visible = !state
	$Settings.visible = state
	if state == true:
		$Settings/CenterContainer/Back.grab_focus()
	else:
		$Menu/Menu/Settings.grab_focus()
