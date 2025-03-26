extends Node

var inventory := []

signal item_added_to_inventory
signal item_removed_from_inventory

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func add_item_to_inventory(item: Sprite2D) -> void:
	inventory.append(item)
	print(item, "added to inventory")
	item_added_to_inventory.emit(item)

func remove_item_from_inventory(item: Sprite2D) -> void:
	inventory.erase(item)
	print(item, "removed from inventory")
	item_removed_from_inventory.emit(item)
