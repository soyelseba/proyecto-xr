extends XRController3D

@export var grab_action: StringName
@export var raycast: RayCast3D

var grabbed_object: RigidBody3D = null
var previous_parent: Node = null
var grab_was_pressed := false

func _physics_process(delta: float) -> void:
	var grab_is_pressed := Input.is_action_just_pressed(grab_action)
	
	if grab_is_pressed and not grab_was_pressed:
		try_grab()
	if not grab_is_pressed and grab_was_pressed:
		release_object()
		
	grab_was_pressed = grab_is_pressed
		
func try_grab() -> void:
	if grabbed_object != null:
		return
	
	if raycast == null or not raycast.is_colliding():
		return
		
	var collider := raycast.get_collider()
	
	if collider is RigidBody3D and collider.is_in_group("grabbable"):
		grabbed_object = collider
		previous_parent = grabbed_object.get_parent()
		
		grabbed_object.freeze = true
		grabbed_object.reparent(self, true)
		grabbed_object.global_transform = global_transform

func release_object() -> void:
	if grabbed_object == null:
		return
	
	var released_object := grabbed_object
	grabbed_object = null
	
	var release_transform := released_object.global_transform
	var target_parent: Node = previous_parent
	
	if target_parent == null or not is_instance_valid(target_parent):
		target_parent = get_tree().current_scene
	
	released_object.reparent(target_parent, true)
	released_object.global_transform = release_transform
	released_object.freeze = false
	
	previous_parent = null
