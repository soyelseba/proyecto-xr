class_name VRSettings
extends Resource
## Shared, read-only defaults; VRPlayer duplicates this for each instance.
@export var continuous_movement: bool = false
@export_range(0.5, 5.0) var move_speed: float = 2.0
@export_range(15.0, 90.0) var snap_degrees: float = 30.0
@export_range(0.1, 0.9) var stick_deadzone: float = 0.25
@export var seated: bool = false
@export_range(0.0, 1.2) var seated_height_offset: float = 0.55
@export_range(0.0, 1.0) var vignette_strength: float = 0.65
@export_range(0.1, 1.0) var grab_threshold: float = 0.65
@export_range(0.1, 1.0) var release_threshold: float = 0.35
@export_range(0.5, 10.0) var ray_length: float = 4.0
@export var distance_grab: bool = true
