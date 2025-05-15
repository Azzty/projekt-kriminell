extends Control

func _on_retry_button_pressed() -> void:
	print("Pressed!")
	get_tree().paused = false
	GameState.change_scene.emit("", true)
	GuiManager.clear_extra_ui_elements()
