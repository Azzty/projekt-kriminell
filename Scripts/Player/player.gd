extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var _following_items := []
var itemOffsetLength = 8

func _ready():
	GameState.connect("item_added_to_inventory", _add_following_item)
	for item_data: Dictionary in GameState.inventory:
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
	
	# Flip sprite if moving to right
	if directionX > 0:
		animated_sprite.flip_h = false
	elif directionX < 0:
		animated_sprite.flip_h = true
	
	# Play correct animation
	if directionX or directionY:
		animated_sprite.play("Run")
	else:
		animated_sprite.play("Idle")
	
	move_and_slide()
	
	for index in _following_items.size():
		var item: Sprite2D = _following_items[index]
		var rotateIncrement = (2 * PI) / _following_items.size()
		var offsetVector = Vector2(0, itemOffsetLength).rotated(index * rotateIncrement)
		
		# This is where we want to be at
		var targetPosition = global_position + offsetVector
		
		# This is how were gonna move
		var deltaPosition = targetPosition - item.global_position
		
		# Skip if too close
		if deltaPosition.length() < 5: continue
		
		# Move and look at player
		item.global_position += deltaPosition.normalized() * SPEED * delta * 0.95
		item.look_at(position)

func add_item_to_inventory(item: Sprite2D) -> void:
	GameState.add_item_to_inventory(item)

func remove_item_from_inventory(item: Sprite2D) -> void:
	GameState.remove_item_from_inventory(item)

func _add_following_item(item: Sprite2D):
	var item_name = item.name
	if item.get_parent() != self:
		item.reparent(self)
	item.name = item_name # Rename to fix name conflicts
	_following_items.append(item)
	itemOffsetLength = 8 + _following_items.size() * 2
