extends Node3D
## Builds a lightweight placeholder island from primitive meshes.
## Art assets and a proper terrain system will replace these placeholders later.

const PLAYER_SCENE := preload("res://scenes/player.tscn")

var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	_build_environment()
	_build_island()
	_spawn_player()
	_build_hud()

func _build_environment() -> void:
	var world_environment := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.72, 0.82, 0.88)
	environment.ambient_light_energy = 0.8
	world_environment.environment = environment
	add_child(world_environment)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55.0, -30.0, 0.0)
	sun.light_energy = 1.15
	add_child(sun)

	var water := MeshInstance3D.new()
	var water_mesh := PlaneMesh.new()
	water_mesh.size = Vector2(90.0, 90.0)
	water.mesh = water_mesh
	water.position.y = -0.45
	var water_material := StandardMaterial3D.new()
	water_material.albedo_color = Color(0.12, 0.48, 0.62)
	water_material.roughness = 0.28
	water.material_override = water_material
	add_child(water)

func _build_island() -> void:
	var ground := StaticBody3D.new()
	ground.name = "IslandGround"
	var ground_mesh := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(34.0, 34.0)
	ground_mesh.mesh = plane
	var grass := StandardMaterial3D.new()
	grass.albedo_color = Color(0.36, 0.55, 0.28)
	grass.roughness = 1.0
	ground_mesh.material_override = grass
	ground.add_child(ground_mesh)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(34.0, 0.5, 34.0)
	collision.shape = shape
	collision.position.y = -0.25
	ground.add_child(collision)
	add_child(ground)

	# Sandy shoreline ring, represented by a slightly larger flat disk.
	var shore := MeshInstance3D.new()
	var shore_mesh := CylinderMesh.new()
	shore_mesh.top_radius = 19.0
	shore_mesh.bottom_radius = 19.0
	shore_mesh.height = 0.12
	shore.mesh = shore_mesh
	shore.position.y = -0.12
	var sand := StandardMaterial3D.new()
	sand.albedo_color = Color(0.78, 0.69, 0.48)
	shore.material_override = sand
	add_child(shore)

	for i in range(24):
		var x := rng.randf_range(-14.0, 14.0)
		var z := rng.randf_range(-14.0, 14.0)
		if Vector2(x, z).length() < 4.5:
			continue
		_add_tree(Vector3(x, 0.0, z))

	for i in range(12):
		var x := rng.randf_range(-13.0, 13.0)
		var z := rng.randf_range(-13.0, 13.0)
		_add_rock(Vector3(x, 0.0, z))

func _add_tree(at: Vector3) -> void:
	# StaticBody3D makes the trunk a solid obstacle for the player.
	var tree := StaticBody3D.new()
	tree.name = "Tree"
	tree.position = at

	var trunk := MeshInstance3D.new()
	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius = 0.16
	trunk_mesh.bottom_radius = 0.24
	trunk_mesh.height = 1.8
	trunk.mesh = trunk_mesh
	trunk.position.y = 0.9
	var trunk_mat := StandardMaterial3D.new()
	trunk_mat.albedo_color = Color(0.32, 0.20, 0.11)
	trunk.material_override = trunk_mat
	tree.add_child(trunk)

	var trunk_collision := CollisionShape3D.new()
	var trunk_shape := CapsuleShape3D.new()
	trunk_shape.radius = 0.32
	trunk_shape.height = 2.0
	trunk_collision.shape = trunk_shape
	trunk_collision.position.y = 1.0
	tree.add_child(trunk_collision)

	var leaves := MeshInstance3D.new()
	var leaf_mesh := SphereMesh.new()
	leaf_mesh.radius = rng.randf_range(0.75, 1.05)
	leaf_mesh.height = leaf_mesh.radius * 1.8
	leaves.mesh = leaf_mesh
	leaves.position.y = 2.05
	var leaf_mat := StandardMaterial3D.new()
	leaf_mat.albedo_color = Color(0.18, rng.randf_range(0.38, 0.52), 0.20)
	leaves.material_override = leaf_mat
	tree.add_child(leaves)
	add_child(tree)

func _add_rock(at: Vector3) -> void:
	# The mesh and its collision share the same parent transform.
	var rock := StaticBody3D.new()
	rock.name = "Rock"
	rock.position = at + Vector3(0.0, 0.0, 0.0)

	var mesh_instance := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = rng.randf_range(0.35, 0.65)
	mesh.height = mesh.radius * 1.35
	mesh_instance.mesh = mesh
	mesh_instance.position.y = mesh.radius * 0.45
	mesh_instance.scale = Vector3(1.25, 0.8, 1.0)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.38, 0.40, 0.38)
	mesh_instance.material_override = material
	rock.add_child(mesh_instance)

	var rock_collision := CollisionShape3D.new()
	var rock_shape := SphereShape3D.new()
	rock_shape.radius = mesh.radius
	rock_collision.shape = rock_shape
	rock_collision.position.y = mesh.radius * 0.45
	rock_collision.scale = Vector3(1.25, 0.8, 1.0)
	rock.add_child(rock_collision)
	add_child(rock)

func _spawn_player() -> void:
	var player := PLAYER_SCENE.instantiate()
	player.name = "Player"
	player.position = Vector3(0.0, 1.0, 0.0)
	add_child(player)

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	layer.name = "UI"
	add_child(layer)

	var title := Label.new()
	title.text = "ISLAND MOBILE  |  PROTOTIPO"
	title.position = Vector2(18.0, 14.0)
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	layer.add_child(title)

	var hint := Label.new()
	hint.text = "Explora la isla  •  WASD / flechas o joystick táctil"
	hint.position = Vector2(18.0, 44.0)
	hint.add_theme_font_size_override("font_size", 15)
	hint.add_theme_color_override("font_color", Color(0.95, 0.95, 0.88))
	layer.add_child(hint)

	var joystick := Control.new()
	joystick.name = "Joystick"
	joystick.set_script(load("res://scripts/virtual_joystick.gd"))
	joystick.anchor_left = 0.0
	joystick.anchor_top = 1.0
	joystick.anchor_right = 0.0
	joystick.anchor_bottom = 1.0
	joystick.offset_left = 24.0
	joystick.offset_top = -204.0
	joystick.offset_right = 204.0
	joystick.offset_bottom = -24.0
	joystick.mouse_filter = Control.MOUSE_FILTER_STOP
	layer.add_child(joystick)
