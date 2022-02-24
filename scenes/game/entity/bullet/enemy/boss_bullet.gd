extends "res://scenes/game/entity/bullet/base_bullet.gd"

# Class for the boss's regular bullet. Extends base bullet.
# This bullet has some extra behaviour to deal with defeating the boss.

var direction := Vector2.RIGHT
# Some extra variables for the destroy method's effects to work.
var destroyed := false
var compensation := 0.0

# If not "destroyed", move normally. Otherwise just follow the level.
func _physics_process(delta):
	if !destroyed:
		translate(direction * speed * delta)
	else:
		translate(Vector2.UP * compensation * delta)

# This methods creates a nicer animation for the bullet's disappearing when
# defeating the boss.
func destroy():
	destroyed = true
	# Getting movement compensation from the bullet parent node.
	compensation = get_parent().movement_compensation
	# Disabling collisions with the shape.
	$Shape.set_deferred("disabled", true)
	# Creating a new tween node and animating the bullet fading out.
	var tween := Tween.new()
	add_child(tween)
	tween.interpolate_property(self, "modulate", null, Color.transparent, 1.0)
	tween.start()
	# After tween is complete, remove the node.
	yield(tween, "tween_all_completed")
	queue_free()
