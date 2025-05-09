extends AnimatedSprite2D

const SMELTING_TIME := 1.0
const item_template := preload("res://Scenes/Objects/Interactable Objects/movable_item.tscn")

@onready var drop_cshape := %DropShape
@onready var hum_sound_effect := $%HumSoundEffect
@onready var ding_sound_effect := $%DingSoundEffect
@onready var recipe_button := $%OptionButton

var items_in_drop_area := []
var materials_in_machine := {}
var smelt_queue := []
var is_smelting := false

signal item_smelted

@export var SMELT_EFFICENCY := 0.75 # Yield from smelting items
@export var resource_cshape: CollisionShape2D # Place where resources will be placed

const recipes := {
	"Iron ingot": {"iron": 2},
	"Copper ingot": {"copper": 2}
}

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

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton: return
	if event.button_index != MOUSE_BUTTON_LEFT: return
	if is_smelting: return
	if event.is_released():
		for item: Sprite2D in items_in_drop_area:
			_add_to_smelt_queue(item)
			item.queue_free()
		items_in_drop_area.clear()
	elif Utilities.get_animated_sprite_rect(get_node(".")).has_point(get_global_mouse_position()):
		dispense_recipe()

func dispense_recipe():
	var recipe: String = recipe_button.get_item_text(recipe_button.selected)
	if not recipes.has(recipe):
		print(recipe, " is not a valid recipe")
		return
	if not GameItem.item_data.has(recipe):
		print(recipe, " not item in game_item_class.gd!")
		return
	
	# See if we have all required materals
	for material_name in recipes[recipe]:
		if not materials_in_machine.has(material_name):
			print(material_name, " not in machine!")
			return
		if materials_in_machine[material_name] - recipes[recipe][material_name] < 0:
			print("Insufficent materails! Needs: ", recipes[recipe][material_name],
			" ", material_name, ". Has: ", materials_in_machine[material_name], " ", material_name)
			return
	
	# Actually remove the materials now that we know we have them
	for material_name in recipes[recipe]:
		materials_in_machine[material_name] -= recipes[recipe][material_name]
	
	var result_data := GameItem.new("Iron ingot")
	var result_item := item_template.instantiate()
	result_item.set_meta("item_properties", result_data)
	result_item.bounds_cshape = get_tree().get_first_node_in_group("shop_items").bounds_cshape
	result_item.global_position = global_position
	result_item.texture = result_data.texture
	result_item.scale = Vector2(2,2)
	result_item.bounds_cshape.add_sibling(result_item)
	result_item.name = result_data.name
	result_item.add_to_group("shop_items")

# Smelts materials and add to machine inventory
func _smelt_materials(item_materials: Dictionary) -> void:
	is_smelting = true
	play("active")
	hum_sound_effect.play()
	await get_tree().create_timer(SMELTING_TIME).timeout
	for material_name in item_materials:
		var material_amount = item_materials[material_name]
		if not materials_in_machine.has(material_name):
			materials_in_machine[material_name] = 0.0
		materials_in_machine[material_name] += material_amount * SMELT_EFFICENCY
	print("smelted an item")
	is_smelting = false
	play("idle")
	hum_sound_effect.stop()
	ding_sound_effect.play()
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
