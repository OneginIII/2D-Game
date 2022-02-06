extends Node2D

export var destroy_delay := 2.0
export var stop_emitting := false
export var emission_stop_delay := 1.0
export var movement_compensation := false

func _ready():
	$Particles.emitting = true;
	$Animation.play("light");
	if stop_emitting:
		get_tree().create_timer(emission_stop_delay).connect("timeout", $Particles, "set", ["emitting", false])
	get_tree().create_timer(destroy_delay).connect("timeout", self, "queue_free")

func _process(delta):
	if movement_compensation:
		translate(Vector2.UP * 120.0 * delta)
