extends Node

export var debug := true

func _input(event):
	if !debug:
		return
	if event is InputEventKey:
		if event.pressed:
			if event.scancode == KEY_ESCAPE:
				get_tree().quit()
			if event.scancode == KEY_R:
				Engine.time_scale = 5.0
			if event.scancode == KEY_P:
				$Game.score += 100
		else:
			if event.scancode == KEY_R:
				Engine.time_scale = 1.0
