extends Node

const APPLE = preload("res://Assets/sprites/Items/Misc/apple.png")
const CROWBAR = preload("res://Assets/sprites/Items/Weapons/Melee/crowbar.png")
const REVOLVER = preload("res://Assets/sprites/Items/Weapons/Guns/revolver.png")
const DOCUMENT = preload("res://Assets/sprites/Items/Special/document.png")

const ITEMS = [APPLE, CROWBAR, REVOLVER, DOCUMENT]

@onready var shelfshape_0: CollisionShape2D = $Shelf/Shelfshape0
@onready var shelfshape_1: CollisionShape2D = $Shelf/Shelfshape1
const font = preload("res://Assets/fonts/dogicapixel.ttf")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var ranNum = randi_range(1, 4)
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
		
		# Skapa en knapp
		var button := Button.new()
		button.top_level = true
		button.text = "E to pickup"
		button.position = item.global_position - Vector2(0, item.get_rect().size.y)
		button.add_theme_font_override("font", font)
		button.add_theme_font_size_override("font_size", 4)
		button.disabled = false
		button.visible = true
		item.add_child(button)
		
		# Lägger till en ruta för att se om man är tillräckligt nära för att plocka upp sak
		var pickupZone := Area2D.new()
		var pickupZoneCollisionShape := CollisionShape2D.new()
		pickupZoneCollisionShape.shape = CircleShape2D.new()
		pickupZoneCollisionShape.shape.radius = 10
		pickupZoneCollisionShape.position = item.position
		pickupZone.add_child(pickupZoneCollisionShape)
		item.add_child(pickupZone)
		pickupZone.body_entered.connect(_toggle_button_visibility.bind(button))
		pickupZone.body_exited.connect(_toggle_button_visibility.bind(button))

		# Koppla knappen till _button_pressed
		button.pressed.connect(_button_pressed.bind(item, button))
		
		# Lägger till en hotkey så att saker tas upp med E
		var hotkey = InputEventKey.new()
		button.shortcut = Shortcut.new()
		hotkey.keycode = KEY_E
		button.shortcut.events.append(hotkey)

func _button_pressed(item: Sprite2D, button: Button) -> void:
	GameState.add_item_to_inventory(item)
	delete_all_descendants(item)
	button.pressed.disconnect(_button_pressed)
	button.queue_free()

func _toggle_button_visibility(_body: PhysicsBody2D,button: Button) -> void:
	button.disabled = not button.disabled
	button.visible = not button.visible

# Tar bort alla ättlingar från noden
func delete_all_descendants(node: Node):
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
