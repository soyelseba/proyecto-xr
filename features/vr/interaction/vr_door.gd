class_name VRDoor
extends AnimatableBody3D
signal opened_changed(opened: bool)
@export var travel: Vector3 = Vector3(0.0, 2.4, 0.0)
@export_range(0.1, 5.0) var duration: float = 0.7
var opened: bool = false
var _closed_position: Vector3
var _tween: Tween

func _ready() -> void:
	_closed_position = position

func set_open(new_opened: bool) -> void:
	opened = new_opened
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_tween.tween_property(self, "position", _closed_position + (travel if opened else Vector3.ZERO), duration).set_trans(Tween.TRANS_SINE)
	opened_changed.emit(opened)

func toggle_open() -> void:
	set_open(not opened)
