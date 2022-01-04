extends "res://scenes/game/entity/powerup/powerup.gd"

class_name A_PowerupLife

func powerup_activate(player_node: PlayerShip):
	player_node.lives += 1
