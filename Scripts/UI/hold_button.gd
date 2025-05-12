extends Button

@export var hold_duration: float = 1.0
@export var action_name: String = "interact_e"
@export var prompt_text := "text to be displayed":
	set(value):
		prompt_text = value
		if not label: call_deferred("update_label_text", value)
		else: update_label_text(value)

signal activated

var _time_held := 0.0
var _is_pressed := false
var _is_activated := false

var progress_stylebox: StyleBoxTexture
var border_color = get_theme_stylebox("normal").border_color

@onready var label: Label = get_node("Panel/Label")

func _ready() -> void:
	visible = false
	label.text = prompt_text
	shortcut.events.clear()
	var shortcut_keys := InputMap.action_get_events(action_name)
	shortcut.events.append_array(shortcut_keys)
	
	progress_stylebox = StyleBoxTexture.new()
	var style_texture = GradientTexture2D.new()
	var default_style: StyleBoxFlat = get_theme_stylebox("normal")

	style_texture.fill_from = Vector2(0,1)
	style_texture.fill_to = Vector2(0,1)
	style_texture.gradient = Gradient.new()
	style_texture.gradient.set_color(0, default_style.bg_color)
	style_texture.gradient.set_color(1, default_style.bg_color.lightened(0.3))
	
	progress_stylebox.texture = style_texture
	add_theme_stylebox_override("pressed", progress_stylebox)
	add_theme_stylebox_override("normal", progress_stylebox)

func _process(delta: float) -> void:
	if _is_pressed:
		grab_focus()
		_time_held += delta
		progress_stylebox.texture.fill_from = Vector2(0, 1 - _time_held/hold_duration)
		progress_stylebox.texture.fill_to = Vector2(0, 1 - _time_held/hold_duration + 0.01)
	else:
		_is_activated = false
		_time_held = 0
		progress_stylebox.texture.fill_from = Vector2(0, 1)
		progress_stylebox.texture.fill_to = Vector2(0, 1)
	
	if _time_held >= hold_duration and not _is_activated:
		_is_activated = true
		activated.emit()

# If it doesnt want to draw a border, ill do it myself
func _draw() -> void:
	var rect = Rect2(Vector2.ZERO, size)
	draw_rect(rect, border_color, false, 1, false)

func _on_pressed() -> void:
	_is_pressed = true

func _unhandled_input(event):
	if event.is_action_released(action_name):
		_is_pressed = false

func _on_button_up() -> void:
	_is_pressed = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		GameState.buttons_in_range.append(self)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player": GameState.buttons_in_range.erase(self)
	visible = false

func update_label_text(new_text: String):
	label.text = new_text
