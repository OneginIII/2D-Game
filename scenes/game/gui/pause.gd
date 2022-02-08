extends Control

var game_node

func _ready():
	game_node = get_tree().root.find_node("Game", true, false)
	visible = false

func pause(state: bool):
	get_tree().paused = state
	visible = state
	if state == true:
		$Menu/Resume.grab_focus()
		$Menu.visible = true
		$QuitConfirm.visible = false

func quit_confirm(state: bool):
	$Menu.visible = !state
	$QuitConfirm.visible = state
	if state == true:
		$QuitConfirm/Buttons/Back.grab_focus()
	else:
		$Menu/Quit.grab_focus()

func quit_game():
	game_node.exit_game()
	pause(false)

func _unhandled_input(event):
	if visible:
		if event.is_action_pressed("pause"):
			pause(false)
			get_tree().set_input_as_handled()
