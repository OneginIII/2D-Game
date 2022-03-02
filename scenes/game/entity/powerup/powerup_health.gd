extends "res://scenes/game/entity/powerup/powerup.gd"

# The health powerup resource. Extends base powerup class.

# Class name prefixed with A_ to find it in the resource list more easily.
class_name A_PowerupHealth

# A customizable healing amount.
export(int) var heal_amount := 100

# When collected, add the heal amount to the player's health.
func powerup_activate(player_node: PlayerShip):
	player_node.health += heal_amount
