extends Node

# Inventory
var inventory: Array[Dictionary] = []
signal item_added_to_inventory
signal item_removed_from_inventory

# Change of scene
signal change_scene(file_path: String)

# Money !!! 🦀🦀🦀😈😈🤸🦽🏌️
var _final_money_multiplier := 5
var money: int = 0:
	set(value):
		var added_value = value - money
		money += added_value * _final_money_multiplier
		money_changed.emit()
signal money_changed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	for i in range(2):
		var item := Sprite2D.new()
		item.name = "Crowbar"
		item.texture = preload("res://Assets/sprites/crowbar.png")
		add_item_to_inventory(item)
	for i in range(2):
		var item := Sprite2D.new()
		item.name = "Revolver"
		item.texture = preload("res://Assets/sprites/revolver.png")
		add_item_to_inventory(item)


func add_item_to_inventory(item: Sprite2D) -> void:
	var item_data = {"name": item.name, "texture": item.texture}
	
	item_data.name = _remove_number_suffix(item_data.name)
	inventory.append(item_data)
	print(item_data.name, " added to inventory")
	item_added_to_inventory.emit(item)

func remove_item_from_inventory(item: Sprite2D) -> void:
	var item_data = {"name": item.name, "texture": item.texture}
	
	# Fix name (remove digits)
	item_data.name = _remove_number_suffix(item_data.name)
	
	# Find first occurence of name from inventory
	var index_to_remove = -1
	for i in range(inventory.size()):
		if inventory[i].has("name") and inventory[i]["name"] == item_data.name:
			index_to_remove = i
			break
	
	# Remove item if exists
	if index_to_remove != -1:
		inventory.remove_at(index_to_remove)
		print(item_data.name, " removed from inventory")
	else:
		print(item_data.name, " not in inventory")
	
	item_removed_from_inventory.emit(item)

# Removes number suffix from name
func _remove_number_suffix(item_name: String):
	var digits_int = int(item_name)
	var digits_str = str(digits_int) if digits_int != 0 else ""
	return item_name.substr(0, item_name.length() - digits_str.length())
