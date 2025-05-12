extends Panel

@onready var cursor := $%Cursor
@onready var track := $%Track
@onready var green_part := $%GreenPart
@onready var points_label := $%PointsLabel

@export var speed := 50.0:
	set(value):
		if value < 100 and value > 30:
			speed = value
		else:
			print("speed capped")
@export var required_wins := 4

signal minigame_won
signal minigame_lost

var original_speed
var points := 0:
	set(value):
		points = value
		_update_points_label()
var track_rect: Rect2
var green_start_position: Vector2

var direction := 1
var can_move := true

func _ready() -> void:
	original_speed = speed
	_update_points_label()
	track_rect = track.get_rect()
	green_start_position = green_part.position
	_randomize_green_part_position()
	
	#connect("hit_green_part", _on_green_part_hit)

func _process(delta: float) -> void:
	if not can_move: return
	var position_offset = speed * direction * delta
	if abs(cursor.position.x + position_offset) > track_rect.size.x and direction == 1 or cursor.position.x <= 0 and direction == -1:
		direction *= -1
	cursor.position.x += position_offset

func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("spacebar"): return
	var sucess := false
	
	# Slightly increase size to show that user clicked
	cursor.size += Vector2(0, 4)
	cursor.position -= Vector2(0, 2)
	can_move = false
	
	# Check if hit or miss
	if cursor.get_global_rect().intersects(green_part.get_global_rect()):
		sucess = true
		green_part.modulate = Color.LIGHT_GREEN
	if sucess:
		_on_green_part_hit()
	else: _on_green_part_missed()
	
	# Wait for dramatic effect
	await get_tree().create_timer(0.2).timeout
	green_part.modulate = Color.GREEN
	if points >= required_wins:
		minigame_won.emit()
		queue_free()
	
	# Back to normal
	_randomize_green_part_position()
	cursor.size -= Vector2(0, 4)
	cursor.position += Vector2(0, 2)
	can_move = true

func _randomize_green_part_position() -> void:
	green_part.position = green_start_position
	green_part.position += 0.5 * Vector2(randf_range(-track_rect.size.x, track_rect.size.x), 0)

func _on_green_part_hit() -> void:
	points += 1
	speed *= 1.1

func _on_green_part_missed() -> void:
	points = 0
	speed = original_speed

func _on_x_button_pressed() -> void:
	queue_free()

func _update_points_label() -> void:
	points_label.text = "Pins: " + str(points) + "/" + str(required_wins)

func _on_spacebar_button_pressed() -> void:
	var event = InputEventAction.new()
	event.action = "spacebar"
	event.pressed = true
	Input.parse_input_event(event) # Pretend that you pressed space

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE: minigame_lost.emit()
