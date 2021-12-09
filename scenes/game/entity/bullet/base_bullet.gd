extends Area2D

export var direction_vector := Vector2(0.0, -100.0)
export var lifetime := 5.0

var lifetime_timer := Timer.new()

func _ready():
	add_child(lifetime_timer)
	lifetime_timer.connect("timeout", self, "queue_free")
	lifetime_timer.start(lifetime)

func _physics_process(delta):
	translate(direction_vector * delta)
