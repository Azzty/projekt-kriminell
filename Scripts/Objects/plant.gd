@tool
extends Sprite2D

const COL_COUNT := 3
const ROW_COUNT := 0

@export var region_index := -1

func _ready() -> void:
	region_enabled = true
	if region_index == -1:
		# Only randomize once, then store the result
		var col = randi_range(0, COL_COUNT)
		var row = randi_range(0, ROW_COUNT)
		region_index = col + row * (COL_COUNT + 1)
	@warning_ignore("integer_division")
	var plant_texture_position = Vector2((region_index % (COL_COUNT + 1)) * 16, int(region_index / (COL_COUNT + 1)) * 16)
	region_rect = Rect2(plant_texture_position, Vector2(16, 16))
