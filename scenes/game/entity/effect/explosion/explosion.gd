extends Node2D

# Explosion effect used when enemies and player are destroyed.

# Variables adjustable for the unique explosion effect variations.
export var destroy_delay := 2.0
export var stop_emitting := false
export var emission_stop_delay := 1.0
export var movement_compensation := false

func _ready():
	# Start emitting particles on ready and play animation for light sprite.
	$Particles.emitting = true;
	$Animation.play("light");
	# If the emission of particles is set to stop manually, use a delay for that.
	# This signal connection is a bit complicated, but it calls the "set" method,
	# which takes two arguments which are set for the signal by an array.
	if stop_emitting:
		get_tree().create_timer(emission_stop_delay).connect("timeout", $Particles, "set", ["emitting", false])
	# Creating a SceneTreeTimer to delete the node after the set delay.
	get_tree().create_timer(destroy_delay).connect("timeout", self, "queue_free")

# If compensating for screen movement, doing that in the process function.
func _process(delta):
	if movement_compensation:
		# 120.0 is the amount of scroll used by the main level, typed here
		# directly because I was lazy :)
		translate(Vector2.UP * 120.0 * delta)
