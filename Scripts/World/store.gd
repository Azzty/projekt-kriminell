extends Node2D

@onready var counter: Area2D = $Counter
@onready var counter_collisionshape: CollisionShape2D = $Counter/Counter_shape

@export var item_move_script: Script
@export var sold_particle_effect: GPUParticles2D

var customer: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_node("Customer").customer_leaving.connect(customer_left)
	customer = get_node("Customer").duplicate()
	for item_data: Object in GameState.inventory:
		var texture := CompressedTexture2D.new()
		var big_file_path: String = get_bigger_texture_version(item_data.texture.resource_path)
		
		# Change to larger texture version if exists
		if FileAccess.file_exists(big_file_path):
			texture = load(big_file_path)
		else:
			texture = item_data.texture
		
		var item := Sprite2D.new()
		item.texture = texture
		
		var counterRect = counter_collisionshape.shape.get_rect()
		
		# Random position on counter (divided by 3 instead of 2 for padding)
		item.position = Vector2(counterRect.get_center() + Vector2(randf_range(-counterRect.size.x/3, counterRect.size.x/3), randf_range(-counterRect.size.y/3, counterRect.size.y/3)))
		item.z_index = 2
		item.rotate(randf_range(-PI, PI))
		item.scale = Vector2(2,2)
		item.set_script(item_move_script)
		item.bounds_cshape = get_node("Counter/Counter_shape")
		item.customer_drop_shape = get_node("Customer/CustomerDropArea/CustomerDropShape")
		item.customer = get_node("Customer")
		item.sold_particle_effect = sold_particle_effect
		counter.add_child(item)
		item.name = item_data.name
		item.set_meta("item_properties", item_data)

func customer_left():
	add_child(customer)
	customer = customer.duplicate()

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
