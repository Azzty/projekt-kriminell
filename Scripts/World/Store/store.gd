extends Node2D

@onready var shop_node := $Shop
@onready var workshop_node := $Workshop

## TODO: Hide button when reaching edge

var is_switching_scenes := false

func _on_button_to_shop_pressed() -> void:
	const MOVE_AMOUNT = Vector2(300, 0)
	move_scenes(MOVE_AMOUNT)

func _on_button_to_workshop_pressed() -> void:
	const MOVE_AMOUNT = Vector2(-300, 0)
	move_scenes(MOVE_AMOUNT)

func move_scenes(delta_position: Vector2):
	is_switching_scenes = true
	
	# Create a tween to move from one scene to the other
	var move_tween := create_tween()
	move_tween.set_trans(Tween.TRANS_SINE)
	move_tween.set_ease(Tween.EASE_OUT)
	move_tween.set_parallel(true)
	move_tween.tween_property(shop_node, "position", shop_node.position - delta_position, 1.0)
	move_tween.tween_property(workshop_node, "position", workshop_node.position - delta_position, 1.0)
	move_tween.play()
	
	await move_tween.finished
	is_switching_scenes = false

func _input(event: InputEvent) -> void:
	if not is_switching_scenes: return
	if event.is_action("left_click"):
		get_viewport().set_input_as_handled()
