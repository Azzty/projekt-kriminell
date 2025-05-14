extends Node2D

@export var item_zone_cshape: CollisionShape2D
@export var item_move_script: Script

@onready var material_shape := $%MaterialCollisionShape

const movable_item_scene = preload("res://Scenes/Objects/Interactable Objects/movable_item.tscn")

## TODO: Change so that it uses the items from shop instead. Also scale is incorrect on items

func _ready() -> void:
	for item_data: Object in GameState.inventory:
		if not ("Resource" in item_data.tags): continue
		var texture := CompressedTexture2D.new()
		var big_file_path: String = Utilities.get_bigger_texture_version(item_data.texture.resource_path)
		
		# Change to larger texture version if exists
		if FileAccess.file_exists(big_file_path):
			texture = load(big_file_path)
		else:
			texture = item_data.texture
		
		var item := movable_item_scene.instantiate()
		item.texture = texture
		
		var zone_rect = material_shape.shape.get_rect()
		
		# Random position on counter (divided by 3 instead of 2 for padding)
		item.position = Vector2(zone_rect.get_center() + Vector2(randf_range(-zone_rect.size.x/3, zone_rect.size.x/3), randf_range(-zone_rect.size.y/3, zone_rect.size.y/3)))
		item.z_index = 2
		item.rotate(randf_range(-PI, PI))
		item.scale = Vector2(2,2)
		item.bounds_cshape = material_shape
		material_shape.add_sibling(item)
		item.name = item_data.name
		item.set_meta("item_properties", item_data)
		item.add_to_group("resource_items")
