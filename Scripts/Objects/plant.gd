@tool
extends Sprite2D

const COL_COUNT := 3 # Amount of columns in spritesheet (starting from 0)
const ROW_COUNT := 0 # Amount of rows in spritesheet

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	region_enabled = true
	var plant_texture_postion = Vector2(randi_range(0, COL_COUNT) * 16, randi_range(0, ROW_COUNT) * 16)
	region_rect = Rect2(plant_texture_postion, Vector2(16, 16))
