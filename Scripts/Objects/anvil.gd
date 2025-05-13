extends Sprite2D

@onready var anvil_sprite_bounds := Utilities.get_sprite_rect(get_node("."))

var items_in_drop_area := []

var is_crafting := false

# Highlight when hovering
func _process(delta: float) -> void:
	if is_crafting: return
	if anvil_sprite_bounds.has_point(get_global_mouse_position()):
		self_modulate.r = 1.2
		self_modulate.g = 1.2
		self_modulate.b = 1.2
	else:
		self_modulate.r = 1.0
		self_modulate.g = 1.0
		self_modulate.b = 1.0
