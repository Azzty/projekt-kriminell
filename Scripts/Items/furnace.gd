extends AnimatedSprite2D

@onready var drop_cshape := %DropShape

var items_in_drop_area = []

@export var items_in_machine: Array

func _on_area_2d_area_entered(area: Area2D) -> void:
	print("I've been entered 😈😈😈")
	var item: Sprite2D = Utilities.find_first_parent_of_class(area, "Sprite2D")
	if not item.has_meta("item_properties"): return
	
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
			var item_name: String = item.get_meta("item_properties").name
			items_in_machine.append(item_name)
			item.queue_free()
		items_in_drop_area.clear()

## TODO: Make it process finished goods into raw materials
