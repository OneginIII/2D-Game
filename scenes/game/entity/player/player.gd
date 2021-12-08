extends KinematicBody2D

onready var visual := get_node("Visual")

export var speed := 10.0
export var acceleration := 10.0

var current_move_vector := Vector2.ZERO

func _physics_process(delta):
	var move_vector := Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))
	move_vector = move_vector.clamped(1.0);
	current_move_vector = current_move_vector.move_toward(move_vector, delta * acceleration)
	move_and_collide(current_move_vector * speed)
	
	var mat := visual.material as ShaderMaterial
	mat.set_shader_param("gradient_effect", -current_move_vector.x / (speed * 2.0))
	mat.set_shader_param("warp_effect", current_move_vector.x / (speed * 3.0))
