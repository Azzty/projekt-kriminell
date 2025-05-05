extends Sprite2D

@export var bounds_cshape: CollisionShape2D
@export var customer_drop_shape: CollisionShape2D
@export var customer: Node
@export var sold_particle_effect: GPUParticles2D
@export var target_position: Vector2

@onready var customer_requested_tags: Array[String]

const PURCHASE_SOUND = preload("res://Assets/Audio/SFX/purchase.mp3")

signal item_sold(item: Sprite2D)

const SPEED := 20
const STIFFNESS := 0.06
var dampning := 0.9

var holding_mouse0 = false
var acceleration = Vector2.ZERO
var velocity = Vector2.ZERO
var delta_position = Vector2.ZERO
var grab_position: Vector2

var isOutOfBounds = false
var released_out_of_bounds = false

func _ready() -> void:
	if customer: customer_requested_tags = customer.requested_item_tags

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	delta_position = Vector2.ZERO
	
	if holding_mouse0:
		dampning = 0.9
		delta_position = (get_global_mouse_position() - global_position)
	else:
		dampning = 0.99
	
	# If out of bounds happened on this frame, bounce back
	_keep_within_bounds()
	
	if holding_mouse0:
		released_out_of_bounds = false
	if released_out_of_bounds:
		print("Grab position out of bounds")
		var rect = bounds_cshape.shape.get_rect()
		
		if not rect.has_point(grab_position):
			grab_position = Vector2(
				0.3 * randi_range(-rect.size.x, rect.size.x),
				0.3 * randi_range(-rect.size.y, rect.size.y)
				)
		
		print("Going to: ", grab_position)
		position = position.lerp(grab_position, 0.1)
		if position.distance_to(grab_position) < 1.0: released_out_of_bounds = false
	# Move item towards mouse
	acceleration = delta_position * STIFFNESS
	velocity += acceleration
	velocity *= dampning
	rotate(2 * delta * (velocity.x))
	global_position += velocity * SPEED * delta

# Keep within bounds and move back to grabbed spot if released in air
func _keep_within_bounds():
	if holding_mouse0: return
	
	var bounds = bounds_cshape.shape.get_rect()
	# Check if out of bounds
	
	var outX = position.x < bounds.position.x or position.x > bounds.end.x
	var outY = position.y < bounds.position.y or position.y > bounds.end.y
	
	# If released out of bounds
	if Input.is_action_just_released("left_click") and (outX or outY):
		released_out_of_bounds = true
		velocity = Vector2.ZERO
		if not customer_drop_shape:	return
		var local_mouse_pos = customer_drop_shape.to_local(get_global_mouse_position())
		
		# If dropped on customer
		if customer_drop_shape.shape.get_rect().has_point(local_mouse_pos):
			_sell_item()
			
	# If not yet out of bounds then reverse velocity (avoids getting stuck on edge)
	if outX and not isOutOfBounds:
		velocity.x *= -0.8
	if outY and not isOutOfBounds:
		velocity.y *= -0.8

	if (outX or outY): # If out of bounds
		isOutOfBounds = true
	else: # We are not out of bounds
		isOutOfBounds = false

func _sell_item():
	if customer.recieved_item:
		print("Customer already recieved item!")
		return
	if customer_requested_tags.size() == 0:
		print("No requested items")
		return
	# If requested tags not in item tags, skip
	for tag in customer_requested_tags:
		if not tag in get_meta("item_properties").tags:
			print(tag, " not in ", get_meta("item_properties").tags)
			customer.state = customer.States.ITEM_GIVEN_INCORRECT
			return
	GameState.money += get_meta("item_properties").value
	GameState.remove_item_from_inventory(self)
	var effect = sold_particle_effect.duplicate()
	effect.emitting = true
	add_sibling(effect)
	effect.global_position = global_position
	var sound_effect = AudioStreamPlayer.new()
	sound_effect.volume_db = -8.0
	sound_effect.stream = PURCHASE_SOUND
	effect.add_child(sound_effect)
	sound_effect.play()
	item_sold.emit()
	customer.state = customer.States.ITEM_GIVEN_CORRECT
	queue_free()

# Set holding_mouse0 to true if clicked on item
func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton: return
	if event.button_index != MOUSE_BUTTON_LEFT: return
	if not event.is_pressed():
		holding_mouse0 = false
		return

	if abs(get_global_mouse_position() - global_position) < get_rect().size:
		holding_mouse0 = true
		grab_position = get_global_mouse_position()
		get_viewport().set_input_as_handled()

func _on_texture_changed() -> void:
	var shape: RectangleShape2D = $%CollisionShape2D.shape
	shape.size = get_rect().size
