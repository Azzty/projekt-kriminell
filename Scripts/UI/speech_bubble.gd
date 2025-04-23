extends Panel

const TEXT_SPEED = 25.0 # ms / letter

signal char_name_changed
signal text_changed
signal user_clicked
signal finished_writing

var writing_id = 0
var fade_in_playing = false

@export var char_name: String = "NAME":
	set(value):
		if char_name != value:
			char_name = value
			char_name_changed.emit()
@export var text: String = "SAMPLE TEXT":
	set(value):
		if text != value:
			text = value
			text_changed.emit()

@onready var character_name_label: Label = $CharacterName
@onready var speech_label: Label = $Speech

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	modulate = Color.TRANSPARENT
	char_name_changed.connect(_update_textbox)
	text_changed.connect(_update_textbox)
	
	character_name_label.text = char_name
	speech_label.text = text

# Updates the text in the labels
func _update_textbox():
	character_name_label.text = char_name
	if speech_label.text == text: return
	write_text(text, true)

func write_text(new_text: String, clear: bool = true):
	writing_id += 1 # New text = new ID
	var local_id = writing_id

	if clear:
		speech_label.text = ""
	var current_text := speech_label.text
	if not current_text.ends_with("\n") and current_text.length() > 0:
		current_text += "\n"


	for letter in new_text:
		# If ID is outdated, stop writing
		if local_id != writing_id:
			return
		await get_tree().create_timer(TEXT_SPEED / 1000.0).timeout

		current_text += letter
		speech_label.text = current_text
	
	finished_writing.emit()

func _on_button_pressed() -> void:
	user_clicked.emit()
	fade_in()

# Fades in the dialouge box
func fade_in():
	if fade_in_playing: return
	fade_in_playing = true
	modulate = Color.TRANSPARENT
	var tween = self.create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 1)
	tween.connect("finished", func(): fade_in_playing = false)
	tween.play()
	return tween

func fade_out():
	modulate = self.modulate
	var tween = self.create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 1)
	tween.play()
	return tween
