extends StaticBody3D
## Small crop plot: plant, water, grow in stages, and harvest.

@export var growth_seconds: float = 12.0
var stage: int = 0
var watered: bool = false
var growth_timer: float = 0.0
var crop_visual: Node3D
var status_label: Label

func _ready() -> void:
	add_to_group("farm_plot")
	_build_plot()
	_refresh_visual()

func _process(delta: float) -> void:
	if stage <= 0 or stage >= 3 or not watered:
		return
	growth_timer += delta
	if growth_timer >= growth_seconds:
		growth_timer = 0.0
		watered = false
		stage += 1
		_refresh_visual()

func interact(player: Node) -> void:
	var inventory: Dictionary = player.inventory
	if stage == 0:
		if int(inventory.get("seeds", 0)) <= 0:
			_set_status("Necesitas semillas")
			return
		inventory["seeds"] = int(inventory["seeds"]) - 1
		stage = 1
		watered = false
		_set_status("Sembrado: falta regar")
	elif stage < 3 and not watered:
		if int(inventory.get("water", 0)) <= 0:
			_set_status("Necesitas agua")
			return
		inventory["water"] = int(inventory["water"]) - 1
		watered = true
		growth_timer = 0.0
		_set_status("Regado: creciendo")
	elif stage < 3 and watered:
		_set_status("La planta está creciendo")
	elif stage >= 3:
		inventory["berries"] = int(inventory.get("berries", 0)) + 3
		inventory["seeds"] = int(inventory.get("seeds", 0)) + 1
		stage = 0
		watered = false
		growth_timer = 0.0
		_set_status("Cosecha: +3 frutos y +1 semilla")
	_refresh_visual()
	if player.has_method("_update_inventory_display"):
		player.call("_update_inventory_display")

func _build_plot() -> void:
	var soil := MeshInstance3D.new()
	var soil_mesh := BoxMesh.new()
	soil_mesh.size = Vector3(1.8, 0.18, 1.8)
	soil.mesh = soil_mesh
	soil.position.y = 0.08
	var soil_material := StandardMaterial3D.new()
	soil_material.albedo_color = Color(0.30, 0.19, 0.11)
	soil.material_override = soil_material
	add_child(soil)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(1.8, 0.25, 1.8)
	collision.shape = shape
	collision.position.y = 0.08
	add_child(collision)

	crop_visual = Node3D.new()
	crop_visual.name = "CropVisual"
	add_child(crop_visual)

func _refresh_visual() -> void:
	if crop_visual == null:
		return
	for child in crop_visual.get_children():
		child.queue_free()
	if stage <= 0:
		return
	var stem := MeshInstance3D.new()
	var stem_mesh := CylinderMesh.new()
	stem_mesh.top_radius = 0.035
	stem_mesh.bottom_radius = 0.06
	stem_mesh.height = 0.25 + float(stage) * 0.22
	stem.mesh = stem_mesh
	stem.position.y = 0.20 + stem_mesh.height * 0.5
	var stem_material := StandardMaterial3D.new()
	stem_material.albedo_color = Color(0.24, 0.55, 0.19) if stage < 3 else Color(0.36, 0.72, 0.24)
	stem.material_override = stem_material
	crop_visual.add_child(stem)
	if stage >= 2:
		for i in range(3):
			var leaf := MeshInstance3D.new()
			var leaf_mesh := SphereMesh.new()
			leaf_mesh.radius = 0.17 if stage == 2 else 0.23
			leaf_mesh.height = 0.10
			leaf.mesh = leaf_mesh
			leaf.position = Vector3(cos(float(i) * TAU / 3.0) * 0.22, 0.28 + float(stage) * 0.18, sin(float(i) * TAU / 3.0) * 0.22)
			var leaf_material := StandardMaterial3D.new()
			leaf_material.albedo_color = Color(0.30, 0.62, 0.18) if stage < 3 else Color(0.82, 0.36, 0.12)
			leaf.material_override = leaf_material
			crop_visual.add_child(leaf)

func _set_status(message: String) -> void:
	var label := get_node_or_null("/root/Main/UI/HintLabel")
	if label != null:
		label.text = message
