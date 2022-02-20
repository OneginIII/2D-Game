extends Area2D

# Base class all bullets derive from.
# Contains basic aspects for all bullets.

# All bullets have a speed and damage value.
export var speed : float = 10.0
export var damage : int = 10
# Active area to manage deleting off-screen bullets.
export var active_area := Rect2(0.0, 0.0, 128.0, 128.0)
# All bullets have a color that is used for a flashing hit effect.
export var color := Color.white * 2.0
# Sound file used for the hit sound.
export var hit_sound : AudioStream
export var hit_volume := 0.0

# Creating a player for the hit sound.
onready var audio := AudioStreamPlayer2D.new()
onready var shape := $Shape

# An extra bool to make sure bullets can't hit twice.
var hit := false

func _ready():
	add_child(audio)

func _physics_process(_delta):
	# Checking rect intersections every physics frame to
	# find out if the bullet is off-screen for removal.
	active_area.position = global_position - (active_area.size / 2.0)
	if not active_area.intersects(get_viewport_rect()):
		queue_free()

# This method is called by the Area2D node's body_entered signal.
func hit_target(target: Node):
	# Checking that bullet hits only once.
	if hit: return
	hit = true
	# If the target has a method for taking damage, calling it.
	if target.has_method("take_damage"):
		# The take_damage method has the damage value and color for effects.
		target.take_damage(damage, color)
	# The rest of the method is used to "hide" the bullet and play the sound.
	visible = false
	set_physics_process(false)
	shape.set_deferred("disabled", true)
	audio.bus = "Sound"
	audio.stream = hit_sound
	audio.volume_db = hit_volume
	audio.play()
	# Connecting the audio's finished signal for deleting the bullet after.
	audio.connect("finished", self, "queue_free")
