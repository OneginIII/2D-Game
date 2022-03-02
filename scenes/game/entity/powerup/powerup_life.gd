extends "res://scenes/game/entity/powerup/powerup.gd"

# The life powerup resource. Extends base powerup class.

# Class name prefixed with A_ to find it in the resource list more easily.
class_name A_PowerupLife

# When collected add one to the player's lives.
func powerup_activate(player_node: PlayerShip):
	player_node.lives += 1
