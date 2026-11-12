extends StaticBody3D
## Resource node that can be harvested by the player.

@export var resource_label: String = "Recurso"
@export var max_durability: int = 3
@export var drop_table: Dictionary = {"stone": 2}

var durability: int

func _ready() -> void:
	durability = max_durability
	add_to_group("harvestable")

func apply_hit() -> bool:
	if durability <= 0:
		return false
	durability -= 1
	if durability <= 0:
		return true
	return false

func get_drops() -> Dictionary:
	return drop_table.duplicate(true)

func get_status_text() -> String:
	return "%s (%d/%d)" % [resource_label, durability, max_durability]
