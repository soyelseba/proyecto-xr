class_name XRSession
extends Node
signal mode_changed(xr_active: bool)
signal focus_changed(focused: bool)
signal recentered
@export var requested_refresh_rate: float = 90.0
var xr_active: bool = false
var interface: OpenXRInterface
var _paused_by_session: bool = false
var _previous_mute: bool = false
var _previous_pause: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var desktop_requested := OS.get_cmdline_user_args().has("--desktop")
	interface = XRServer.find_interface("OpenXR") as OpenXRInterface
	if not desktop_requested and interface != null and interface.is_initialized():
		xr_active = true
		get_viewport().use_xr = true
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		if RenderingServer.get_rendering_device() != null:
			get_viewport().vrs_mode = Viewport.VRS_XR
		interface.session_begun.connect(_on_session_begun)
		interface.session_visible.connect(_lose_focus)
		interface.session_synchronized.connect(_lose_focus)
		interface.session_focussed.connect(_gain_focus)
		interface.session_stopping.connect(_lose_focus)
		interface.session_loss_pending.connect(_lose_focus)
		interface.pose_recentered.connect(_on_recentered)
		interface.refresh_rate_changed.connect(_on_refresh_rate_changed)
		_on_session_begun()
	elif OS.has_feature("android") and not desktop_requested:
		push_error("OpenXR no está disponible en el visor. Revisar configuración y runtime.")
		get_tree().quit(1)
	mode_changed.emit(xr_active)

func _on_session_begun() -> void:
	var best_rate: float = 0.0
	for rate: float in interface.get_available_display_refresh_rates():
		if rate <= requested_refresh_rate and rate > best_rate:
			best_rate = rate
	if best_rate > 0.0:
		interface.set_display_refresh_rate(best_rate)
	_on_refresh_rate_changed(interface.get_display_refresh_rate())

func _on_refresh_rate_changed(rate: float) -> void:
	if rate > 0.0:
		Engine.physics_ticks_per_second = roundi(rate)

func _lose_focus() -> void:
	if _paused_by_session:
		return
	_previous_pause = get_tree().paused
	_previous_mute = AudioServer.is_bus_mute(0)
	focus_changed.emit(false)
	_paused_by_session = true
	get_tree().paused = true
	AudioServer.set_bus_mute(0, true)

func _gain_focus() -> void:
	if _paused_by_session:
		get_tree().paused = _previous_pause
		AudioServer.set_bus_mute(0, _previous_mute)
		_paused_by_session = false
	focus_changed.emit(true)

func _on_recentered() -> void:
	recentered.emit()

func _exit_tree() -> void:
	if _paused_by_session:
		get_tree().paused = _previous_pause
		AudioServer.set_bus_mute(0, _previous_mute)
