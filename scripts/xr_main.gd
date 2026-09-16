extends Node3D

func _ready() -> void:
	var xr_interface: XRInterface = XRServer.find_interface("OpenXR")
	
	if xr_interface == null:
		push_error("No se encuentra la interfaz OpenXR")
		return
		
	if not xr_interface.is_initialized():
		var initialized := xr_interface.initialize()
		
		if not initialized:
			push_error("No se pudo inicializar la interfaz XR")
			return
		
		get_viewport().use_xr = true
		print("OpenXR inicializado correctamente.")
