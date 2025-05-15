extends Node

const APPLE = preload("res://Assets/sprites/Items/Misc/apple.png")
const CROWBAR = preload("res://Assets/sprites/Items/Weapons/Melee/crowbar.png")
const REVOLVER = preload("res://Assets/sprites/Items/Weapons/Guns/revolver.png")
const DOCUMENT = preload("res://Assets/sprites/Items/Special/document.png")
## TODO: ^^ Add and reference these items to the inventory singleton or something because
## this looks like it could get very problematic very fast

@export var min_item_amount: int = 0
@export var max_item_amount: int = 2

const ITEMS = [APPLE, CROWBAR, REVOLVER, DOCUMENT]

@onready var shelfshape_0: CollisionShape2D = $Shelf/Shelfshape0
@onready var shelfshape_1: CollisionShape2D = $Shelf/Shelfshape1
const font = preload("res://Assets/fonts/dogicapixel.ttf")

const hold_button := preload("res://Scenes/UI Elements/hold_button.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var ranNum = randi_range(min_item_amount, max_item_amount)
	for i in range(ranNum):
		var shelf: CollisionShape2D = [shelfshape_0, shelfshape_1][randi() % 2]
		var itemTexture: CompressedTexture2D = ITEMS[randi() % ITEMS.size()]
		var shelfRect = shelf.shape.get_rect()
		
		# Skapa ett föremål
		var item := Sprite2D.new()
		item.texture = itemTexture
		item.position = shelfRect.get_center() + Vector2(0, randf_range(-shelfRect.size.y/2, shelfRect.size.y/2))
		item.rotate(randf_range(0, PI))
		item.z_index = 2
		shelf.add_child(item)
		var item_name = itemTexture.resource_path.get_file().get_basename().capitalize()
		var item_data = GameItem.new(item_name)
		item.set_meta("item_properties", item_data)
		item.name = item_name # Do this here so godot adds a suffix instead of breaking name
		
		var button = hold_button.instantiate()
		button.prompt_text = "Pick up " + str(item_name)
		item.add_child(button)
		button.top_level = true
		button.position = item.global_position - Vector2(0, item.get_rect().size.y)
		button.activated.connect(_button_pressed.bind(item, button))

func _button_pressed(item: Sprite2D, button: Button) -> void:
	GameState.add_item_to_held_items(item)
	delete_all_descendants(item)
	button.activated.disconnect(_button_pressed)
	button.queue_free()

func _toggle_button_visibility(_body: PhysicsBody2D,button: Button) -> void:
	button.disabled = not button.disabled
	button.visible = not button.visible

# Tar bort alla ättlingar från noden
func delete_all_descendants(node: Node):
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
