extends "res://scenes/game/entity/powerup/powerup.gd"

# The gun powerup resource. Extends base powerup class.

# Class name prefixed with A_ to find it in the resource list more easily.
class_name A_PowerupGun

# When the gun powerup is collected, it adds one to the player's gun's level.
func powerup_activate(player_node: PlayerShip):
	player_node.player_gun.current_gun_level += 1
