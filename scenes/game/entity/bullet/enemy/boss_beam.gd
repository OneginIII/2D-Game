extends "res://scenes/game/entity/bullet/base_bullet.gd"

# This is the "bullet" for the boss beam weapon. Extends base bullet.

# Setting up variables for a gradient effect used for the beam's color value.
var gradient
var width
var compensation
# The beam works differently than other bullets and needs a target node.
var target_node

func _ready():
	# Getting the gradient texture from the shader used by the sprite.
	var mat = $Transform/Sprite.material as ShaderMaterial
	var texture = mat.get_shader_param("rainbow_gradient") as GradientTexture
	gradient = texture.gradient
	width = texture.width
	# Reading movement compensation from bullet parent node.
	compensation = get_parent().movement_compensation

# The beam should stay still on screen like the boss. Using the compensation
# value to do that in the physics process method.
func _physics_process(delta):
	translate(Vector2.UP * compensation * delta)

func _process(_delta):
	# Bullets have a color value that determines what color the flash effect
	# of the target they hit is. Since the beam changes color in a gradient,
	# it's color value is animated here in the process method.
	# Reading the gradient using the engine running time with a float modulo.
	color = gradient.interpolate(fmod((OS.get_ticks_msec() / 1000.0), 1.0))
	color *= Color(1.5, 1.5, 1.5, 1.0)
	color.s = 0.5
	# If the beam is hitting the player, damage them constantly.
	if target_node != null:
		target_node.take_damage(damage, color)

# Called by the boss when firing the beam. Animates the beam and then deletes it.
func fire():
	$Animation.play("fire")
	# Pauses the methods execution until receiving the animation's
	# finishing signal. "yield" is GDScripts way of doing coroutines.
	yield($Animation, "animation_finished")
	queue_free()

# This overrides the base bullet class hit method, which would for example
# delete the beam once it hits anything.
func hit_target(target: Node):
	if target.has_method("take_damage"):
		# Setting the target node damaged every frame by the beam.
		target_node = target

func _on_body_exited(target: Node):
	if target.has_method("take_damage"):
		# When target exits the area, stop damaging it by setting to null.
		target_node = null
