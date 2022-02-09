extends "res://scenes/game/entity/powerup/powerup.gd"

class_name A_PowerupHealth

export(int) var heal_amount := 100

func powerup_activate(player_node: PlayerShip):
	player_node.health += heal_amount
