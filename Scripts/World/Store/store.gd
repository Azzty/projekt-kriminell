extends Node2D

@onready var shop_node := $Shop
@onready var workshop_node := $Workshop

## TODO: Hide button when reaching edge

var is_switching_scenes := false
var current_scene := "shop"

const MOVE_AMOUNT = Vector2(300, 0)

func _on_button_to_shop_pressed() -> void:
	move_scenes(MOVE_AMOUNT)

func _on_button_to_workshop_pressed() -> void:
	move_scenes(-MOVE_AMOUNT)

func move_scenes(delta_position: Vector2):
	is_switching_scenes = true
	var shop_items := get_tree().get_nodes_in_group("shop_items")
	
	for item in shop_items:
		var tween := item.create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CIRC)
		tween.tween_property(item, "position", item.position + Vector2(0, 100), 1.0)
		tween.play()
	
	# Create a tween to move from one scene to the other
	var move_tween := create_tween()
	move_tween.set_trans(Tween.TRANS_SINE)
	move_tween.set_ease(Tween.EASE_OUT)
	move_tween.set_parallel(true)
	move_tween.tween_property(shop_node, "position", shop_node.position - delta_position, 1.0)
	move_tween.tween_property(workshop_node, "position", workshop_node.position - delta_position, 1.0)
	move_tween.play()
	
	await move_tween.finished
	
	for item in shop_items:
		#item.position += Vector2(MOVE_AMOUNT)
		var tween := item.create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CIRC)
		tween.tween_property(item, "position", item.position - Vector2(0, 100), 0.5)
		tween.play()
	
	match shop_node.position:
		Vector2(0,0):
			current_scene = "shop"
			var bounds_cshape = find_child("Counter").find_child("Counter_shape")
			for item in shop_items:
				item.reparent(find_child("Counter"), true)
				item.bounds_cshape = bounds_cshape
				item.isOutOfBounds = true
				item.released_out_of_bounds = true
		-MOVE_AMOUNT:
			current_scene = "workshop"
			var bounds_cshape = find_child("ItemZone", true).find_child("ItemCollisionShape")
			for item in shop_items:
				item.reparent(find_child("ItemZone"), true)
				item.bounds_cshape = bounds_cshape
				item.holding_mouse0 = false
				item.isOutOfBounds = true
				item.released_out_of_bounds = true
		_:
			current_scene = "unknown"
	is_switching_scenes = false

func _input(event: InputEvent) -> void:
	if not is_switching_scenes: return
	if event.is_action("left_click"):
		get_viewport().set_input_as_handled()
