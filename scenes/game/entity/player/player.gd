extends KinematicBody2D

# This is the script on the player node. The player is a KinematicBody2D that
# can be moved and interact with the physics engine.

# The player also has a class name set.
class_name PlayerShip

# These constants contain defaults, limits and other fixed values.
const FULL_HEALTH := 100
const DEFAULT_SPEED := 500.0
const MAX_SPEED := 1000.0
const FULL_LIVES := 3
const DEATH_DELAY := 3.0
const SPAWN_OFFSET := Vector2(0.5, 0.75)
const SPAWN_LENGTH := 2.0
# The player has a small invulnerability time.
const INVUL_TIME := 0.1

# Signals used for updating gui elements and tracking events.
signal health_updated(value)
signal lives_updated(value)
signal player_destroyed()
signal player_death(out_of_lives)
signal bonus_upgrade(bonus_name)

# Exported variable for the health with a setget method.
export var health := FULL_HEALTH setget set_health
func set_health(value: int):
	# If trying to set health to above full health, reward bonus points.
	if value > FULL_HEALTH:
		emit_signal("bonus_upgrade", "health")
	# Limit health amount.
	health = int(min(value, FULL_HEALTH))
	# Emit signal to update gui.
	emit_signal("health_updated", health)
# Exported variable for the speed with a setget method.
export var speed := DEFAULT_SPEED setget set_speed
func set_speed(value: float):
	# If trying to set the speed to above maximum, reward bonus points.
	if value > MAX_SPEED:
		emit_signal("bonus_upgrade", "speed")
	# Limit speed value.
	speed = min(value, MAX_SPEED)
# Exported variable for the lives with a setget method.
export var lives: int = FULL_LIVES setget set_lives
func set_lives(value: int):
	# If trying to set lives to above full amount, reward bonus points.
	if value > FULL_LIVES:
		emit_signal("bonus_upgrade", "lives")
	# Limit lives amount.
	lives = int(min(value, FULL_LIVES))
	# Emit signal to update gui.
	emit_signal("lives_updated", lives)
# Acceleration used for movement.
export var acceleration := 10.0
# Particle effect scene for the death sequence.
export(PackedScene) var death_particles
# Exported variable for invulnerability. Useful for testing.
export var invulnerable := false
# Damage sound file and volume.
export var damage_sound : AudioStream
export var damage_volume := 0.0

# References, initial position and extra child nodes.
onready var player_visual := $Visual
onready var player_gun := $Gun
onready var player_shape := $Shape
onready var initial_position := position
onready var tween := Tween.new()
onready var invul_timer := Timer.new()
onready var audio := AudioStreamPlayer2D.new()

# Input vector and current movement vector.
var input_move_vector := Vector2.ZERO
var current_move_vector := Vector2.ZERO
# Booleans for death state and control toggling.
var dead := false
var controllable := false

func _ready():
	# Show player, if hidden by other methods.
	visible = false
	# Add and setup tween and timer.
	add_child(tween)
	add_child(invul_timer)
	invul_timer.one_shot = true
	# Connect signals emitted by child gun node.
	player_gun.connect("gun_fired", player_visual, "gun_fired")
	player_gun.connect("gun_level_bonus", self, "on_gun_level_bonus")
	# Connect bonus upgrade signal to score manager to give rewards.
	connect("bonus_upgrade", ScoreManager, "on_bonus_powerup")
	# Player is initially uncontrollable.
	controllable = false
	# Setup audio.
	add_child(audio)
	audio.bus = "Sound"

# The process method handles reading the player input.
func _process(delta):
	# Reading the input axex to form the input Vector2.
	input_move_vector = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))
	# Clamping the vector length to avoid diagonal movement being faster.
	input_move_vector = input_move_vector.limit_length(1.0);
	# Setting the current move vector by using the move toward method.
	# The move toward method is used along with the delta and acceleration to
	# give smooth yet responsive movement.
	current_move_vector = current_move_vector.move_toward(input_move_vector, delta * acceleration)
	# If controllable, also read firing input.
	if Input.is_action_pressed("fire") and controllable:
		# Fire the gun, even every frame. Gun handles the fire rate.
		player_gun.fire()
	if controllable:
		# If controllable, also give the visual node the movement information
		# used for effects.
		player_visual.reference_vector = current_move_vector

# Physics process handles actually moving the KinematicBody2D node.
func _physics_process(_delta):
	# If controllable, use the move and slide method to move using the move
	# vector multiplied by the speed.
	if controllable:
		move_and_slide(current_move_vector * speed)

# This method handles the player taking damage. Triggered by enemy bullets.
func take_damage(amount: int, color: Color):
	# Can't take damage if dead.
	if dead:
		return
	# If the brief invulnerable timer is not stopped, can't take damage.
	if not invul_timer.is_stopped():
		return
	# Start short invulnerable period.
	invul_timer.start(INVUL_TIME)
	# Player visual handles flashing effect on the sprites when hit.
	player_visual.damage_flash(color)
	# Setup and play damage sound.
	audio.stream = damage_sound
	audio.volume_db = damage_volume
	audio.play()
	# If permanently invulnerable, exit the method at this point.
	if invulnerable:
		return
	# Now the player should actually lose health.
	self.health -= amount
	# If out of health, trigger death.
	if health <= 0:
		death()

# This method handles the player dying. Triggered by running out of health.
func death():
	# Emit the player destroyed signal immediately. Stops the music.
	emit_signal("player_destroyed")
	# Dead and not controllable.
	dead = true
	controllable = false
	# Disable the player's collision shape, so that bullets pass through.
	player_shape.set_deferred("disabled", true)
	# Create the death particles.
	var particles = death_particles.instance()
	add_child(particles)
	# Fade out the player visual node.
	tween.interpolate_property(player_visual, "modulate", Color.white, Color.transparent, 1.0)
	tween.start()
	# After the fadeout is done, toggle visibility and reset the modulation.
	yield(get_tree().create_timer(DEATH_DELAY), "timeout")
	player_visual.modulate = Color.white
	visible = false
	# At this point, check what the life status of the player is and send the
	# appropriate signal for the game to either be over or restart at checkpoint.
	if lives <= 0:
		emit_signal("player_death", true)
	else:
		emit_signal("player_death", false)
	# Reduce lives.
	self.lives -= 1

# This method resets the player's state and values to their defaults. Since the
# player is a single instance and always exists, it needs to be done manually.
# Optional argument for a full reset, including lives and upgrades.
func reset_player(full_reset: bool = false):
	# Remove any tweens.
	tween.remove_all()
	# Make visible and reset modulation.
	visible = true
	player_visual.modulate = Color.white
	# Not dead and collision shape should be enabled again.
	dead = false
	player_shape.set_deferred("disabled", false)
	# In the case of a full reset, reset lives, speed and gun level.
	if full_reset:
		self.lives = FULL_LIVES
		self.speed = DEFAULT_SPEED
		player_gun.current_gun_level = 0
	# Animating player ship arrival. First setting the final spawn position.
	position = get_viewport_rect().size * SPAWN_OFFSET
	var reset_position := position
	# Then moving the player out of the screen.
	position.y += get_viewport_rect().size.y * SPAWN_OFFSET.y
	# Lastly, tweening the player position back to the final spawn position.
	tween.interpolate_property(self, "position", null, reset_position,
		SPAWN_LENGTH, Tween.TRANS_QUAD, Tween.EASE_OUT)
	# Tweening the health back to full. This gives a nice effect in the gui.
	tween.interpolate_property(self, "health", null, FULL_HEALTH,
		SPAWN_LENGTH, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()
	# Enable controls only after tweens are complete.
	yield(tween, "tween_all_completed")
	controllable = true

# When the game is completed, there is an additional animation of the player
# flying out of the screen. Setting up the tween to do that here.
func player_victory():
	tween.interpolate_property(self, "position", null,
		position - Vector2(0.0, 2000.0), 3.0, Tween.TRANS_QUAD, Tween.EASE_IN)
	tween.start()

# This method is called by the signal from the player gun. Triggers the bonus
# upgrade signal like health, speed and lives do.
func on_gun_level_bonus():
	emit_signal("bonus_upgrade", "gun")
