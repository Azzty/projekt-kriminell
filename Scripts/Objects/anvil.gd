extends Sprite2D

@onready var anvil_sprite_bounds: Rect2 = get_node(".").get_rect()

const recipes := {
	"Crowbar": ["Iron ingot", "Iron ingot", "Iron ingot"]
}

var active_slots: Array[Area2D] = [] # Slots that an item is hovering over
var held_item: Sprite2D
var materials_in_machine := {}
var items_in_slots := {} ## key = slot object, value = item object

var can_craft := false

func _ready() -> void:
	# Connect slots to their functions
	for slot: Area2D in get_tree().get_nodes_in_group("item_slots"):
		slot.area_entered.connect(_on_item_slot_entered.bind(slot))
		slot.area_exited.connect(_on_item_slot_exited.bind(slot))

func _on_item_slot_entered(area: Area2D, slot: Area2D) -> void:
	var item: Sprite2D = Utilities.find_first_parent_of_class(area, "Sprite2D")
	if not item.has_meta("item_properties") or not item.is_in_group("resource_items"): return
	
	held_item = item
	if active_slots.size() > 0: active_slots[0].modulate = Color(1,1,1,1)
	active_slots.push_front(slot)
	active_slots[0].modulate = Color(1.5,1.5,1.5,1)

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
		pass # Craft the item (find it in game_item_class)
	
	place_held_item_in_slot()
	
	# Check current setup for matching recipes
	var items_in_slot_names = []
	for item in items_in_slots.values():
		if not item: continue
		items_in_slot_names.append(item.get_meta("item_properties").name)
	for recipe in recipes.values():
		if recipe == items_in_slot_names:
			print("Current setup matches recipe!")
			can_craft = true
			break
		else:
			can_craft = false

func place_held_item_in_slot():
	if active_slots.size() == 0: return
	items_in_slots[active_slots[0]] = held_item
	_add_item_materials(held_item)
	held_item.reparent(get_node("."))
	held_item.set_process(false)
	held_item.global_position = active_slots[0].global_position
	held_item.rotation_degrees = active_slots[0].rotation_degrees + 90
	active_slots[0].monitoring = false # Set this last, otherwise it will send out exited signal

func _add_item_materials(item: Sprite2D):
	if not item.get_meta("item_properties").materials: return
	
	var item_materials: Dictionary = item.get_meta("item_properties").materials
	# Add smelted materials to furnace
	for material_name in item_materials:
		var material_amount = item_materials[material_name]
		if not materials_in_machine.has(material_name):
			materials_in_machine[material_name] = 0.0
		materials_in_machine[material_name] += material_amount

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
