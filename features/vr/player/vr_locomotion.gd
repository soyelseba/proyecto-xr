class_name VRLocomotion
extends Node
signal moved(distance: float)
signal turned(degrees: float)
signal teleported(destination: Vector3)
var body: CharacterBody3D
var camera: XRCamera3D
var origin: XROrigin3D
var body_shape: CollisionShape3D
var settings: VRSettings
var _turn_armed: bool = true
var _gravity: float = 9.8

func configure(player_body: CharacterBody3D, head: XRCamera3D, xr_origin: XROrigin3D, shape: CollisionShape3D, config: VRSettings) -> void:
	body = player_body
	camera = head
	origin = xr_origin
	body_shape = shape
	settings = config
	_gravity = float(ProjectSettings.get_setting("physics/3d/default_gravity", 9.8))

func tick(delta: float, move_input: Vector2, turn_input: float, allow_move: bool = true) -> void:
	_update_capsule()
	if absf(turn_input) < settings.stick_deadzone:
		_turn_armed = true
	elif absf(turn_input) > 0.7 and _turn_armed and allow_move:
		_turn_armed = false
		snap_turn(-signf(turn_input) * settings.snap_degrees)
	var direction := Vector3.ZERO
	if settings.continuous_movement and allow_move and move_input.length() > settings.stick_deadzone:
		var forward := -camera.global_basis.z
		forward.y = 0.0
		forward = forward.normalized()
		var right := forward.cross(Vector3.UP)
		direction = (right * move_input.x - forward * move_input.y).limit_length(1.0)
	body.velocity.x = direction.x * settings.move_speed
	body.velocity.z = direction.z * settings.move_speed
	if body.is_on_floor():
		body.velocity.y = 0.0
	else:
		body.velocity.y -= _gravity * delta
	var before := body.global_position
	body.move_and_slide()
	var distance := Vector2(body.global_position.x - before.x, body.global_position.z - before.z).length()
	if distance > 0.0001:
		moved.emit(distance)

func _update_capsule() -> void:
	var head_local := body.to_local(camera.global_position)
	var capsule := body_shape.shape as CapsuleShape3D
	capsule.height = clampf(head_local.y, 0.65, 2.3)
	body_shape.position = Vector3(head_local.x, capsule.height * 0.5 + 0.02, head_local.z)

func snap_turn(degrees: float) -> void:
	var pivot := camera.global_position
	body.rotate_y(deg_to_rad(degrees))
	var correction := pivot - camera.global_position
	correction.y = 0.0
	body.global_position += correction
	turned.emit(degrees)

func teleport_to(destination: Vector3) -> void:
	var head_offset := camera.global_position - body.global_position
	head_offset.y = 0.0
	body.global_position = destination - head_offset + Vector3.UP * 0.03
	body.velocity = Vector3.ZERO
	body.reset_physics_interpolation()
	teleported.emit(destination)

func set_seated(enabled: bool) -> void:
	settings.seated = enabled
	origin.position.y = settings.seated_height_offset if enabled else 0.0
