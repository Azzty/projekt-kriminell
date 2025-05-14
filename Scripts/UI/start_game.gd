extends Button

@export_file var first_scene: String

func _start_button_pressed() -> void:
	var music_nodes = get_tree().get_nodes_in_group("music")
	for node in music_nodes:
		if node.name == "TitleMusic":
			node.queue_free()
			break
	SceneManager.handle_scene_changed(first_scene)
	queue_free()
