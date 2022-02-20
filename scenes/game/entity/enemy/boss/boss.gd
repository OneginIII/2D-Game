extends "res://scenes/game/entity/enemy/base_enemy.gd"

# Boss enemy extending the base enemy class.
# The boss enemy is pretty complex in it's behaviour and is also
# linked to things like game completition.

signal boss_started()
signal boss_defeated()

# The boss works off of a lot of timers, the delays of which are set here.
const INITIAL_DELAY := 7.5
const IDLE_TIME := 10.0
const SPIN_TIME := 10.0
const GUN_DELAY := 0.05
const GUN_AMOUNT := 12
const BEAM_DELAY := 4.0
const BEAM_LENGTH := 5.0
const BEAM_FADE := 0.5

# Besides the normal gun sounds, the beam weapon has two sound effects.
export var chargeup_sound : AudioStream
export var beam_sound : AudioStream

# Preloading the bullet and beam scenes.
onready var bullet_scene := preload("res://scenes/game/entity/bullet/enemy/boss_bullet.tscn")
onready var beam_scene := preload("res://scenes/game/entity/bullet/enemy/boss_beam.tscn")
onready var rotator := $Rotator
# Getting the guns, gun lights and beam doors as arrays of nodes here.
onready var guns := $Rotator/Guns.get_children()
onready var gun_lights := $Rotator/Lights/Guns.get_children()
onready var doors := $Rotator/Doors.get_children()

# Creating an audio player for the beam sound effects.
var beam_audio := AudioStreamPlayer2D.new()
# Initializing the tween and multiple timers used by the boss.
var tween := Tween.new()
var gun_timer := Timer.new()
var main_timer := Timer.new()
var beam_timer := Timer.new()
var position_lock := false
var on_idle := true
# This enemy counteracts the level's scrolling to stay fixed on screen.
var level_scroll
var gun_index := 0
var doors_open := false
# This is used to track the current beam node (if any exist) for deletion.
var current_beam_path : NodePath
var destroyed := false
# Initializing the ShaderMaterial variable for animations later.
var center_shader : ShaderMaterial

func _ready():
	# Getting the scroll speed of the level node.
	level_scroll = game_node.level_node.scroll_speed
	# Adding the tween and timers as children.
	# You can create these nodes in the editor, but since I will be using
	# them exclusively through code, I find creating them and getting the
	# references this way is just more convenient.
	add_child(tween)
	add_child(gun_timer)
	add_child(main_timer)
	add_child(beam_timer)
	# Timers are repeating by default.
	gun_timer.one_shot = true
	main_timer.one_shot = true
	beam_timer.one_shot = true
	# Make all the gun lights dark.
	for light in gun_lights:
		light.modulate = Color.black
	# Connecting the on_activate signal of the base enemy class.
	connect("on_activate", self, "on_activate")
	# Connecting timer signals.
	main_timer.connect("timeout", self, "on_main_timer_timeout")
	gun_timer.connect("timeout", self, "on_gun_timer_timeout")
	beam_timer.connect("timeout", self, "on_beam_timer_timeout")
	# Connecting boss start and defeat signals.
	connect("boss_defeated", game_node, "on_boss_defeated")
	connect("boss_started", game_node, "on_boss_started")
	# Add beam audio child and set output bus.
	add_child(beam_audio)
	beam_audio.bus = "Sound"
	# Get reference to central light shader and reset parameter.
	center_shader = $Rotator/CenterEffect.material as ShaderMaterial
	center_shader.set_shader_param("rainbow_blend", 0.0)

# The movement of the boss enemy is handled in physics process.
func _physics_process(delta):
	# Skip movement logic once destroyed.
	if !active and !destroyed:
		return
	# A the beginning of the boss fight the boss scrolls on to the screen,
	# before locking in place after a certain amount of time.
	if position_lock:
		translate(Vector2.UP * level_scroll * delta)
	else:
		translate(Vector2.UP * (level_scroll / 2.0) * delta)

# The initial delay timer is fired here, that runs until the boss's normal
# behaviour cycle begins.
func on_activate():
	main_timer.start(INITIAL_DELAY)
	emit_signal("boss_started")

# Triggered after the main boss cycle timer runs out.
func on_main_timer_timeout():
	# Skip if destroyed.
	if destroyed:
		return
	# Called after the initial delay, before the position is locked.
	if !position_lock:
		position_lock = true
		main_timer.start(IDLE_TIME)
		gun_timer.start(GUN_DELAY)
		return
	# The on_idle boolean alternates between the "idle" state where the boss
	# charges and fires the main beam weapon and the "non_idle" state where
	# the boss spins around and shoots at a faster pace.
	if on_idle:
		main_timer.start(SPIN_TIME)
		if doors_open:
			animate_doors(false)
		# Randomize an angle for the next rotation in 90 degree incements.
		# Might not rotate the boss at all (probably) because of value wrapping.
		var rot = randi() % 8 + 1
		rot = rot * 90.0
		# A tween node animates the rotation, which has to be converted to radians
		# from the degree angles of the earlier randomizing.
		# A null as the starting value in a tween uses the current property value.
		tween.interpolate_property(rotator, "rotation", null, deg2rad(rot),
			SPIN_TIME, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
		tween.start()
		on_idle = false
	else:
		main_timer.start(IDLE_TIME)
		animate_doors(true)
		# Inverting the array of guns to reverse the shooting order.
		guns.invert()
		# And same for the gun lights.
		gun_lights.invert()
		# Start the timer for firing the beam and call the effects method
		# that animates effects before and after firing.
		beam_timer.start(BEAM_DELAY)
		beam_effects()
		on_idle = true

# Called on the repeating gun timer timeout.
func on_gun_timer_timeout():
	shoot()
	# The gun_index handles which gun to shoot from. Incremented here.
	gun_index += 1
	# Wrapping the index value based on the amount of guns on the boss.
	gun_index = wrapi(gun_index, 0, GUN_AMOUNT)
	# Changing the shooting delay (firing rate) based on the idle state.
	if on_idle:
		gun_timer.start(GUN_DELAY * 4.0)
	else:
		gun_timer.start(GUN_DELAY)

# Method for shooting bullets from the regular guns around the boss.
func shoot():
	if !active:
		return
	var bullet = bullet_scene.instance()
	# Using the gun_index here to determine which gun to fire from.
	bullet.position = guns[gun_index].get_node("Position").global_position
	# Compensating for level scrolling.
	bullet.position -= bullets_parent.global_position
	bullet.rotation = guns[gun_index].get_node("Position").global_rotation
	bullet.direction = bullet.direction.rotated(bullet.rotation)
	bullets_parent.add_child(bullet)
	# Flashing the appropriate gun light.
	tween.interpolate_property(gun_lights[gun_index], "modulate", bullet.color, Color.black, 0.5)
	tween.start()
	audio.global_position = guns[gun_index].get_node("Position").global_position
	# Base class shoot method called to play shooting sounds.
	.shoot()

# Animates the beam doors opening and closing during the firing sequence.
func animate_doors(open: bool = true):
	if open:
		doors[get_angle_index()].get_node("Animation").play("open")
		doors_open = true
	else:
		# A single opening animation can be used and just reversed for closing.
		doors[get_angle_index()].get_node("Animation").play_backwards("open")
		doors_open = false

# This method is used to determine which beam doors are facing down for animating.
# The "-> int" before the colon tells Godot the return type of the method.
func get_angle_index() -> int:
	var angle = wrapf(rotator.rotation_degrees, 0.0, 360.0)
	return int(angle / 90.0)

# This method is called on the beam timer timeout.
# The timer could directly call the "beam" method but leaving this in for
# consistency since the other timers also have a timeout method.
func on_beam_timer_timeout():
	beam()

# This method creates the various tweens used for the effects of firing the beam.
func beam_effects():
	# Some of the tween calls here utilize the delay property to animate things
	# on and off after a certain amount of time. The delays are calculated based
	# on the various constants, some used by the timers.
	tween.interpolate_property(center_shader, "shader_param/pulse_blend", 0.0, 1.0,
		BEAM_DELAY, Tween.TRANS_QUAD, Tween.EASE_IN)
	tween.interpolate_property(center_shader, "shader_param/pulse_blend", 1.0, 0.0,
		BEAM_FADE, Tween.TRANS_QUAD, Tween.EASE_IN, BEAM_DELAY + BEAM_LENGTH - BEAM_FADE)
	tween.interpolate_property(center_shader, "shader_param/rainbow_blend", 0.0, 1.0,
		BEAM_FADE, Tween.TRANS_QUAD, Tween.EASE_IN, BEAM_DELAY - BEAM_FADE)
	tween.interpolate_property(center_shader, "shader_param/rainbow_blend", 1.0, 0.0,
		BEAM_FADE, Tween.TRANS_QUAD, Tween.EASE_IN, BEAM_DELAY + BEAM_LENGTH - BEAM_FADE)
	tween.interpolate_property(beam_audio, "volume_db", 0.0, -80.0,
		BEAM_FADE * 2.0, Tween.TRANS_QUAD, Tween.EASE_IN, BEAM_DELAY + BEAM_LENGTH)
	tween.start()
	# Setting up the beam charging audio.
	beam_audio.volume_db = 0.0
	beam_audio.stream = chargeup_sound
	beam_audio.play()

# This method fires the main beam weapon of the boss.
func beam():
	# Don't fire while inactive.
	if !active:
		return
	var beam = beam_scene.instance()
	beam.position = global_position
	beam.position -= bullets_parent.global_position
	# The beam "bullet" has a fire method for running through it's animations.
	beam.fire()
	bullets_parent.add_child(beam)
	# Saving the current node path of the beam for deletion when boss is destroyed.
	current_beam_path = beam.get_path()
	# Using the same audio player as the chargeup, but changing the sound.
	beam_audio.stream = beam_sound
	beam_audio.play()

# The destroy method of the boss requires a few extra steps than other enemies.
func destroy():
	.destroy()
	# Removing all the tweens to stop animations.
	tween.remove_all()
	# Still need to fade away the beam sound if it's playing.
	tween.interpolate_property(beam_audio, "volume_db", null, -80.0, 1.0)
	tween.start()
	destroyed = true
	# Hiding the gun lights since their animations were stopped.
	$Rotator/Lights.visible = false
	# If there exists a beam object in the saved node path, remove it here.
	if get_node_or_null(current_beam_path):
		get_node(current_beam_path).queue_free()
	# Emitting a signal that triggers various game completion features.
	emit_signal("boss_defeated")
