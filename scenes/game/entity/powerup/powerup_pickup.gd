extends Area2D

export(Resource) var powerup_resource

func _ready():
	$Sprite.texture = powerup_resource.powerup_sprite

func _on_PowerupPickup_body_entered(body):
	$Particles.modulate = powerup_resource.powerup_color
	$Particles.emitting = true
	$Sprite.visible = false
	$Shape.set_deferred("disabled", true)
	$Audio.play()
	if body is PlayerShip:
		powerup_resource.powerup_activate(body)
	get_tree().create_timer(1.5).connect("timeout", self, "queue_free")
