extends Node2D

export var destroy_delay := 2.0

func _ready():
	$Particles.emitting = true;
	$Animation.play("light");
	get_tree().create_timer(destroy_delay).connect("timeout", self, "queue_free")
