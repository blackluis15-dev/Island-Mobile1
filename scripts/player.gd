extends CharacterBody3D
## Starter movement controller: keyboard for editor testing and virtual joystick for touch.

@export var move_speed: float = 5.0
@export var acceleration: float = 18.0
@export var gravity: float = 20.0

@onready var camera: Camera3D = $Camera3D

func _physics_process(delta: float) -> void:
	var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var joystick := get_node_or_null("/root/Main/UI/Joystick")
	if joystick != null and joystick.has_method("get_output"):
		var touch_input: Vector2 = joystick.get_output()
		if touch_input.length() > 0.12:
			input_vector = touch_input

	# Camera-relative movement keeps controls intuitive in an isometric view.
	var forward := -camera.global_basis.z
	var right := camera.global_basis.x
	forward.y = 0.0
	right.y = 0.0
	forward = forward.normalized()
	right = right.normalized()
	var direction := (right * input_vector.x + forward * input_vector.y).normalized()

	if direction.length() > 0.01:
		velocity.x = move_toward(velocity.x, direction.x * move_speed, acceleration * delta)
		velocity.z = move_toward(velocity.z, direction.z * move_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, acceleration * delta)
		velocity.z = move_toward(velocity.z, 0.0, acceleration * delta)

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	move_and_slide()
