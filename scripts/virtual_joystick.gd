extends Control
## Minimal floating-style joystick for Android touch input.

@export var dead_zone: float = 0.12
@export var knob_limit: float = 54.0

var _finger_index: int = -1
var _output := Vector2.ZERO
var _knob_position := Vector2.ZERO

func _ready() -> void:
	_knob_position = size * 0.5
	queue_redraw()

func get_output() -> Vector2:
	return _output

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and _finger_index == -1:
			_finger_index = event.index
			_update_stick(event.position)
		elif not event.pressed and event.index == _finger_index:
			_release_stick()
	elif event is InputEventScreenDrag and event.index == _finger_index:
		_update_stick(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_finger_index = 0
			_update_stick(event.position)
		else:
			_release_stick()
	elif event is InputEventMouseMotion and _finger_index == 0 and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_update_stick(event.position)

func _update_stick(pointer: Vector2) -> void:
	var center := size * 0.5
	var offset := pointer - center
	if offset.length() > knob_limit:
		offset = offset.normalized() * knob_limit
	_knob_position = center + offset
	# Input.get_vector convention: negative Y means forward/up.
	_output = offset / knob_limit
	if _output.length() < dead_zone:
		_output = Vector2.ZERO
	queue_redraw()

func _release_stick() -> void:
	_finger_index = -1
	_output = Vector2.ZERO
	_knob_position = size * 0.5
	queue_redraw()

func _draw() -> void:
	var center := size * 0.5
	draw_circle(center, 78.0, Color(0.04, 0.08, 0.10, 0.34))
	draw_arc(center, 78.0, 0.0, TAU, 64, Color(0.85, 0.91, 0.84, 0.65), 3.0)
	draw_circle(_knob_position, 27.0, Color(0.82, 0.88, 0.76, 0.72))
	draw_arc(_knob_position, 27.0, 0.0, TAU, 48, Color(1.0, 1.0, 1.0, 0.9), 2.0)
