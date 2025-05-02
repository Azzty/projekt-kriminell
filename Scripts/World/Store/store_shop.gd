extends Node2D

@onready var counter: Area2D = $Counter
@onready var counter_collisionshape: CollisionShape2D = $Counter/Counter_shape

@export var item_move_script: Script
@export var sold_particle_effect: GPUParticles2D
@export var customer_drop_shape: CollisionShape2D

var current_customer: Node
var customer_template: PackedScene = preload("res://Scenes/NPCS/customer.tscn") # A blank customer with no soul
var customer_properties = {} # Save important properties from the customer here (in _ready)
var spawned_items := []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_customer = get_node("Customer")
	customer_properties = {
		"position": current_customer.position,
		"z_index": current_customer.z_index
	}
	current_customer.customer_leaving.connect(customer_left)
	for item_data: Object in GameState.inventory:
		var texture := CompressedTexture2D.new()
		var big_file_path: String = Utilities.get_bigger_texture_version(item_data.texture.resource_path)
		
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
		item.customer_drop_shape = customer_drop_shape
		update_item_customer(item)
		item.sold_particle_effect = sold_particle_effect
		counter.add_child(item)
		item.name = item_data.name
		item.set_meta("item_properties", item_data)
		item.item_sold.connect(_on_item_sold.bind(item))
		spawned_items.append(item)

func update_item_customer(item: Sprite2D):
	item.customer = current_customer
	item.customer_requested_tags = current_customer.requested_item_tags

func customer_left():
	current_customer = customer_template.instantiate()
	add_child(current_customer)
	for property in customer_properties:
		current_customer[property] = customer_properties[property]
	current_customer.customer_leaving.connect(customer_left)
	for item: Sprite2D in spawned_items:
		update_item_customer(item)

func _on_item_sold(item: Sprite2D):
	spawned_items.erase(item)
