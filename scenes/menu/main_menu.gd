extends Control

signal game_started()

func _on_Start_button_down():
	emit_signal("game_started")
	visible = false

func _on_Quit_button_down():
	get_tree().quit()
