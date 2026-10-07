class_name VRButton
extends StaticBody3D
signal activated
signal toggled(active: bool)
@export var caption: String = "Botón"
@export var toggle: bool = false
var active: bool = false
var _cooldown: float = 0.0
@onready var face: MeshInstance3D = %Face
@onready var label: Label3D = %Caption

func _ready() -> void:
	label.text = caption
	face.material_override = face.material_override.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)

func _physics_process(delta: float) -> void:
	_cooldown = maxf(0.0, _cooldown - delta)

func use(_anchor: Node3D) -> void:
	if _cooldown > 0.0:
		return
	_cooldown = 0.25
	if toggle:
		set_active(not active)
		toggled.emit(active)
	activated.emit()

func set_active(new_active: bool) -> void:
	active = new_active
	var material := face.material_override as StandardMaterial3D
	material.albedo_color = Color(0.1, 0.85, 0.5) if active else Color(0.2, 0.4, 0.7)

func reset_state() -> void:
	_cooldown = 0.0
	set_active(false)

func get_prompt() -> String:
	return caption + " · Gatillo: activar"
