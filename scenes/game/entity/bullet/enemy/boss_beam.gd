extends "res://scenes/game/entity/bullet/base_bullet.gd"

var gradient
var width
var compensation
var target_node

func _ready():
	var mat = $Transform/Sprite.material as ShaderMaterial
	var texture = mat.get_shader_param("rainbow_gradient") as GradientTexture
	gradient = texture.gradient
	width = texture.width
	compensation = get_parent().movement_compensation

func _physics_process(delta):
	translate(Vector2.UP * compensation * delta)

func _process(_delta):
	color = gradient.interpolate(fmod((OS.get_ticks_msec() / 1000.0), 1.0))
	color *= Color(1.5, 1.5, 1.5, 1.0)
	if target_node != null:
		target_node.take_damage(damage, color)

func fire():
	$Animation.play("fire")
	yield($Animation, "animation_finished")
	queue_free()

func hit_target(target: Node):
	if target.has_method("take_damage"):
		target_node = target

func _on_body_exited(target: Node):
	if target.has_method("take_damage"):
		target_node = null
