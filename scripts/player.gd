extends CharacterBody3D
## Movement, resource harvesting, inventory and basic tool durability.

@export var move_speed: float = 5.0
@export var acceleration: float = 18.0
@export var gravity: float = 20.0
@export var harvest_range: float = 3.4

@onready var camera: Camera3D = $Camera3D

const TOOL_ORDER: Array[String] = ["hand", "axe", "pickaxe"]
const TOOL_NAMES := {"hand": "Manos", "axe": "Hacha", "pickaxe": "Pico"}

var inventory: Dictionary = {}
var current_tool_index: int = 0
var tool_durability: Dictionary = {"axe": 60, "pickaxe": 60}

func _physics_process(delta: float) -> void:
	var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var joystick := get_node_or_null("/root/Main/UI/Joystick")
	if joystick != null and joystick.has_method("get_output"):
		var touch_input: Vector2 = joystick.get_output()
		if touch_input.length() > 0.12:
			input_vector = touch_input

	var forward := -camera.global_basis.z
	var right := camera.global_basis.x
	forward.y = 0.0
	right.y = 0.0
	forward = forward.normalized()
	right = right.normalized()
	var direction := (right * input_vector.x - forward * input_vector.y).normalized()

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

	if Input.is_action_just_pressed("interact"):
		interact()
	if Input.is_action_just_pressed("cycle_tool"):
		cycle_tool()
	_update_inventory_display()
	_update_tool_display()

func cycle_tool() -> void:
	current_tool_index = (current_tool_index + 1) % TOOL_ORDER.size()
	_update_tool_display()

func _get_current_tool() -> String:
	return TOOL_ORDER[current_tool_index]

func _get_hit_power(resource: Node) -> int:
	var tool := _get_current_tool()
	var resource_name := str(resource.get("resource_label")).to_lower()
	if tool == "axe" and resource_name.contains("árbol"):
		return 2
	if tool == "pickaxe" and resource_name.contains("roca"):
		return 2
	return 1

func interact() -> void:
	var target: Node3D = null
	var closest_distance := harvest_range
	for node in get_tree().get_nodes_in_group("harvestable"):
		if not is_instance_valid(node):
			continue
		var resource := node as Node3D
		var distance := global_position.distance_to(resource.global_position)
		if distance <= closest_distance:
			closest_distance = distance
			target = resource

	if target == null:
		return

	var tool := _get_current_tool()
	var power := _get_hit_power(target)
	var destroyed: bool = target.call("apply_hit", power)

	if tool != "hand":
		tool_durability[tool] = int(tool_durability.get(tool, 0)) - 1
		if int(tool_durability[tool]) <= 0:
			tool_durability[tool] = 0
			current_tool_index = 0

	if destroyed:
		var drops: Dictionary = target.call("get_drops")
		for item in drops.keys():
			inventory[item] = int(inventory.get(item, 0)) + int(drops[item])
		target.queue_free()

	_update_inventory_display()
	_update_tool_display()

func _update_inventory_display() -> void:
	var label := get_node_or_null("/root/Main/UI/InventoryLabel")
	if label == null:
		return
	if inventory.is_empty():
		label.text = "Mochila: vacía"
		return

	var item_names := {
		"wood": "Madera",
		"leaves": "Hojas",
		"sapling": "Brote",
		"stone": "Piedra"
	}
	var entries: Array[String] = []
	for item in inventory.keys():
		var display_name: String = item_names.get(item, str(item))
		entries.append("%s: %d" % [display_name, int(inventory[item])])
	label.text = "Mochila: " + "  |  ".join(entries)

func _update_tool_display() -> void:
	var label := get_node_or_null("/root/Main/UI/ToolLabel")
	if label == null:
		return
	var tool := _get_current_tool()
	if tool == "hand":
		label.text = "Herramienta: Manos"
	else:
		label.text = "Herramienta: %s (%d)" % [TOOL_NAMES[tool], int(tool_durability[tool])]
