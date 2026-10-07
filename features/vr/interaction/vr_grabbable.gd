class_name VRGrabbable
extends RigidBody3D
signal grabbed(anchor: Node3D)
signal released(velocity: Vector3)
signal used
@export var display_name: String = "Objeto"
@export var color: Color = Color(0.95, 0.55, 0.15)
@export var item_id: StringName = &"cube"
@export var snap_to_hand: bool = true
@export_range(1.0, 40.0) var follow_speed: float = 18.0
@export_range(1.0, 15.0) var maximum_throw_speed: float = 8.0
var held_by: Node3D
var _offset: Transform3D = Transform3D.IDENTITY
var _pending_reset: bool = false
var _reset_transform: Transform3D
var _spawn_transform: Transform3D

func _ready() -> void:
	var visual := %Visual as MeshInstance3D
	visual.material_override = visual.material_override.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	(visual.material_override as StandardMaterial3D).albedo_color = color
	_spawn_transform = global_transform
	add_to_group(&"vr_grabbable")

func begin_grab(anchor: Node3D) -> bool:
	if is_instance_valid(held_by):
		return false
	held_by = anchor
	_offset = Transform3D.IDENTITY if snap_to_hand else anchor.global_transform.affine_inverse() * global_transform
	freeze = false
	sleeping = false
	grabbed.emit(anchor)
	return true

func end_grab(throw_velocity: Vector3) -> void:
	held_by = null
	linear_velocity = throw_velocity.limit_length(maximum_throw_speed)
	angular_velocity = angular_velocity.limit_length(15.0)
	released.emit(linear_velocity)

func use(_anchor: Node3D) -> void:
	used.emit()

func get_prompt() -> String:
	return display_name + " · Grip: tomar / soltar"

func offset_for_teleport(offset: Vector3) -> void:
	_reset_transform = global_transform
	_reset_transform.origin += offset
	_pending_reset = true
	sleeping = false

func can_socket() -> bool:
	return not _pending_reset and not is_instance_valid(held_by)

func reset_object() -> void:
	held_by = null
	freeze = false
	_reset_transform = _spawn_transform
	_pending_reset = true
	sleeping = false

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if _pending_reset:
		state.transform = _reset_transform
		state.linear_velocity = Vector3.ZERO
		state.angular_velocity = Vector3.ZERO
		_pending_reset = false
		return
	if not is_instance_valid(held_by):
		held_by = null
		return
	var target := held_by.global_transform * _offset
	state.linear_velocity = ((target.origin - state.transform.origin) * follow_speed).limit_length(12.0)
	var rotation_delta := (target.basis.get_rotation_quaternion() * state.transform.basis.get_rotation_quaternion().inverse()).normalized()
	if rotation_delta.w < 0.0:
		rotation_delta = -rotation_delta
	var angle := rotation_delta.get_angle()
	state.angular_velocity = rotation_delta.get_axis() * minf(angle * follow_speed, 15.0) if angle > 0.001 else Vector3.ZERO
