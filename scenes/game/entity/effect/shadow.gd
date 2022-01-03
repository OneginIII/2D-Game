extends Sprite

export(NodePath) var reference_path

onready var reference_node := get_node(reference_path) as Node2D
onready var position_offset := position
onready var rotation_offset := rotation

func _process(_delta):
	global_rotation = reference_node.global_rotation + rotation_offset
	global_position = reference_node.global_position + position_offset
