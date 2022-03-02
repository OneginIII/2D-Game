extends Resource

# Base class for all powerups. Powerups are resources that are "embedded" in
# the powerup pickups, giving the player various boosts when collected.

# Powerups have a color for effects.
export(Color) var powerup_color := Color.white
# Powerups have a sprite.
export(Texture) var powerup_sprite

# This empty activate method is overriden by the derived powerup classes.
func powerup_activate(_player_node: PlayerShip):
	pass
