extends Node

## Returns a file path that is the same path but with a _big suffix to the file name
## Used to get more detailed versions of sprites
func get_bigger_texture_version(resource_path: String) -> String:
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

## Like get_bigger_texture version but returns the actual texture instead of name
func get_bigger_texture_as_texture(item_data) -> Texture:
	var texture := CompressedTexture2D.new()
	var big_file_path: String = get_bigger_texture_version(item_data.texture.resource_path)

	# Change to larger texture version if exists
	if FileAccess.file_exists(big_file_path):
		texture = load(big_file_path)
	else:
		texture = item_data.texture
	return texture

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

## Walks up the ancestry and finds the first ancestor of a given class.
## If exact_match is true it will only return parents with the same class_name, for example:
## [codeblock]
## var parent = Sprite2D.new()
## var child = Sprite2D.new()
## parent.add_child(child)
## print(find_first_parent_of_class(child, Sprite2D, false) # returns parent
## print(find_first_parent_of_class(child, Sprite2D, true) # returns parent
## print(find_first_parent_of_class(child, Node, false) # returns parent
## print(find_first_parent_of_class(child, Node, true) # returns null
## [/codeblock]
func find_first_parent_of_class(node: Node, class_type: String, exact_match: bool = false):
	var parent = node.get_parent()
	if parent:
		if exact_match:
			if parent.get_class() == class_type:
				return parent
			else:
				find_first_parent_of_class(parent, class_type, exact_match)
		else:
			if parent.is_class(class_type):
				return parent
			else:
				find_first_parent_of_class(parent, class_type, exact_match)
	else:
		return null

## Walks down the tree and returns the first child of the given class.
## If exact_match is true it will only return parents with the same class_name.
## If recusive is true it will check all descendants.
## [codeblock]
## var parent = CharacterBody2D.new()
## var child = Sprite2D.new()
## var child2 = Camera2D.new()
## child.add_child(child2)
## parent.add_child(child)
## print(find_first_child_of_class(parent, Node, false, true) # returns child
## print(find_first_child_of_class(parent, Node, true, true) # returns null
## print(find_first_child_of_class(parent, Camera2D, false, true) # returns child2
## print(find_first_child_of_class(parent, Camera2D, true, false) # returns null
## [/codeblock]
func find_first_child_of_class(node: Node, class_type: String, exact_match: bool = false, recursive: bool = false):
	if not node: return
	var children = node.get_children()
	for child in children:
		if exact_match:
			if child.get_class() == class_type:
				return child
		else:
			if child.is_class(class_type):
				return child
	if recursive:
		for child in children:
			var result = find_first_child_of_class(child, class_type, exact_match, recursive)
			if result: return result

## Picks a random key from a dictionary where values are weights (probabilities).
## Example: {"A": 0.1, "B": 0.3, "C": 0.6}
func pick_weighted_random(weighted_dict: Dictionary) -> Variant:
	var total_weight := 0.0
	for weight in weighted_dict.values():
		total_weight += float(weight)
	if total_weight == 0.0:
		return null

	var rand := randf() * total_weight
	var cumulative := 0.0
	for key in weighted_dict.keys():
		cumulative += float(weighted_dict[key])
		if rand < cumulative:
			return key
	return null