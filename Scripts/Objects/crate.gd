extends Sprite2D

const hold_button := preload("res://Scenes/UI Elements/hold_button.tscn")
const broken_texture := preload("res://Assets/sprites/broken_crate.png")

## Item: Probability
@export var droppable_items: Dictionary[String, float] = {
	"Crowbar": 5,
	"Revolver": 1
}
@export var hp := 100

@warning_ignore("unused_signal")
signal take_damage(damage: int)

func _on_take_damage(damage: int) -> void:
	hp -= damage
	shake_crate()
	if hp <= 0: destroy_crate()

func shake_crate():
	var original_position := position
	var shake_amount := 1
	var shake_times := 6
	var shake_time := 0.03

	for i in shake_times:
		var shake_offset := Vector2(randf_range(-shake_amount, shake_amount), randf_range(-shake_amount, shake_amount))
		position = original_position + shake_offset
		await get_tree().create_timer(shake_time).timeout
	position = original_position

func destroy_crate():
	var item_name = Utilities.pick_weighted_random(droppable_items)
	var item_data = GameItem.new(item_name)
	var crate_rect := get_rect()

	# Create item
	var item := Sprite2D.new()
	item.texture = item_data.texture
	item.rotate(randf_range(0, PI))
	item.z_index = 2
	add_sibling(item)
	item.set_meta("item_properties", item_data)
	item.global_position = to_global(crate_rect.get_center())
	item.name = item_data.name

	var button = hold_button.instantiate()
	button.prompt_text = "Pick up " + str(item_name)
	item.add_child.call_deferred(button)
	button.top_level = true
	button.position = item.global_position - Vector2(0, item.get_rect().size.y)
	button.activated.connect(_button_pressed.bind(item, button))

	texture = broken_texture
	process_mode = Node.PROCESS_MODE_DISABLED

func _button_pressed(item: Sprite2D, button: Button) -> void:
	if not GameState.add_item_to_held_items(item):
		return
	for child in item.get_children():
		child.queue_free()
	button.activated.disconnect(_button_pressed)
	button.queue_free()
