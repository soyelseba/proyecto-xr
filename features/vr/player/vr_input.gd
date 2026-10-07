class_name VRInput
extends Node
## Desktop adapter and OpenXR share exactly the same gameplay commands.
@export var move_action: StringName = &"primary"
@export var turn_action: StringName = &"primary"
@export var grip_action: StringName = &"grip"
@export var use_action: StringName = &"trigger"
@export var teleport_action: StringName = &"ax_button"
var xr_active: bool = false
var _pitch: float = 0.0
var _camera: XRCamera3D
var _body: CharacterBody3D
var _left: VRHand
var _right: VRHand

func configure(active: bool, body: CharacterBody3D, camera: XRCamera3D, left: VRHand, right: VRHand) -> void:
	xr_active = active
	_body = body
	_camera = camera
	_left = left
	_right = right
	if not active:
		_camera.position = Vector3(0.0, 1.7, 0.0)
		if DisplayServer.get_name() != "headless":
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if xr_active or _camera == null:
		return
	if event.is_action_pressed(&"desktop_capture"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var motion := event as InputEventMouseMotion
		_body.rotate_y(-motion.relative.x * 0.002)
		_pitch = clampf(_pitch - motion.relative.y * 0.002, -1.2, 1.2)
		_camera.rotation.x = _pitch

func update_desktop_hands() -> void:
	if xr_active:
		return
	for hand: VRHand in [_left, _right]:
		var side: float = -1.0 if hand == _left else 1.0
		hand.grip.global_transform = _camera.global_transform.translated_local(Vector3(side * 0.22, -0.22, -0.4))
		hand.aim.global_transform = hand.grip.global_transform

func move_vector() -> Vector2:
	if xr_active:
		var axis := _left.grip.get_vector2(move_action) if _left.grip.get_has_tracking_data() else Vector2.ZERO
		return Vector2(axis.x, -axis.y)
	return Input.get_vector(&"desktop_left", &"desktop_right", &"desktop_forward", &"desktop_back")

func turn_value() -> float:
	if xr_active:
		return _right.grip.get_vector2(turn_action).x if _right.grip.get_has_tracking_data() else 0.0
	return Input.get_axis(&"desktop_turn_left", &"desktop_turn_right")

func can_teleport() -> bool:
	return not xr_active or _right.aim.get_has_tracking_data()

func teleport_pressed() -> bool:
	if xr_active:
		return _right.aim.get_has_tracking_data() and _right.aim.is_button_pressed(teleport_action)
	return Input.is_action_pressed(&"desktop_teleport")

func grip_value(hand: VRHand) -> float:
	if xr_active:
		return hand.grip.get_float(grip_action) if hand.grip.get_has_tracking_data() else 0.0
	return float(Input.is_action_pressed(&"desktop_grab_left" if hand == _left else &"desktop_grab_right"))

func use_value(hand: VRHand) -> float:
	if xr_active:
		return hand.grip.get_float(use_action) if hand.grip.get_has_tracking_data() else 0.0
	return float(Input.is_action_pressed(&"desktop_use_left" if hand == _left else &"desktop_use_right"))
