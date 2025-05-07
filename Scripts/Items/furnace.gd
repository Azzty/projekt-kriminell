extends AnimatedSprite2D

const SMELTING_TIME := 1.0

@onready var drop_cshape := %DropShape

var items_in_drop_area := []
var materials_in_machine := {}
var smelt_queue := []
var is_smelting := false

signal item_smelted

@export var SMELT_EFFICENCY := 0.75 # Yield from smelting items

func _on_area_2d_area_entered(area: Area2D) -> void:
	print("I've been entered 😈😈😈")
	var item: Sprite2D = Utilities.find_first_parent_of_class(area, "Sprite2D")
	if not item.has_meta("item_properties") or not item.is_in_group("shop_items"): return
	
	self_modulate.r = 1.5
	self_modulate.g = 1.5
	self_modulate.b = 1.5
	
	items_in_drop_area.append(item)

func _on_area_2d_area_exited(area: Area2D) -> void:
	var item: Sprite2D = Utilities.find_first_parent_of_class(area, "Sprite2D")
	if not item.has_meta("item_properties"): return
	
	self_modulate.r = 1
	self_modulate.g = 1
	self_modulate.b = 1
	
	items_in_drop_area.erase(item)

func _input(event: InputEvent) -> void:
	if not event is InputEventMouseButton: return
	if event.button_index != MOUSE_BUTTON_LEFT: return
	if event.is_released():
		for item: Sprite2D in items_in_drop_area:
			_add_to_smelt_queue(item)
			item.queue_free()
		items_in_drop_area.clear()

# Smelts materials and add to machine inventory
func _smelt_materials(item_materials: Dictionary) -> void:
	is_smelting = true
	play("active")
	await get_tree().create_timer(SMELTING_TIME).timeout
	for material_name in item_materials:
		var material_amount = item_materials[material_name]
		if not materials_in_machine.has(material_name):
			materials_in_machine[material_name] = 0.0
		materials_in_machine[material_name] += material_amount * SMELT_EFFICENCY
	print("smelted an item")
	is_smelting = false
	play("idle")
	item_smelted.emit()

func smelt_all_items() -> void:
	if is_smelting: await item_smelted # Wait for the furnace to be ready
	
	var item_materials = smelt_queue.pop_front()
	if not item_materials: return
	
	await _smelt_materials(item_materials)
	
	smelt_all_items()

func _add_to_smelt_queue(item) -> void:
	var item_materials: Dictionary = item.get_meta("item_properties").materials
	if not item_materials: return
	smelt_queue.append(item_materials)
	
	if not is_smelting: smelt_all_items()
