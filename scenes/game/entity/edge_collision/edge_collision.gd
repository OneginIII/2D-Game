extends StaticBody2D

onready var top_shape := $TopShape
onready var bottom_shape := $BottomShape
onready var left_shape := $LeftShape
onready var right_shape := $RightShape

func _ready():
	adjust_shapes()
	get_viewport().connect("size_changed", self, "adjust_shapes")

func adjust_shapes():
	var viewport_rect := get_viewport_rect()
	top_shape.position.x = viewport_rect.size.x / 2.0
	top_shape.position.y = -(top_shape.shape.extents.y)
	top_shape.shape.extents.x = viewport_rect.size.x / 2.0
	bottom_shape.position.x = viewport_rect.size.x / 2.0
	bottom_shape.position.y = (bottom_shape.shape.extents.y) + viewport_rect.size.y
	bottom_shape.shape.extents.x = viewport_rect.size.x / 2.0
	left_shape.position.x = -(left_shape.shape.extents.x)
	left_shape.position.y = viewport_rect.size.y / 2.0
	left_shape.shape.extents.y = viewport_rect.size.y / 2.0
	right_shape.position.x = (right_shape.shape.extents.x) + viewport_rect.size.x
	right_shape.position.y = viewport_rect.size.y / 2.0
	right_shape.shape.extents.y = viewport_rect.size.y / 2.0
