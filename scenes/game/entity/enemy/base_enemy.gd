extends Node2D

# Base class all enemies derive from.
# Contains the common functionality of all enemies.

# The basic explosion effect used by default is preloaded here.
const EXPLOSION_SCENE := preload("res://scenes/game/entity/effect/explosion/explosion.tscn")
const FLASH_MULTIPLY = 2.5
const FLASH_TIME = 0.2
const ACTIVATION_INTERVAL = 0.1

signal on_activate()

export var health : int = 100
# A list of NodePaths to sprites that flash with bullet color when hit.
export (Array, NodePath) var flashing_sprites
# Margin used to activate the enemies while still positioned off-screen.
export var activation_margin : float = 64.0
export var score_value := 10
# Optional alternative explosion effect.
export (PackedScene) var alternative_explosion
# Delay before the enemy is removed.
export var destroy_delay := 0.5
# Sound for enemies shooting.
export var shoot_sound : AudioStream
export var shoot_volume := 0.0

# Audio player for shoot sound.
onready var audio := AudioStreamPlayer2D.new()
onready var shape := $Shape

# Variables for references to certain nodes that the
# enemy might need to function, such as the player
# for aiming at them.
var player_node
var game_node
var bullets_parent
var effects_parent
# Enemies are inactive until entering the player's screen.
var active := false
# Tween for flashing the sprites and fading the enemy on destruction.
var modulate_tween := Tween.new()
# Timer used for periodically checking activation state.
var activation_timer := Timer.new()

func _ready():
	add_child(modulate_tween)
	add_child(activation_timer)
	# Starting and connecting the activation timer, repeating by default.
	activation_timer.connect("timeout", self, "check_activation")
	activation_timer.start(ACTIVATION_INTERVAL)
	# Adding audio player child for shooting sound.
	add_child(audio)
	audio.bus = "Sound"
	# Using find_parent to get the game node and then using that reference
	# as a base to get the other nodes the base enemy needs.
	game_node = find_parent("Game")
	# If game node is found all the rest should be available.
	if game_node:
		# The player nodes name and position in tree should be fixed.
		player_node = game_node.get_node("Player")
		# Have to use find_node here since the level node's name might change.
		bullets_parent = game_node.find_node("Bullets", true, false)
		effects_parent = game_node.find_node("Effects", true, false)
		# You can't use the game node's variables for this since it's ready
		# callback will only be called after it's children's ready.

# This method is called by incoming bullets to damage enemies.
func take_damage(amount: int, color: Color):
	# Can't hit inactive enemies.
	if !active:
		return
	# Reduce health and destroy dead enemies.
	health -= amount
	if health <= 0:
		destroy()
		return
	# Effect of flashing the sprites included in the flashing_sprites array.
	# Making the flash a bit brighter.
	var flash_color := color * FLASH_MULTIPLY
	# Don't want to multiply the alpha.
	flash_color.a = 1.0
	# Iterate through the sprites and add a tween for each, then start them.
	for path in flashing_sprites:
		var sprite = get_node(path)
		modulate_tween.interpolate_property(sprite, "modulate", flash_color, Color.white, FLASH_TIME)
	modulate_tween.start()

# Method for destroying enemies.
func destroy():
	# Can't be destroyed while still inactive.
	if !active:
		return
	active = false
	activation_timer.stop()
	# Give score for defeating enemy.
	ScoreManager.score += score_value
	shape.set_deferred("disabled", true)
	# Setting up default or alternative explosion.
	var explosion
	if alternative_explosion != null:
		explosion = alternative_explosion.instance()
	else:
		explosion = EXPLOSION_SCENE.instance()
	explosion.position = global_position
	explosion.position -= effects_parent.global_position
	effects_parent.add_child(explosion)
	# Fading enemy to transparent.
	modulate_tween.interpolate_property(self, "modulate", Color.white, Color.transparent, destroy_delay)
	modulate_tween.start()
	# Creating a SceneTreeTimer to destroy the enemy after the destroy delay.
	get_tree().create_timer(destroy_delay).connect("timeout", self, "queue_free")

# Triggered by the activation timer periodically to update activation status.
# Checking activation every frame for all enemies would be much more costly.
func check_activation():
	if global_position.y > -activation_margin and not active:
		active = true
		# Emitting a signal on activation.
		emit_signal("on_activate")
	# Stop checking for enemies that have passed the bottom of the screen.
	elif global_position.y > get_viewport_rect().size.y + activation_margin and active:
		active = false
		activation_timer.stop()

# The base method for shooting just plays the audio.
# Each enemy has a custom extended method for shooting.
func shoot():
	audio.stream = shoot_sound
	audio.volume_db = shoot_volume
	audio.play()
