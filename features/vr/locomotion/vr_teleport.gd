class_name VRTeleport
extends Node3D
signal target_changed(valid: bool)
@export_range(1.0, 15.0) var launch_speed: float = 7.0
@export_range(2.0, 20.0) var maximum_distance: float = 10.0
@export_range(10.0, 60.0) var maximum_slope: float = 40.0
@export_range(0.1, 4.0) var maximum_height_change: float = 1.5
@onready var marker: MeshInstance3D = %DestinationMarker
@onready var arc: MeshInstance3D = %Arc
var target_valid: bool = false
var destination: Vector3 = Vector3.ZERO
var _body_shape: CollisionShape3D
var _body: CharacterBody3D
var _camera: XRCamera3D
var _surface: Node
var _normal: Vector3 = Vector3.UP
var _aim: XRController3D
var _mesh: ImmediateMesh = ImmediateMesh.new()
var _material: StandardMaterial3D = StandardMaterial3D.new()

func _ready() -> void:
	arc.mesh = _mesh
	_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_material.vertex_color_use_as_albedo = true
	_material.no_depth_test = false
	arc.material_override = _material

func configure(body: CharacterBody3D, head: XRCamera3D, controller: XRController3D, body_shape: CollisionShape3D) -> void:
	_body = body
	_camera = head
	_aim = controller
	_body_shape = body_shape

func update_target(active: bool) -> void:
	arc.visible = active
	marker.visible = active
	if not active:
		return # Keep the last validated target for release-to-teleport.
	var was_valid := target_valid
	target_valid = false
	var space := get_world_3d().direct_space_state
	var point := _aim.global_position
	var velocity := -_aim.global_basis.z * launch_speed + Vector3.UP * 1.5
	var points := PackedVector3Array([point])
	var hit: Dictionary = {}
	for index: int in range(50):
		var next := point + velocity * 0.06
		var query := PhysicsRayQueryParameters3D.create(point, next, 11, [_body.get_rid()])
		hit = space.intersect_ray(query)
		if not hit.is_empty():
			points.append(hit.position)
			break
		points.append(next)
		point = next
		velocity += Vector3.DOWN * 9.8 * 0.06
	if not hit.is_empty():
		destination = hit.position
		_surface = hit.collider as Node
		_normal = hit.normal
		target_valid = validate_destination(destination, _normal, _surface)
		marker.global_position = destination + Vector3.UP * 0.015
	else:
		marker.visible = false
	var color := Color(0.1, 1.0, 0.65) if target_valid else Color(1.0, 0.25, 0.2)
	(marker.material_override as StandardMaterial3D).albedo_color = color
	_mesh.clear_surfaces()
	_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	for index: int in range(points.size() - 1):
		_mesh.surface_set_color(color)
		_mesh.surface_add_vertex(arc.to_local(points[index]))
		_mesh.surface_set_color(color)
		_mesh.surface_add_vertex(arc.to_local(points[index + 1]))
	_mesh.surface_end()
	if was_valid != target_valid:
		target_changed.emit(target_valid)

func validate_destination(point: Vector3, normal: Vector3, surface: Node) -> bool:
	if surface == null or not surface.is_in_group(&"vr_teleportable"):
		return false
	if normal.dot(Vector3.UP) < cos(deg_to_rad(maximum_slope)):
		return false
	if point.distance_to(_body.global_position) > maximum_distance or absf(point.y - _body.global_position.y) > maximum_height_change:
		return false
	var height := clampf(_camera.global_position.y - _body.global_position.y, 0.65, 2.3)
	var capsule := CapsuleShape3D.new()
	capsule.radius = (_body_shape.shape as CapsuleShape3D).radius
	capsule.height = height
	var clearance := PhysicsShapeQueryParameters3D.new()
	clearance.shape = capsule
	clearance.transform = Transform3D(Basis.IDENTITY, point + Vector3.UP * (height * 0.5 + 0.06))
	clearance.collision_mask = 11
	clearance.exclude = [_body.get_rid()]
	if not get_world_3d().direct_space_state.intersect_shape(clearance, 1).is_empty():
		return false
	# The entire footprint must be supported, so edges and tiny platforms are rejected.
	var radius := capsule.radius * 0.9
	for offset: Vector3 in [Vector3(radius, 0.0, 0.0), Vector3(-radius, 0.0, 0.0), Vector3(0.0, 0.0, radius), Vector3(0.0, 0.0, -radius)]:
		var query := PhysicsRayQueryParameters3D.create(point + offset + Vector3.UP * 0.2, point + offset - Vector3.UP * 0.2, 1)
		var support := get_world_3d().direct_space_state.intersect_ray(query)
		if support.is_empty() or not (support.collider as Node).is_in_group(&"vr_teleportable"):
			return false
	return true

func confirm_destination() -> bool:
	return target_valid and is_instance_valid(_surface) and validate_destination(destination, _normal, _surface)

func cancel() -> void:
	target_valid = false
	arc.visible = false
	marker.visible = false
