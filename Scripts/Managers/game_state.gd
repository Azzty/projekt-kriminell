extends Node

const DEFAULT_PLAYER_SPEED := 150

# Playerstats
var player: CharacterBody2D
var player_speed := DEFAULT_PLAYER_SPEED

# Inventory
var inventory: Array[Object] = []
var held_items: Array[Object] = [] ## Items held by player not yet added to inventory (via van or something)
const MAX_HELD_ITEMS := 2
signal item_added_to_inventory
signal item_added_to_held_items
signal item_removed_from_inventory
signal item_removed_from_held_items

# Change of scene
@warning_ignore("unused_signal")
signal change_scene(file_path: String, restart_current_scene: bool)

# Money !!! 🦀🦀🦀😈😈🤸🦽🏌️
var multiplier_upgrade := 1.0:
	set(value):
		multiplier_upgrade = value
		_update_final_money_multiplier()
var _final_money_multiplier := 1.0
var money: int = 500:
	set(value):
		var added_value = value - money
		if added_value < 0:
			money = value
			money_changed.emit()
			return
		money += added_value * _final_money_multiplier
		money_changed.emit()
signal money_changed

# Buttons eligble to be shown
var buttons_in_range: Array[Button] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	debug_add_items()

func debug_add_items():
	for i in range(2):
		var item_data = GameItem.new("Crowbar")
		var item := Sprite2D.new()
		item.name = item_data.name
		item.texture = item_data.texture
		item.set_meta("item_properties", item_data)
		add_item_to_inventory(item)
	for i in range(2):
		var item_data = GameItem.new("Revolver")
		var item := Sprite2D.new()
		item.name = item_data.name
		item.texture = item_data.texture
		item.set_meta("item_properties", item_data)
		add_item_to_inventory(item)

func add_item_to_held_items(item: Sprite2D) -> bool:
	var success := false

	if held_items.size() < MAX_HELD_ITEMS:
		held_items.append(item)
		success = true
	else:
		return success
	item_added_to_held_items.emit(item)
	return success

func add_item_to_inventory(item: Sprite2D) -> void:
	if item in held_items: remove_item_from_held_items(item)
	var item_data = item.get_meta("item_properties")

	item_data.name = _remove_number_suffix(item_data.name)
	inventory.append(item_data)
	print(item_data.name, " added to inventory")
	item_added_to_inventory.emit(item)

func remove_item_from_held_items(item: Sprite2D) -> void:
	if item in held_items:
		held_items.erase(item)
	item_removed_from_held_items.emit(item)

func remove_item_from_inventory(item: Sprite2D) -> void:
	var item_name = item.name

	# Fix name (remove digits)
	item_name = _remove_number_suffix(item_name)

	# Find first occurence of name from inventory
	var index_to_remove = -1
	for i in range(inventory.size()):
		if inventory[i]["name"] == item_name:
			index_to_remove = i
			break

	# Remove item if exists
	if index_to_remove != -1:
		inventory.remove_at(index_to_remove)
		print(item_name, " removed from inventory")
	else:
		print(item_name, " not in inventory")

	item_removed_from_inventory.emit(item)

## Removes number suffix from name, example: Crowbar2 -> Crowbar
func _remove_number_suffix(item_name: String):
	var digits_int = int(item_name)
	var digits_str = str(digits_int) if digits_int != 0 else ""
	return item_name.substr(0, item_name.length() - digits_str.length())

func _get_player_node():
	return get_tree().get_first_node_in_group("player")

func get_closest_button_to_player():
	if not player: player = _get_player_node()
	var closest_distance = INF
	var closest_button = null

	for button in buttons_in_range:
		var distance = button.global_position.distance_to(player.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_button = button

	return closest_button

## Update the multiplier by combining all other multipliers
func _update_final_money_multiplier():
	_final_money_multiplier = 1.0
	_final_money_multiplier *= multiplier_upgrade
