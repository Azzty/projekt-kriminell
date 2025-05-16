extends Sprite2D

func _on_exfiltrate_button_activated() -> void:
	for item in GameState.held_items.duplicate():
		print("Looping")
		GameState.add_item_to_inventory(item)
	GameState.change_scene.emit("res://Scenes/Levels/store.tscn")

func _on_put_in_van_button_activated() -> void:
	for item in GameState.held_items.duplicate():
		print("Looping")
		GameState.add_item_to_inventory(item)
