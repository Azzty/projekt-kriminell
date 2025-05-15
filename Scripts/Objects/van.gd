extends Sprite2D

func _on_hold_button_activated() -> void:
	for item in GameState.held_items.duplicate():
		print("Looping")
		GameState.add_item_to_inventory(item)
