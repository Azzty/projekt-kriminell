extends Node

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
