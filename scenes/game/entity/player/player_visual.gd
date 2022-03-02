extends Node2D

# Script for the visual elements of the player. The player ship utilizes
# a separate viewport and shaders for some of the ship effects.

# Constants adjusting the amount, speed and timing of effects. Having all the
# adjustments in one place in the script is handy for quickly tuning things.
const GRADIENT_AMOUNT := 0.1
const WARP_AMOUNT := 0.05
const SHADOW_WARP_AMOUNT := 0.02
const EXHAUST_SPEED := 10.0
const EXHAUST_SPEED_MIN := 5.0
const EXHAUST_AMOUNT := 1.0
const EXHAUST_AMOUNT_MIN := 0.5
const GUN_LIGHTUP_TIME := 0.25
const FLASH_MULTIPLY := 2.5
const FLASH_TIME := 0.25

# An exported list of the sprite nodes to apply a flashing effect on when hit.
export (Array, NodePath) var flashing_sprites

# Getting references to the sprite's materials as ShaderMaterials.
onready var sprite_material := $Sprite.material as ShaderMaterial
onready var shadow_material := $Shadow.material as ShaderMaterial
# This array is filled in the ready method with all the exhaust flame sprites.
onready var exhaust_materials := []
# Gun light sprites for muzzle flashes.
onready var gun_light_left := $PlayerViewport/GunLightLeft
onready var gun_light_right := $PlayerViewport/GunLightRight

# The reference vector is used to adjust shader effects according to movement.
var reference_vector := Vector2.ZERO
var tween := Tween.new()

func _ready():
	# Filling exhaust materials array with references.
	exhaust_materials.append($PlayerViewport/ExhaustFlameLeft.material)
	exhaust_materials.append($PlayerViewport/ExhaustFlameMiddle.material)
	exhaust_materials.append($PlayerViewport/ExhaustFlameRight.material)
	# Resetting gun lights to black. Lights use additive materials so this makes
	# them invisible.
	gun_light_left.modulate = Color.black
	gun_light_right.modulate = Color.black
	add_child(tween)

# The process method is used to adjust shader parameters of the ship's sprites.
func _process(_delta):
	# Adjustments are done based on the reference vector supplied by the main
	# player script. The constants are used to manage the effect strengths.
	# The gradient effect makes the ship darker/brighter in a gradient when turning.
	sprite_material.set_shader_param("gradient_effect", -reference_vector.x * GRADIENT_AMOUNT)
	# The warp effect distorts the sprite to create a perspective effect.
	sprite_material.set_shader_param("warp_effect", reference_vector.x * WARP_AMOUNT)
	shadow_material.set_shader_param("warp_effect", reference_vector.x * SHADOW_WARP_AMOUNT)
	# Iterating through the array of exhaust materials to adjust shader parameters.
	for mat in exhaust_materials:
		# These two parameters adjust the speed and amount of exhaust flames to
		# simulate more/less thrust when moving forward/back.
		mat.set_shader_param("speed", -reference_vector.y * EXHAUST_SPEED + EXHAUST_SPEED_MIN)
		mat.set_shader_param("amount", -reference_vector.y * EXHAUST_AMOUNT + EXHAUST_AMOUNT_MIN)

# Triggered when the player ship fires it's gun. Takes the position and color argument.
func gun_fired(gun_position, gun_color):
	# Getting gun position enum from the player gun.
	var gun_pos = get_parent().player_gun.GunPosition
	# Tweens are set up for left and right gun light depending on gun position.
	if gun_position == gun_pos.GUN_LEFT or gun_position == gun_pos.GUN_BOTH:
		tween.interpolate_property(gun_light_left, "modulate", gun_color, Color.black, GUN_LIGHTUP_TIME)
	if gun_position == gun_pos.GUN_RIGHT or gun_position == gun_pos.GUN_BOTH:
		tween.interpolate_property(gun_light_right, "modulate", gun_color, Color.black, GUN_LIGHTUP_TIME)
	# The correct tweens are started.
	tween.start()

# This method is called when player takes a hit. Takes the incoming bullet color.
func damage_flash(color: Color):
	# Multiplying the color to be brighter.
	var flash_color := color * FLASH_MULTIPLY
	# Don't want to multiply the alpha.
	flash_color.a = 1.0
	# Iterating through the array of node paths, getting the node and adding a tween.
	for path in flashing_sprites:
		var sprite = get_node(path)
		tween.interpolate_property(sprite, "modulate", flash_color, Color.white, FLASH_TIME)
	# Starting the tweens added in the for loop.
	tween.start()
