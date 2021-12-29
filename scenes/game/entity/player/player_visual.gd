extends Node2D

export (Array, NodePath) var flashing_sprites

onready var sprite_material := $Sprite.material as ShaderMaterial
onready var shadow_material := $Shadow.material as ShaderMaterial
onready var exhaust_materials := []
onready var gun_light_left := $PlayerViewport/GunLightLeft
onready var gun_light_right := $PlayerViewport/GunLightRight

var reference_vector := Vector2.ZERO
var light_tween := Tween.new()
var flash_tween := Tween.new()

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

func _ready():
	exhaust_materials.append($PlayerViewport/ExhaustFlameLeft.material)
	exhaust_materials.append($PlayerViewport/ExhaustFlameMiddle.material)
	exhaust_materials.append($PlayerViewport/ExhaustFlameRight.material)
	gun_light_left.modulate = Color.black
	gun_light_right.modulate = Color.black
	add_child(light_tween)
	add_child(flash_tween)

func _process(_delta):
	sprite_material.set_shader_param("gradient_effect", -reference_vector.x * GRADIENT_AMOUNT)
	sprite_material.set_shader_param("warp_effect", reference_vector.x * WARP_AMOUNT)
	shadow_material.set_shader_param("warp_effect", reference_vector.x * SHADOW_WARP_AMOUNT)
	
	for mat in exhaust_materials:
		mat.set_shader_param("speed", -reference_vector.y * EXHAUST_SPEED + EXHAUST_SPEED_MIN)
		mat.set_shader_param("amount", -reference_vector.y * EXHAUST_AMOUNT + EXHAUST_AMOUNT_MIN)

func gun_fired(gun_position, gun_color):
	light_tween.interpolate_property(gun_light_left, "modulate", gun_color, Color.black, GUN_LIGHTUP_TIME)
	light_tween.interpolate_property(gun_light_right, "modulate", gun_color, Color.black, GUN_LIGHTUP_TIME)
	if gun_position == get_parent().player_gun.GunPosition.GUN_LEFT:
		light_tween.remove(gun_light_right, "modulate")
	elif gun_position == get_parent().player_gun.GunPosition.GUN_RIGHT:
		light_tween.remove(gun_light_left, "modulate")
	light_tween.start()

func damage_flash(color: Color):
	var flash_color := color * FLASH_MULTIPLY
	flash_color.a = 1.0
	for path in flashing_sprites:
		var sprite = get_node(path)
		flash_tween.interpolate_property(sprite, "modulate", flash_color, Color.white, FLASH_TIME)
	flash_tween.start()
