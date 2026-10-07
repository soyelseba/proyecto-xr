class_name VRFlashlight
extends VRGrabbable
## A usable prop illustrating the grabbable 'used' extension point.
@onready var light: SpotLight3D = %Light

func _ready() -> void:
	super._ready()
	used.connect(_toggle_light)

func _toggle_light() -> void:
	light.visible = not light.visible

func reset_object() -> void:
	super.reset_object()
	light.visible = false

func get_prompt() -> String:
	return "Linterna · Grip: tomar / Gatillo: encender"
