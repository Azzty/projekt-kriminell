extends Node2D

@export var item_zone_cshape: CollisionShape2D
@export var item_move_script: Script

@onready var item_zone := $ItemZone

## TODO: Change so that it uses the items from shop instead. Also scale is incorrect on items

#func _ready() -> void:
	#for item_data: Object in GameState.inventory:
			#var texture := CompressedTexture2D.new()
			#var big_file_path: String = Utilities.get_bigger_texture_version(item_data.texture.resource_path)
			#
			## Change to larger texture version if exists
			#if FileAccess.file_exists(big_file_path):
				#texture = load(big_file_path)
			#else:
				#texture = item_data.texture
			#
			#var item := Sprite2D.new()
			#item.texture = texture
			#
			#var item_zone_rect = item_zone_cshape.shape.get_rect()
			#
			## Random position on counter (divided by 3 instead of 2 for padding)
			#item.position = Vector2(item_zone_rect.get_center() + Vector2(randf_range(-item_zone_rect.size.x/3, item_zone_rect.size.x/3), randf_range(-item_zone_rect.size.y/3, item_zone_rect.size.y/3)))
			#item.z_index = 2
			#item.rotate(randf_range(-PI, PI))
			#item.scale = Vector2(2,2)
			#item.set_script(item_move_script)
			#item.bounds_cshape = get_node("ItemZone/Area2D/CollisionShape2D")
			#item_zone.add_child(item)
			#item.name = item_data.name
			#item.set_meta("item_properties", item_data)
