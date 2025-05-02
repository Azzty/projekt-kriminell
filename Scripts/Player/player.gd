extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 150.0
const JUMP_VELOCITY = -400.0
const PUSH_FORCE = 80.0

var _following_items := []
var item_offset_length = 8 # Distance between player and items

var is_picking_up_item := false
var last_picked_up_item_position: Vector2 = Vector2.ZERO

func _ready():
	add_to_group("player")
	GameState.connect("item_added_to_inventory", _add_following_item)
	for item_data: Object in GameState.inventory:
		var item = Sprite2D.new()
		item.texture = item_data.texture
		add_child(item)
		item.name = item_data.name
		_add_following_item(item)

func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	var directionX := Input.get_axis("move_left", "move_right")
	var directionY := Input.get_axis("move_up", "move_down")
	
	# Handle movement in X and Y direction
	if directionX:
		velocity.x = directionX * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if directionY:
		velocity.y = directionY * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
	velocity = velocity.normalized() * SPEED
	
	look_at(position + velocity)
	if velocity.length() > 0: rotate(0.5 * PI)
	
	# Flip sprite if moving to right
	if directionX > 0:
		animated_sprite.flip_h = false
	elif directionX < 0:
		animated_sprite.flip_h = true
	
	# Play correct move animation
	if not is_picking_up_item:
		if directionX or directionY:
			animated_sprite.play("Run")
		else:
			animated_sprite.play("Idle")
	else:
		look_at(last_picked_up_item_position)
		rotate(0.5 * PI)
		animated_sprite.play("Pickup")
		
	move_and_slide()
	
	# Apply forces to collisions
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			c.get_collider().apply_central_impulse(-c.get_normal() * PUSH_FORCE)
	
	# Move following items to the player
	for index in _following_items.size():
		var item: Sprite2D = _following_items[index]
		var rotateIncrement = (2 * PI) / _following_items.size()
		var offsetVector = Vector2(0, item_offset_length).rotated(index * rotateIncrement)
		
		# This is where we want to be at
		var targetPosition = global_position + offsetVector
		
		# This is how were gonna move
		var deltaPosition = targetPosition - item.global_position
		
		# Skip if too close
		if deltaPosition.length() < 5: continue
		
		# Move and look at player
		item.global_position += deltaPosition.normalized() * SPEED * delta * 0.95
		item.look_at(position)
	
	var closest_button = GameState.get_closest_button_to_player()
	for button in GameState.buttons_in_range:
		button.visible = false
		if button == closest_button: button.visible = true

func add_item_to_inventory(item: Sprite2D) -> void:
	GameState.add_item_to_inventory(item)

func remove_item_from_inventory(item: Sprite2D) -> void:
	GameState.remove_item_from_inventory(item)

func _add_following_item(item: Sprite2D):
	is_picking_up_item = true
	last_picked_up_item_position = item.global_position
	
	var item_name = item.name
	if item.get_parent() != self:
		item.reparent(self)
	item.name = item_name # Rename to fix name conflicts
	_following_items.append(item)
	item_offset_length = 8 + _following_items.size() * 2


func _on_animated_sprite_2d_animation_looped() -> void:
	if animated_sprite.animation == "Pickup": is_picking_up_item = false
