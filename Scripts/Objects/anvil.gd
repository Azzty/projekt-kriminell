extends Sprite2D

@onready var anvil_sprite_bounds: Rect2 = get_rect()

const item_template := preload("res://Scenes/Objects/Interactable Objects/movable_item.tscn")
const recipes := {
	"Crowbar": ["Iron ingot", "Iron ingot", "Iron ingot"]
}

var current_recipe: String
var active_slots: Array[Area2D] = [] # Slots that an item is hovering over
var held_item: Sprite2D
var items_in_slots := {} ## key = slot object, value = item object

var can_craft := false

## Connect slots to their functions
func _ready() -> void:
	for slot: Area2D in get_tree().get_nodes_in_group("item_slots"):
		slot.area_entered.connect(_on_item_slot_entered.bind(slot))
		slot.area_exited.connect(_on_item_slot_exited.bind(slot))

## Adds a slot to active_slots and adds a highlight
func _on_item_slot_entered(area: Area2D, slot: Area2D) -> void:
	var item: Sprite2D = Utilities.find_first_parent_of_class(area, "Sprite2D")
	if not item.has_meta("item_properties") or not item.is_in_group("resource_items"): return
	
	held_item = item
	if active_slots.size() > 0: active_slots[0].modulate = Color(1,1,1,1)
	active_slots.push_front(slot)
	active_slots[0].modulate = Color(1.5,1.5,1.5,1)

## Removes slot from active_slots and reverts highlight color
func _on_item_slot_exited(area: Area2D, slot: Area2D) -> void:
	if active_slots.size() == 0: return
	
	var item: Sprite2D = Utilities.find_first_parent_of_class(area, "Sprite2D")
	if not item.has_meta("item_properties") or not item.is_in_group("resource_items"): return
	
	active_slots[0].modulate = Color(1,1,1,1)
	active_slots.erase(slot)
	if active_slots.size() > 0: active_slots[0].modulate = Color(1.5,1.5,1.5,1)

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton: return
	if event.button_index != MOUSE_BUTTON_LEFT: return
	
	var mouse_position = get_global_mouse_position()
	
	# Remove item from slot when clicking on it
	for slot: Area2D in items_in_slots:
		var item: Sprite2D = items_in_slots[slot]
		if not item: continue
		
		var item_rect := item.get_rect()
		if item_rect.has_point(item.to_local(mouse_position)):
			item.set_process(true)
			item.modulate = Color(1,1,1,1)
			slot.monitoring = true
			items_in_slots[slot] = null
	
	if can_craft and anvil_sprite_bounds.has_point(to_local(mouse_position)):
		dispense_current_recipe() # Craft the item
	
	place_held_item_in_slot()
	
	# Check current setup for matching recipes
	var items_in_slot_names = []
	for item in items_in_slots.values():
		if not item: continue
		items_in_slot_names.append(item.get_meta("item_properties").name)
	for recipe_name: String in recipes:
		var recipe: Array = recipes[recipe_name]
		if recipe == items_in_slot_names:
			print("Current setup matches recipe!")
			can_craft = true
			current_recipe = recipe_name
			break
		else:
			current_recipe = ""
			can_craft = false

## Creates a new item using the current recipe and adds it to the world
func dispense_current_recipe():
	if not current_recipe: return
	# Get data for the selected recipe
	var item_data := GameItem.new(current_recipe)
	if not item_data:
		return
	
	# Create the item
	var result_item := item_template.instantiate()
	result_item.set_meta("item_properties", item_data)
	result_item.bounds_cshape = get_parent().find_child("ItemZone").find_child("ItemCollisionShape")
	result_item.texture = Utilities.get_bigger_texture_as_texture(item_data)
	result_item.scale = Vector2(2,2)
	result_item.bounds_cshape.add_sibling(result_item)
	result_item.global_position = global_position
	result_item.name = item_data.name
	result_item.released_out_of_bounds = true
	print(get_tree().get_nodes_in_group("shop_items"))
	var reference_shop_item = get_tree().get_first_node_in_group("shop_items")
	result_item.customer = reference_shop_item.customer
	result_item.customer_drop_shape = reference_shop_item.customer_drop_shape
	result_item.customer_requested_tags = reference_shop_item.customer_requested_tags
	result_item.add_to_group("shop_items")
	
	GameState.add_item_to_inventory(result_item)
	
	# Remove the materials from the anvil
	remove_items_from_slots()

## Removes all materials placed in the anvils slots
func remove_items_from_slots():
	for slot in items_in_slots:
		var item: Sprite2D = items_in_slots[slot]
		if not item: continue
		items_in_slots[slot] = null
		GameState.remove_item_from_inventory(item)
		item.queue_free()

## Places the held_item in the first slot in active_slots
func place_held_item_in_slot():
	if active_slots.size() == 0: return
	items_in_slots[active_slots[0]] = held_item
	held_item.reparent(get_node("."))
	held_item.set_process(false)
	held_item.global_position = active_slots[0].global_position
	held_item.rotation_degrees = active_slots[0].rotation_degrees + 90
	active_slots[0].monitoring = false # Set this last, otherwise it will send out exited signal

# Highlight when hovering
func _process(_delta: float) -> void:
	var mouse_position := get_global_mouse_position()
	if can_craft and anvil_sprite_bounds.has_point(to_local(mouse_position)):
		self_modulate.r = 1.2
		self_modulate.g = 1.2
		self_modulate.b = 1.2
	else:
		self_modulate.r = 1.0
		self_modulate.g = 1.0
		self_modulate.b = 1.0
	
	for item: Sprite2D in items_in_slots.values():
		if not item: continue
		
		var item_rect := item.get_rect()
		#item_rect.position = item.position
		
		if item_rect.has_point(item.to_local(mouse_position)):
			item.modulate = Color(0.8,0.8,0.8,1)
		else:
			item.modulate = Color(1,1,1,1)

func update_rect():
	anvil_sprite_bounds = get_rect()
