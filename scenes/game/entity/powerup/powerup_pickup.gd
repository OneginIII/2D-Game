extends Area2D

# Class for the collectable pickup spawned in the level.

# The resource used as the pickup to collect and customize for.
export(Resource) var powerup_resource

# In ready method, set the pickup sprite to match the powerup resource.
func _ready():
	$Sprite.texture = powerup_resource.powerup_sprite

# Triggered when the player hits the pickup.
func _on_PowerupPickup_body_entered(body):
	# Set the particle's color based on the powerup resource.
	$Particles.modulate = powerup_resource.powerup_color
	# Start particles.
	$Particles.emitting = true
	# Hide sprite and disable collision shape.
	$Sprite.visible = false
	$Shape.set_deferred("disabled", true)
	# Play pickup sound.
	$Audio.play()
	# Check that the collecting node is the player and then call the resource's
	# powerup activation method, giving it that player node to interact with.
	if body is PlayerShip:
		powerup_resource.powerup_activate(body)
	# Timer to remove the node after a delay for the sound and effects to finish.
	get_tree().create_timer(1.5).connect("timeout", self, "queue_free")
