extends "res://scenes/game/entity/powerup/powerup.gd"

# The speed powerup resource. Extends base powerup class.

# Class name prefixed with A_ to find it in the resource list more easily.
class_name A_PowerupSpeed

# Customizable speed upgrade amount.
export var speedup_amount := 100.0

# When collected, add the speed upgrade to the player's speed.
func powerup_activate(player_node: PlayerShip):
	player_node.speed += speedup_amount
