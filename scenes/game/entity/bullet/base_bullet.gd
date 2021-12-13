extends Area2D

export var speed : float = 10.0
export var damage : int = 10
export var active_area := Rect2(0.0, 0.0, 128.0, 128.0)

func _physics_process(delta):
	active_area.position = global_position - (active_area.size / 2.0)
	if not active_area.intersects(get_viewport_rect()):
		queue_free()
