class_name VRBoundary
extends Node
signal proximity_changed(near_boundary: bool)
@export_range(0.05, 1.0) var warning_distance: float = 0.25
@export var warning_label: Label3D
var _interface: XRInterface
var _head: XRCamera3D
var _origin: XROrigin3D
var _active: bool = false
var _near: bool = false
var _timer: float = 0.0

func configure(interface: XRInterface, head: XRCamera3D, origin: XROrigin3D, active: bool) -> void:
	_interface = interface
	_head = head
	_origin = origin
	_active = active

func _physics_process(delta: float) -> void:
	if not _active or _interface == null:
		return
	_timer -= delta
	if _timer > 0.0:
		return
	_timer = 0.2
	var bounds := _interface.get_play_area()
	if bounds.size() < 3:
		_set_near(false)
		return # The runtime's own boundary remains authoritative.
	var local_head := _origin.to_local(_head.global_position)
	var point := Vector2(local_head.x, local_head.z)
	var polygon := PackedVector2Array()
	for vertex: Vector3 in bounds:
		polygon.append(Vector2(vertex.x, vertex.z))
	var distance: float = INF
	for index: int in range(polygon.size()):
		var closest := Geometry2D.get_closest_point_to_segment(point, polygon[index], polygon[(index + 1) % polygon.size()])
		distance = minf(distance, point.distance_to(closest))
	_set_near(not Geometry2D.is_point_in_polygon(point, polygon) or distance < warning_distance)

func _set_near(near_boundary: bool) -> void:
	if warning_label != null:
		warning_label.visible = near_boundary
	if _near != near_boundary:
		_near = near_boundary
		proximity_changed.emit(_near)
