extends Sprite2D

@export var bounds_cshape: CollisionShape2D
@export var customer_drop_shape: CollisionShape2D
@export var customer: Node
@export var target_position: Vector2

@onready var customer_requested_tags: Array[String]
@onready var remove_effect = $SparkleExplosion

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
		var rect = bounds_cshape.shape.get_rect()
		rect.position = bounds_cshape.to_global(rect.position) # Convert position to global space
		
		# If not released inside bounds, set grab_position inside bounds
		if not rect.has_point(grab_position):
			grab_position = rect.get_center()
			grab_position += Vector2(
				0.3 * randi_range(-rect.size.x, rect.size.x),
				0.3 * randi_range(-rect.size.y, rect.size.y)
				)
		
		# Go to the grab position
		#print("Going to: ", grab_position)
		global_position = global_position.lerp(grab_position, 0.1)
		if global_position.distance_to(grab_position) < 1.0: released_out_of_bounds = false
	# Move item towards mouse
	acceleration = delta_position * STIFFNESS
	velocity += acceleration
	velocity *= dampning
	rotate(2 * delta * (velocity.x))
	global_position += velocity * SPEED * delta

# Keep within bounds and move back to grabbed spot if released in air
func _keep_within_bounds():
	if holding_mouse0: return
	if not bounds_cshape: return
	
	## This is the problem, ts is in its own local space, need to convert to our local space
	# relative to parent, which is the same? Could be different problem?
	var bounds := bounds_cshape.shape.get_rect()
	bounds.position = bounds_cshape.to_global(bounds.position) # Convert position to global space
	
	# Check if out of bounds
	var outX = global_position.x < bounds.position.x or global_position.x > bounds.end.x
	var outY = global_position.y < bounds.position.y or global_position.y > bounds.end.y
	
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
	var sound_effect = AudioStreamPlayer.new()
	sound_effect.volume_db = -8.0
	sound_effect.stream = PURCHASE_SOUND
	get_parent().add_child(sound_effect)
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

	if get_rect().has_point(get_local_mouse_position()):
		holding_mouse0 = true
		grab_position = get_global_mouse_position()
		get_viewport().set_input_as_handled()

func _on_texture_changed() -> void:
	var shape: RectangleShape2D = $%CollisionShape2D.shape
	shape.size = get_rect().size

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		remove_effect.emitting = true
		remove_effect.reparent(get_parent())
		remove_effect.global_position = global_position
