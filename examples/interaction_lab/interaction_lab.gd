extends Node3D
## Demo-specific wiring; reusable VR components have no knowledge of this room.
@onready var player: VRPlayer = %VRPlayer
@onready var socket: VRSocket = %KeySocket
@onready var door: VRDoor = %SlidingDoor
@onready var lever: VRLever = %Lever
@onready var status: Label3D = %Progress
@onready var movement_button: VRButton = %MovementButton
@onready var seated_button: VRButton = %SeatedButton
var _completed: Dictionary[StringName, bool] = {}
var _thrown_items: Dictionary[int, bool] = {}
const ACTIVITIES: Dictionary[StringName, String] = {
	&"movement": "Movimiento", &"turn": "Giro por pasos", &"teleport": "Teletransporte",
	&"grab": "Agarre", &"use": "Botones / uso", &"lever": "Palanca",
	&"socket": "Encaje", &"door": "Puerta", &"throw": "Lanzamiento al cesto"
}

func _ready() -> void:
	player.activity_completed.connect(_on_activity)
	movement_button.activated.connect(player.toggle_movement)
	seated_button.activated.connect(player.toggle_seated)
	(%DoorButton as VRButton).activated.connect(door.toggle_open)
	(%ResetButton as VRButton).activated.connect(reset_lab)
	lever.value_changed.connect(_on_lever_changed)
	socket.inserted.connect(_on_key_inserted)
	socket.removed.connect(_on_key_removed)
	door.opened_changed.connect(_on_door_changed)
	(%ThrowTarget as Area3D).body_entered.connect(_on_throw_target_entered)
	(%DesktopHelp as CanvasLayer).visible = not player.session.xr_active
	_update_progress()

func _on_activity(activity: StringName) -> void:
	if not _completed.get(activity, false):
		_completed[activity] = true
		_update_progress()

func _update_progress() -> void:
	var lines := PackedStringArray(["PRUEBAS DE INTERACCIÓN"])
	for activity: StringName in ACTIVITIES:
		lines.append(("[OK] " if _completed.get(activity, false) else "[  ] ") + ACTIVITIES[activity])
	status.text = "\n".join(lines)

func _on_lever_changed(value: float) -> void:
	(%LeverIndicator as MeshInstance3D).scale.y = 0.1 + value * 1.5
	_on_activity(&"lever")

func _on_key_inserted(_item: VRGrabbable) -> void:
	door.set_open(true)
	_on_activity(&"socket")

func _on_key_removed(_item: VRGrabbable) -> void:
	door.set_open(false)

func _on_door_changed(_opened: bool) -> void:
	_on_activity(&"door")

func _on_throw_target_entered(body: Node3D) -> void:
	var item := body as VRGrabbable
	if item == null or is_instance_valid(item.held_by) or _thrown_items.has(item.get_instance_id()):
		return
	_thrown_items[item.get_instance_id()] = true
	_on_activity(&"throw")

func reset_lab() -> void:
	player.reset_player()
	socket.eject()
	for node: Node in get_tree().get_nodes_in_group(&"vr_grabbable"):
		(node as VRGrabbable).reset_object()
	door.set_open(false)
	lever.set_value(0.5)
	player.settings.continuous_movement = false
	player.locomotion.set_seated(false)
	movement_button.reset_state()
	seated_button.reset_state()
	_completed.clear()
	_thrown_items.clear()
	_update_progress()
