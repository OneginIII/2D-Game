extends "res://scenes/game/entity/powerup/powerup.gd"

class_name A_PowerupSpeed

export var speedup_amount := 100.0

func powerup_activate(player_node: PlayerShip):
	player_node.speed += speedup_amount
