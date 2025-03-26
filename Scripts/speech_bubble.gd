extends Panel

signal char_name_changed
signal text_changed
signal user_clicked

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
	char_name_changed.connect(_update_textbox)
	text_changed.connect(_update_textbox)
	
	character_name_label.text = char_name
	speech_label.text = text
	_fade_in()

# Updates the text in the labels
func _update_textbox():
	character_name_label.text = char_name
	speech_label.text = text

func _on_button_pressed() -> void:
	user_clicked.emit()
	_fade_in()

# Fades in the dialouge box
func _fade_in():
	if fade_in_playing: return
	fade_in_playing = true
	modulate = Color.TRANSPARENT
	var fade_in = self.create_tween()
	fade_in.tween_property(self, "modulate", Color.WHITE, 1)
	fade_in.connect("finished", func(): fade_in_playing = false)
	fade_in.play()
