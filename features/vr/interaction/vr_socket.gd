class_name VRSocket
extends Area3D
signal inserted(item: VRGrabbable)
signal removed(item: VRGrabbable)
@export var accepted_item: StringName = &"key"
@onready var snap_point: Marker3D = %SnapPoint
var occupant: VRGrabbable
var _cooldown: float = 0.0

func _physics_process(delta: float) -> void:
	_cooldown = maxf(0.0, _cooldown - delta)
	if _cooldown > 0.0:
		return
	if is_instance_valid(occupant):
		return
	occupant = null
	for body: Node3D in get_overlapping_bodies():
		var item := body as VRGrabbable
		if item != null and item.item_id == accepted_item and item.can_socket() and item.global_position.distance_to(snap_point.global_position) < 0.25:
			insert_item(item)
			return

func insert_item(item: VRGrabbable) -> bool:
	if is_instance_valid(occupant) or item.item_id != accepted_item or not item.can_socket():
		return false
	occupant = item
	item.freeze = true
	item.linear_velocity = Vector3.ZERO
	item.angular_velocity = Vector3.ZERO
	item.global_transform = snap_point.global_transform
	item.grabbed.connect(_on_item_grabbed)
	inserted.emit(item)
	return true

func eject() -> void:
	_cooldown = 0.3
	if not is_instance_valid(occupant):
		occupant = null
		return
	var item := occupant
	occupant = null
	if item.grabbed.is_connected(_on_item_grabbed):
		item.grabbed.disconnect(_on_item_grabbed)
	item.freeze = false
	removed.emit(item)

func _on_item_grabbed(_anchor: Node3D) -> void:
	eject()

func _exit_tree() -> void:
	eject()
