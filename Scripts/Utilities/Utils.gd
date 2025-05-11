extends Node

## Returns a file path that is the same path but with a _big suffix to the file name
## Used to get more detailed versions of sprites
func get_bigger_texture_version(resource_path:String):
	# Get path and file name
	var path := resource_path.rsplit("/", false, 1)
	var item_texture_path := path[0]
	var item_texture_name := path[1]

	# Construct new path
	var base_path = item_texture_path + "/"
	var file_name = item_texture_name.split(".", false)[0]
	var file_extension = item_texture_name.split(".", false)[1]
	var big_file_path: String = base_path + file_name + "_big." + file_extension
	
	return big_file_path

## Returns a rect in [b]global[/b] space for the given animated sprite
func get_animated_sprite_rect(sprite: AnimatedSprite2D) -> Rect2:
	if not sprite.sprite_frames or not sprite.animation:
		return Rect2() # Return empty if no frames/animation
	
	# Get current frame texture (returns null if no frame)
	var frame_texture = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
	if not frame_texture:
		return Rect2()
	
	var texture_size = frame_texture.get_size()
	var rect_position = sprite.global_position - (texture_size * sprite.scale * 0.5)
	var rect_size = texture_size * sprite.scale
	
	return Rect2(rect_position, rect_size)

## Returns a rect in [b]global[/b] space for the given sprite
func get_sprite_rect(sprite: Sprite2D) -> Rect2:
	if not sprite.texture:
		return Rect2() # Return empty rect if no texture
	
	var texture_size = sprite.texture.get_size()
	var rect_position = sprite.global_position - (texture_size * sprite.scale * 0.5)
	var rect_size = texture_size * sprite.scale
	return Rect2(rect_position, rect_size)

## Walks up the ancestry and finds the first ancestor of a given class
func find_first_parent_of_class(node:Node, class_type: String):
	var parent = node.get_parent()
	if parent:
		if parent.get_class() == class_type:
			return parent
		else:
			find_first_parent_of_class(parent, class_type)
	else:
		return null
