extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var _following_items := []

func _physics_process(_delta: float) -> void:
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
	
	for item: Sprite2D in _following_items:
		item.look_at(position)
		item.position += (position - item.position).normalized() * SPEED

func add_item_to_inventory(item: Sprite2D) -> void:
	GameManager.inventory.append(item)

func remove_item_from_inventory(item: Sprite2D) -> void:
	GameManager.inventory.erase(item)

func _add_following_item(item: Sprite2D) -> void:
	item.position = position
	GameManager.append(item)
