extends Path2D

# Depracated feature.

# The drone had the ability to follow a path forward, which was unused because
# setting up the paths and balancing the enemy didn't work out well enough.

onready var follow := $DroneFollow
onready var drone := $DroneFollow/Drone

export var speed := 100.0
export var vertical_movement := -100.0

func _physics_process(delta):
	if is_instance_valid(drone):
		if drone.active:
			follow.offset += speed * delta
			translate(Vector2.DOWN * vertical_movement * delta)
	else:
		queue_free()
