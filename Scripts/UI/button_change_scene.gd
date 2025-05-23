extends Button

@export_file("*.tscn") var scene_to_switch_to

func _pressed() -> void:
	if owner.get("exit"): owner.exit.emit()
	GameState.change_scene.emit(scene_to_switch_to)
