extends SceneTree
## Offline scene builder. Run after importing scripts. Generated scenes stay editable.
const BASE := "res://features/vr/"
func _init() -> void:
	build.call_deferred()

func add(parent: Node, node: Node, node_name: String, scene_root: Node, unique: bool = false) -> Node:
	node.name = node_name
	parent.add_child(node)
	node.owner = scene_root
	node.unique_name_in_owner = unique
	return node

func mat(color: Color) -> StandardMaterial3D:
	var result := StandardMaterial3D.new()
	result.albedo_color = color
	result.roughness = 0.8
	result.resource_local_to_scene = true
	return result

func mesh_box(parent: Node3D, size: Vector3, color: Color, scene_root: Node, node_name: String = "Visual") -> MeshInstance3D:
	var visual := add(parent, MeshInstance3D.new(), node_name, scene_root) as MeshInstance3D
	var mesh := BoxMesh.new()
	mesh.size = size
	visual.mesh = mesh
	visual.material_override = mat(color)
	return visual

func collision_box(parent: Node3D, size: Vector3, scene_root: Node) -> CollisionShape3D:
	var collision := add(parent, CollisionShape3D.new(), "CollisionShape", scene_root) as CollisionShape3D
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	return collision

func label(parent: Node3D, text: String, position: Vector3, scene_root: Node, node_name: String = "Sign", font_size: int = 40) -> Label3D:
	var node := add(parent, Label3D.new(), node_name, scene_root) as Label3D
	node.text = text
	node.position = position
	node.font_size = font_size
	node.pixel_size = 0.0025
	node.outline_size = 6
	node.modulate = Color(0.85, 0.94, 1.0)
	return node

func save_scene(scene_root: Node, path: String) -> void:
	var packed := PackedScene.new()
	assert(packed.pack(scene_root) == OK)
	assert(ResourceSaver.save(packed, path) == OK)
	scene_root.free()

func build() -> void:
	build_hand()
	build_grabbable()
	build_flashlight()
	build_button()
	build_lever()
	build_socket()
	build_door()
	build_teleport()
	build_player()
	build_lab()
	print("VR template scenes generated")
	quit()

func build_hand() -> void:
	var r := Node3D.new()
	r.name = "VRHand"
	r.set_script(load(BASE + "hands/vr_hand.gd"))
	var grip := add(r, XRController3D.new(), "Grip", r, true) as XRController3D
	grip.tracker = &"left_hand"
	grip.pose = &"grip"
	var aim := add(r, XRController3D.new(), "Aim", r, true) as XRController3D
	aim.tracker = grip.tracker
	aim.pose = &"aim"
	var visual := add(grip, MeshInstance3D.new(), "HandVisual", r) as MeshInstance3D
	var sphere := SphereMesh.new()
	sphere.radius = 0.045
	sphere.height = 0.09
	visual.mesh = sphere
	visual.unique_name_in_owner = true
	visual.material_override = mat(Color(0.2, 0.7, 0.85))
	add(grip, Marker3D.new(), "HoldPoint", r, true)
	var area := add(grip, Area3D.new(), "GrabArea", r, true) as Area3D
	area.collision_layer = 0
	area.collision_mask = 10
	var sphere_shape := SphereShape3D.new()
	sphere_shape.radius = 0.18
	var shape := add(area, CollisionShape3D.new(), "GrabShape", r) as CollisionShape3D
	shape.shape = sphere_shape
	var ray := add(aim, RayCast3D.new(), "InteractionRay", r, true) as RayCast3D
	ray.collision_mask = 11
	ray.target_position = Vector3(0.0, 0.0, -4.0)
	var beam := mesh_box(aim, Vector3(0.004, 0.004, 1.0), Color(0.4, 0.6, 0.8), r, "Beam")
	beam.unique_name_in_owner = true
	(beam.material_override as StandardMaterial3D).shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var hint := label(aim, "", Vector3(0.0, 0.08, -0.5), r, "Hint", 24)
	hint.unique_name_in_owner = true
	hint.pixel_size = 0.001
	save_scene(r, BASE + "hands/vr_hand.tscn")

func build_grabbable() -> void:
	var r := RigidBody3D.new()
	r.name = "VRGrabbable"
	r.set_script(load(BASE + "interaction/vr_grabbable.gd"))
	r.collision_layer = 2
	r.collision_mask = 11
	r.mass = 0.3
	r.continuous_cd = true
	mesh_box(r, Vector3.ONE * 0.2, Color(0.95, 0.55, 0.15), r).unique_name_in_owner = true
	collision_box(r, Vector3.ONE * 0.2, r)
	save_scene(r, BASE + "interaction/vr_grabbable.tscn")

func build_flashlight() -> void:
	var r := RigidBody3D.new()
	r.name = "VRFlashlight"
	r.set_script(load(BASE + "interaction/vr_flashlight.gd"))
	r.set("display_name", "Linterna")
	r.set("item_id", &"flashlight")
	r.set("color", Color(0.5, 0.6, 0.8))
	r.collision_layer = 2
	r.collision_mask = 11
	r.mass = 0.25
	r.continuous_cd = true
	mesh_box(r, Vector3(0.08, 0.08, 0.25), Color(0.5, 0.6, 0.8), r).unique_name_in_owner = true
	collision_box(r, Vector3(0.08, 0.08, 0.25), r)
	var light := add(r, SpotLight3D.new(), "Light", r, true) as SpotLight3D
	light.position.z = -0.14
	light.spot_range = 8.0
	light.spot_angle = 25.0
	light.light_energy = 3.0
	light.visible = false
	save_scene(r, BASE + "interaction/vr_flashlight.tscn")

func build_button() -> void:
	var r := StaticBody3D.new()
	r.name = "VRButton"
	r.set_script(load(BASE + "interaction/vr_button.gd"))
	r.collision_layer = 8
	r.collision_mask = 0
	var visual := mesh_box(r, Vector3(0.55, 0.22, 0.08), Color(0.2, 0.4, 0.7), r, "Face")
	visual.unique_name_in_owner = true
	collision_box(r, Vector3(0.55, 0.22, 0.08), r)
	var caption := label(r, "Botón", Vector3(0.0, 0.0, 0.045), r, "Caption", 32)
	caption.unique_name_in_owner = true
	caption.pixel_size = 0.0014
	save_scene(r, BASE + "interaction/vr_button.tscn")

func build_lever() -> void:
	var r := AnimatableBody3D.new()
	r.name = "VRLever"
	r.set_script(load(BASE + "interaction/vr_lever.gd"))
	r.collision_layer = 8
	r.collision_mask = 0
	r.sync_to_physics = false
	mesh_box(r, Vector3(0.08, 0.5, 0.08), Color(0.8, 0.3, 0.5), r).position.y = 0.25
	collision_box(r, Vector3(0.16, 0.5, 0.16), r).position.y = 0.25
	save_scene(r, BASE + "interaction/vr_lever.tscn")

func build_socket() -> void:
	var r := Area3D.new()
	r.name = "VRSocket"
	r.set_script(load(BASE + "interaction/vr_socket.gd"))
	r.collision_layer = 16
	r.collision_mask = 2
	collision_box(r, Vector3.ONE * 0.38, r)
	add(r, Marker3D.new(), "SnapPoint", r, true)
	var visual := add(r, MeshInstance3D.new(), "SocketRing", r) as MeshInstance3D
	var torus := TorusMesh.new()
	torus.inner_radius = 0.13
	torus.outer_radius = 0.19
	visual.mesh = torus
	visual.material_override = mat(Color(0.1, 0.9, 0.7))
	save_scene(r, BASE + "interaction/vr_socket.tscn")

func build_door() -> void:
	var r := AnimatableBody3D.new()
	r.name = "VRDoor"
	r.set_script(load(BASE + "interaction/vr_door.gd"))
	r.collision_layer = 1
	r.collision_mask = 6
	r.sync_to_physics = false
	mesh_box(r, Vector3(1.4, 2.2, 0.18), Color(0.18, 0.5, 0.6), r)
	collision_box(r, Vector3(1.4, 2.2, 0.18), r)
	save_scene(r, BASE + "interaction/vr_door.tscn")

func build_teleport() -> void:
	var r := Node3D.new()
	r.name = "VRTeleport"
	r.set_script(load(BASE + "locomotion/vr_teleport.gd"))
	add(r, MeshInstance3D.new(), "Arc", r, true)
	var marker := add(r, MeshInstance3D.new(), "DestinationMarker", r, true) as MeshInstance3D
	var torus := TorusMesh.new()
	torus.inner_radius = 0.2
	torus.outer_radius = 0.24
	marker.mesh = torus
	marker.material_override = mat(Color(0.1, 1.0, 0.65))
	marker.visible = false
	save_scene(r, BASE + "locomotion/vr_teleport.tscn")

func instance_scene(parent: Node, path: String, node_name: String, scene_root: Node, unique: bool = true) -> Node3D:
	var instance := (load(path) as PackedScene).instantiate() as Node3D
	add(parent, instance, node_name, scene_root, unique)
	return instance

func build_player() -> void:
	var r := CharacterBody3D.new()
	r.name = "VRPlayer"
	r.set_script(load(BASE + "player/vr_player.gd"))
	r.collision_layer = 4
	r.collision_mask = 9
	r.floor_snap_length = 0.25
	r.floor_max_angle = deg_to_rad(40.0)
	var defaults := VRSettings.new()
	assert(ResourceSaver.save(defaults, BASE + "player/default_vr_settings.tres") == OK)
	r.set("defaults", load(BASE + "player/default_vr_settings.tres"))
	var shape := add(r, CollisionShape3D.new(), "BodyShape", r, true) as CollisionShape3D
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.22
	capsule.height = 1.7
	capsule.resource_local_to_scene = true
	shape.shape = capsule
	shape.position.y = 0.87
	var origin := add(r, XROrigin3D.new(), "XROrigin", r, true) as XROrigin3D
	var camera := add(origin, XRCamera3D.new(), "Head", r, true) as XRCamera3D
	camera.position.y = 1.7
	camera.near = 0.05
	camera.current = true
	instance_scene(origin, BASE + "hands/vr_hand.tscn", "LeftHand", r)
	var right := instance_scene(origin, BASE + "hands/vr_hand.tscn", "RightHand", r)
	right.set("tracker_name", &"right_hand")
	right.set("hand_color", Color(0.8, 0.35, 0.6))
	for definition: Array in [["InputAdapter", "player/vr_input.gd"], ["Locomotion", "player/vr_locomotion.gd"], ["XRSession", "session/xr_session.gd"], ["Boundary", "session/vr_boundary.gd"], ["HeadCollision", "player/vr_head_collision.gd"]]:
		var component := add(r, Node.new(), definition[0], r, true)
		component.set_script(load(BASE + definition[1]))
	instance_scene(r, BASE + "locomotion/vr_teleport.tscn", "Teleport", r)
	var comfort := add(camera, MeshInstance3D.new(), "ComfortMask", r, true) as MeshInstance3D
	var sphere := SphereMesh.new()
	sphere.radius = 0.12
	sphere.height = 0.24
	comfort.mesh = sphere
	comfort.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var shader_material := ShaderMaterial.new()
	shader_material.shader = load(BASE + "player/comfort.gdshader")
	shader_material.resource_local_to_scene = true
	comfort.material_override = shader_material
	var warning := label(camera, "Límite del área física: vuelve al centro", Vector3(0.0, -0.1, -1.2), r, "BoundaryWarning", 28)
	warning.visible = false
	warning.modulate = Color(1.0, 0.6, 0.2)
	r.get_node("Boundary").set("warning_label", warning)
	save_scene(r, BASE + "player/vr_player.tscn")

func world_box(parent: Node3D, node_name: String, position: Vector3, size: Vector3, color: Color, root: Node, walkable: bool = false) -> StaticBody3D:
	var body := add(parent, StaticBody3D.new(), node_name, root) as StaticBody3D
	body.position = position
	body.collision_layer = 1
	body.collision_mask = 6
	mesh_box(body, size, color, root)
	collision_box(body, size, root)
	if walkable:
		body.add_to_group(&"vr_teleportable", true)
	return body

func build_lab() -> void:
	var r := Node3D.new()
	r.name = "InteractionLab"
	r.set_script(load("res://examples/interaction_lab/interaction_lab.gd"))
	var environment := add(r, WorldEnvironment.new(), "WorldEnvironment", r) as WorldEnvironment
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.025, 0.055, 0.085)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.7, 0.85, 1.0)
	env.ambient_light_energy = 0.6
	environment.environment = env
	var sun := add(r, DirectionalLight3D.new(), "KeyLight", r) as DirectionalLight3D
	sun.rotation_degrees = Vector3(-60.0, -25.0, 0.0)
	sun.light_energy = 1.3
	var world := add(r, Node3D.new(), "World", r) as Node3D
	world_box(world, "Floor", Vector3(0.0, -0.1, 0.0), Vector3(16.0, 0.2, 16.0), Color(0.12, 0.18, 0.23), r, true)
	world_box(world, "BackWall", Vector3(0.0, 1.5, -8.0), Vector3(16.0, 3.0, 0.2), Color(0.16, 0.23, 0.3), r)
	world_box(world, "LeftWall", Vector3(-8.0, 1.5, 0.0), Vector3(0.2, 3.0, 16.0), Color(0.16, 0.23, 0.3), r)
	world_box(world, "RightWall", Vector3(8.0, 1.5, 0.0), Vector3(0.2, 3.0, 16.0), Color(0.16, 0.23, 0.3), r)
	world_box(world, "FrontWall", Vector3(0.0, 1.5, 8.0), Vector3(16.0, 3.0, 0.2), Color(0.16, 0.23, 0.3), r)
	var player := instance_scene(r, BASE + "player/vr_player.tscn", "VRPlayer", r)
	player.position = Vector3(0.0, 0.05, 4.5)
	label(r, "VR · INTERACTION LAB", Vector3(0.0, 3.1, 0.0), r, "Title", 80)
	label(r, "Godot 4.7 / Quest 3\nExplora las estaciones. Grip toma, gatillo usa, A teletransporta.", Vector3(0.0, 2.6, 0.0), r, "Subtitle", 30)
	var stations := add(r, Node3D.new(), "Stations", r) as Node3D
	world_box(stations, "GrabTable", Vector3(-3.0, 0.45, 0.0), Vector3(2.0, 0.9, 1.0), Color(0.2, 0.28, 0.35), r)
	label(stations, "01 · TOMAR Y LANZAR\nCerca: mano / Lejos: rayo + Grip", Vector3(-3.0, 1.9, 0.0), r, "GrabSign", 32)
	for index: int in range(3):
		var item := instance_scene(stations, BASE + "interaction/vr_grabbable.tscn", "Cube" + str(index + 1), r, false)
		item.position = Vector3(-3.6 + index * 0.6, 1.05, 0.0)
		item.set("display_name", "Cubo " + str(index + 1))
	var flashlight := instance_scene(stations, BASE + "interaction/vr_flashlight.tscn", "Flashlight", r)
	flashlight.position = Vector3(-3.5, 1.0, 0.3)
	var key := instance_scene(stations, BASE + "interaction/vr_grabbable.tscn", "Key", r)
	key.position = Vector3(-2.5, 1.08, 0.3)
	key.set("item_id", &"key")
	key.set("display_name", "Llave verde")
	key.set("color", Color(0.1, 0.95, 0.6))
	world_box(stations, "ControlPanel", Vector3(0.0, 1.3, 0.0), Vector3(1.6, 1.25, 0.1), Color(0.1, 0.2, 0.3), r)
	label(stations, "02 · CONTROLES", Vector3(0.0, 2.1, 0.0), r, "ControlSign", 36)
	var names := ["MovementButton", "SeatedButton", "DoorButton", "ResetButton"]
	var captions := ["Movimiento libre", "Modo sentado", "Abrir / cerrar puerta", "Reiniciar laboratorio"]
	for index: int in range(4):
		var button := instance_scene(stations, BASE + "interaction/vr_button.tscn", names[index], r)
		button.position = Vector3(-0.4 if index % 2 == 0 else 0.4, 1.55 if index < 2 else 1.05, 0.15)
		button.set("caption", captions[index])
		button.set("toggle", index < 2)
	world_box(stations, "LeverTable", Vector3(3.0, 0.45, 0.0), Vector3(1.5, 0.9, 1.0), Color(0.2, 0.28, 0.35), r)
	var lever := instance_scene(stations, BASE + "interaction/vr_lever.tscn", "Lever", r)
	lever.position = Vector3(3.0, 0.95, 0.0)
	label(stations, "03 · PALANCA\nGrip y mueve la mano", Vector3(3.0, 1.9, 0.0), r, "LeverSign", 32)
	var indicator := mesh_box(stations, Vector3(0.12, 0.4, 0.12), Color(0.9, 0.3, 0.5), r, "LeverIndicator")
	indicator.unique_name_in_owner = true
	indicator.position = Vector3(3.6, 1.3, 0.0)
	world_box(stations, "SocketTable", Vector3(0.0, 0.45, -2.7), Vector3(1.0, 0.9, 1.0), Color(0.2, 0.28, 0.35), r)
	var socket := instance_scene(stations, BASE + "interaction/vr_socket.tscn", "KeySocket", r)
	socket.position = Vector3(0.0, 1.1, -2.7)
	label(stations, "04 · ENCAJE\nSuelta la llave verde dentro del aro\nRetírala para cerrar la puerta", Vector3(0.0, 1.9, -3.0), r, "SocketSign", 30)
	var door := instance_scene(stations, BASE + "interaction/vr_door.tscn", "SlidingDoor", r)
	door.position = Vector3(3.0, 1.1, -4.5)
	world_box(stations, "DoorLeftPillar", Vector3(2.1, 1.1, -4.5), Vector3(0.3, 2.2, 0.3), Color(0.3, 0.4, 0.5), r)
	world_box(stations, "DoorRightPillar", Vector3(3.9, 1.1, -4.5), Vector3(0.3, 2.2, 0.3), Color(0.3, 0.4, 0.5), r)
	label(stations, "05 · PUERTA", Vector3(3.0, 2.8, -4.5), r, "DoorSign", 36)
	world_box(stations, "TeleportPlatform", Vector3(5.4, 0.2, -1.5), Vector3(2.2, 0.4, 2.2), Color(0.1, 0.4, 0.38), r, true)
	var ramp := world_box(stations, "Ramp", Vector3(5.4, 0.15, 0.3), Vector3(1.5, 0.1, 1.6), Color(0.12, 0.45, 0.4), r, true)
	ramp.rotation.x = 0.245
	label(stations, "06 · TELETRANSPORTE\nA: apuntar / soltar: viajar\nVerde válido · Rojo bloqueado", Vector3(5.4, 1.9, -1.5), r, "TeleportSign", 32)
	var target := add(stations, Area3D.new(), "ThrowTarget", r, true) as Area3D
	target.position = Vector3(-3.0, 0.8, -4.0)
	target.collision_layer = 0
	target.collision_mask = 2
	collision_box(target, Vector3(1.0, 0.7, 1.0), r)
	world_box(stations, "BasketBottom", Vector3(-3.0, 0.25, -4.0), Vector3(1.2, 0.2, 1.2), Color(0.75, 0.4, 0.1), r)
	world_box(stations, "BasketBack", Vector3(-3.0, 0.65, -4.6), Vector3(1.2, 0.8, 0.08), Color(0.75, 0.4, 0.1), r)
	world_box(stations, "BasketLeft", Vector3(-3.6, 0.65, -4.0), Vector3(0.08, 0.8, 1.2), Color(0.75, 0.4, 0.1), r)
	world_box(stations, "BasketRight", Vector3(-2.4, 0.65, -4.0), Vector3(0.08, 0.8, 1.2), Color(0.75, 0.4, 0.1), r)
	label(stations, "07 · CESTO\nLanza un cubo", Vector3(-3.0, 1.8, -4.5), r, "ThrowSign", 36)
	var progress := label(r, "", Vector3(-6.3, 1.7, -1.5), r, "Progress", 32)
	progress.unique_name_in_owner = true
	var help := add(r, CanvasLayer.new(), "DesktopHelp", r, true) as CanvasLayer
	var help_label := add(help, Label.new(), "Controls", r) as Label
	help_label.position = Vector2(16.0, 16.0)
	help_label.text = "ESCRITORIO · WASD: caminar (activar Movimiento libre) · Ratón: mirar\nQ/E: giro por pasos · T: apuntar teletransporte, soltar para viajar\nF/G: Grip izquierdo/derecho · Clic izquierdo/derecho: usar mano derecha/izquierda\nEsc: liberar/capturar ratón · En VR: stick izquierdo, stick derecho, Grip, gatillo y A"
	help_label.add_theme_font_size_override("font_size", 16)
	save_scene(r, "res://examples/interaction_lab/interaction_lab.tscn")
