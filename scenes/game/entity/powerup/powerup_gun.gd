extends "res://scenes/game/entity/powerup/powerup.gd"

class_name A_PowerupGun

func powerup_activate(player_node: PlayerShip):
	player_node.player_gun.current_gun_level += 1
