extends Button

@export_file var first_scene: String

func _on_pressed() -> void:
	SceneManager.handle_scene_changed(first_scene)
	queue_free()
