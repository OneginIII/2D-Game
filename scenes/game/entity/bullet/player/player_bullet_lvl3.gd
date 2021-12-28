extends "res://scenes/game/entity/bullet/base_bullet.gd"

export var direction := Vector2.UP
var sine_timer := PI / 2.0
var index: int
var on_right: bool

func _ready():
	if index % 2 == 0:
		scale = Vector2(0.5, 0.5)
		damage /= 2

func _physics_process(delta):
	._physics_process(delta)
	if index % 2 == 0:
		if on_right:
			direction.x = sin(sine_timer)
		else:
			direction.x = -sin(sine_timer)
	else:
		direction.x = 0.0
	translate(direction * speed * delta)
	sine_timer += delta * 20.0
	rotation = direction.angle() + (PI / 2.0)
