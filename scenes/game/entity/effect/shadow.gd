extends Sprite

# This script is used for shadows of the enemies. Shadows need to move and
# rotate with the main sprite while maintaining a constant offset.

# Uses a node path to get the reference node.
export(NodePath) var reference_path

# Getting the reference node based on exported path.
onready var reference_node := get_node(reference_path) as Node2D
# Setting the offsets to the initial value of this shadow sprite.
onready var position_offset := position
onready var rotation_offset := rotation

func _process(_delta):
	# Every frame, read the reference node's global transforms and add the
	# initial offsets to them.
	global_rotation = reference_node.global_rotation + rotation_offset
	global_position = reference_node.global_position + position_offset
