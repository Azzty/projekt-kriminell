extends AnimatedSprite2D

const item_template := preload("res://Scenes/Objects/Interactable Objects/movable_item.tscn")

@onready var drop_cshape := %DropShape
@onready var hum_sound_effect := $%HumSoundEffect
@onready var ding_sound_effect := $%DingSoundEffect
@onready var pop_sound_effect := $%PopSoundEffect
@onready var decline_sound_effect := $%DeclineSoundEffect
@onready var recipe_button := $%OptionButton
@onready var furnace_sprite_bounds := Utilities.get_animated_sprite_rect(get_node("."))

var items_in_drop_area := []
var materials_in_machine := {"iron": 10.0}
var smelt_queue := []
var is_smelting := false

signal item_smelted

@export var SMELTING_TIME := 1.0
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
			GameState.remove_item_from_inventory(item)
			item.queue_free()
		items_in_drop_area.clear()
	elif furnace_sprite_bounds.has_point(get_global_mouse_position()):
		dispense_recipe()

func dispense_recipe():
	var recipe: String = recipe_button.get_item_text(recipe_button.selected)
	if not recipes.has(recipe):
		print(recipe, " is not a valid recipe")
		decline_sound_effect.play()
		return
	if not GameItem.item_data.has(recipe):
		print(recipe, " not item in game_item_class.gd!")
		decline_sound_effect.play()
		return
	
	# See if we have all required materals
	for material_name in recipes[recipe]:
		if not materials_in_machine.has(material_name):
			print(material_name, " not in machine!")
			decline_sound_effect.play()
			return
		# Not enough materials
		if materials_in_machine[material_name] - recipes[recipe][material_name] < 0:
			print("Insufficent materails! Needs: ", recipes[recipe][material_name],
			" ", material_name, ". Has: ", materials_in_machine[material_name], " ", material_name)
			decline_sound_effect.play()
			return
	
	# Actually remove the materials now that we know we have them
	for material_name in recipes[recipe]:
		materials_in_machine[material_name] -= recipes[recipe][material_name]
	
	# Create the item
	var result_data := GameItem.new("Iron ingot")
	var result_item := item_template.instantiate()
	result_item.set_meta("item_properties", result_data)
	result_item.bounds_cshape = get_parent().find_child("MaterialZone").find_child("MaterialCollisionShape")
	result_item.texture = result_data.texture
	result_item.scale = Vector2(2,2)
	result_item.bounds_cshape.add_sibling(result_item)
	result_item.global_position = global_position
	result_item.name = result_data.name
	result_item.released_out_of_bounds = true
	result_item.remove_from_group("shop_items")
	result_item.add_to_group("resource_items")
	
	# Play pop sound
	pop_sound_effect.pitch_scale = randf_range(0.9, 1.1) 
	pop_sound_effect.play()

# Smelts materials and add to machine inventory
func _smelt_materials(item_materials: Dictionary) -> void:
	is_smelting = true
	play("active")
	hum_sound_effect.play()
	await get_tree().create_timer(SMELTING_TIME).timeout # Wait for it to smelt
	
	# Add smelted materials to furnace
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

## Repeatedly pops the first item in smelt_queue and smelts it
## until smelt_queue is empty
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

func _process(delta: float) -> void:
	if is_smelting: return
	if furnace_sprite_bounds.has_point(get_global_mouse_position()):
		self_modulate.r = 1.2
		self_modulate.g = 1.2
		self_modulate.b = 1.2
	else:
		self_modulate.r = 1.0
		self_modulate.g = 1.0
		self_modulate.b = 1.0
