extends Panel

@onready var cursor := $%Cursor
@onready var track := $%Track
@onready var green_part := $%GreenPart

@export var SPEED := 50

var track_rect: Rect2
var direction := 1

var can_move := true

func _ready() -> void:
	track_rect = track.get_rect()

func _process(delta: float) -> void:
	if not can_move: return
	var position_offset = SPEED * direction * delta
	if abs(cursor.position.x + position_offset) > track_rect.size.x and direction == 1 or cursor.position.x <= 0 and direction == -1:
		direction *= -1
	cursor.position.x += position_offset

func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("spacebar"): return
	var sucess := false
	
	cursor.size += Vector2(0, 4)
	cursor.position -= Vector2(0, 2)
	can_move = false
	if cursor.get_global_rect().intersects(green_part.get_global_rect()):
		sucess = true
		green_part.modulate = Color.LIGHT_GREEN
	await get_tree().create_timer(0.2).timeout
	if sucess:
		green_part.modulate = Color.GREEN
	cursor.size -= Vector2(0, 4)
	cursor.position += Vector2(0, 2)
	can_move = true

func _on_x_button_pressed() -> void:
	queue_free()
