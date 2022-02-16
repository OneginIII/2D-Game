extends Area2D

export var speed : float = 10.0
export var damage : int = 10
export var active_area := Rect2(0.0, 0.0, 128.0, 128.0)
export var color := Color.white * 2.0
export var hit_sound : AudioStream
export var hit_volume := 0.0

onready var audio := AudioStreamPlayer2D.new()
onready var shape := $Shape

var hit := false

func _ready():
	add_child(audio)

func _physics_process(_delta):
	active_area.position = global_position - (active_area.size / 2.0)
	if not active_area.intersects(get_viewport_rect()):
		queue_free()

func hit_target(target: Node):
	if hit: return
	hit = true
	if target.has_method("take_damage"):
		target.take_damage(damage, color)
	visible = false
	shape.set_deferred("disabled", true)
	audio.bus = "Sound"
	audio.stream = hit_sound
	audio.volume_db = hit_volume
	audio.play()
	audio.connect("finished", self, "queue_free")
