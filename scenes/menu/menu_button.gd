extends Button

export var hover_offset := Vector2(40.0, 0.0)
export var tween_duration := 0.2
export var focus_sound : AudioStream
export var accept_sound : AudioStream
export var focus_sound_volume := -6.0
export var play_accept_sound := true

onready var icon_node := $Icon
onready var sound := $Sound

var tween := Tween.new()
var initial_position := Vector2()
var accepted := false
var just_visible := false

func _ready():
	add_child(tween)
	initial_position = rect_position
	icon_node.modulate = Color.transparent

func highlight_enter():
	if !tween.is_active():
		initial_position = rect_position
	tween.interpolate_property(
		self, "rect_position", null, initial_position + hover_offset, 
		tween_duration, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.interpolate_property(
		icon_node, "rect_position", null, -hover_offset, 
		tween_duration, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.interpolate_property(
		icon_node, "modulate", null, Color.white,
		tween_duration / 2.0, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()
	if !accepted and !just_visible:
		sound.stream = focus_sound
		sound.volume_db = focus_sound_volume
		sound.play()

func highlight_exit():
	tween.interpolate_property(
		self, "rect_position", null, initial_position, 
		tween_duration, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.interpolate_property(
		icon_node, "rect_position", null, Vector2.ZERO, 
		tween_duration, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.interpolate_property(
		icon_node, "modulate", null, Color.transparent,
		tween_duration / 2.0, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()
	accepted = false

func press():
	if !play_accept_sound:
		return
	accepted = true
	sound.stream = accept_sound
	sound.volume_db = 0.0
	sound.play()

func visibility_changed():
	just_visible = true
	yield(get_tree(), "idle_frame")
	just_visible = false
