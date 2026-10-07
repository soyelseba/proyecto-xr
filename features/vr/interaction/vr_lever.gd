class_name VRLever
extends AnimatableBody3D
signal value_changed(value: float)
signal grabbed(anchor: Node3D)
signal released(velocity: Vector3)
@export_range(10.0, 80.0) var angle_limit: float = 45.0
var value: float = 0.5
var _anchor: Node3D
var _base_transform: Transform3D

func _ready() -> void:
	_base_transform = transform

func begin_grab(anchor: Node3D) -> bool:
	if is_instance_valid(_anchor):
		return false
	_anchor = anchor
	grabbed.emit(anchor)
	return true

func end_grab(velocity: Vector3) -> void:
	_anchor = null
	released.emit(velocity)

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(_anchor):
		return
	var base_global := get_parent_node_3d().global_transform * _base_transform
	var direction := base_global.affine_inverse() * _anchor.global_position
	var angle := clampf(-atan2(direction.x, maxf(direction.y, 0.05)), -deg_to_rad(angle_limit), deg_to_rad(angle_limit))
	set_value(inverse_lerp(-deg_to_rad(angle_limit), deg_to_rad(angle_limit), angle))

func set_value(new_value: float) -> void:
	value = clampf(new_value, 0.0, 1.0)
	transform = _base_transform * Transform3D(Basis(Vector3.FORWARD, -lerpf(-deg_to_rad(angle_limit), deg_to_rad(angle_limit), value)), Vector3.ZERO)
	value_changed.emit(value)

func use(_anchor_node: Node3D) -> void:
	set_value(0.0 if value > 0.5 else 1.0)

func get_prompt() -> String:
	return "Palanca · Grip: arrastrar / Gatillo: alternar"
