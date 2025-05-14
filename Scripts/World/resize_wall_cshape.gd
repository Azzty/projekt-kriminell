@tool
extends NinePatchRect

var cshape: CollisionShape2D
var wall_part: NinePatchRect

func _ready() -> void:
	resized.connect(_update_cshape)
	_update_cshape()

func _update_cshape():
	cshape = get_node("StaticBody2D/CollisionShape2D")
	wall_part = get_node("NinePatchRect")
	
	if cshape.shape:
		cshape.shape = cshape.shape.duplicate()  # gör unik kopia
	
	var rect = get_global_rect()
	var shape: RectangleShape2D = cshape.shape
	if shape:
		shape.size = rect.size
		cshape.position = rect.size / 2.0
		wall_part.size = rect.size
