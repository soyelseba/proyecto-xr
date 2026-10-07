extends SceneTree
func _init() -> void:
	capture.call_deferred()
func capture() -> void:
	var lab := load("res://examples/interaction_lab/interaction_lab.tscn").instantiate() as Node3D
	root.add_child(lab)
	current_scene = lab
	root.size = Vector2i(1280, 720)
	for index: int in range(45):
		await process_frame
	await RenderingServer.frame_post_draw
	var result := root.get_texture().get_image().save_png("res://tools/lab_preview.png")
	print("Screenshot result: ", result)
	quit(result)
