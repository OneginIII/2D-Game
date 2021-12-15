extends Node2D

func _ready():
	$Particles.emitting = true;
	$Animation.play("light");
	yield(get_tree().create_timer(2.0), "timeout")
	queue_free()
