extends Node2D

const CHARACTER_RESPONSES: Dictionary = preload("res://Assets/Characters/character_responses.json").data
const CHARACTER_NAMES: Array = preload("res://Assets/Characters/character_names.json").data

@onready var speech_bubble: Panel = $SpeechBubble

# The diffrerent states the customer can be in
enum States {
	GREETING,
	REQUESTING,
	REQUEST_ACCEPTED,
	REQUEST_DENIED,
	WAITING,
	LEAVING
}

@export var state := States.GREETING

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var char_name = CHARACTER_NAMES[randi() % CHARACTER_NAMES.size()]
	var greetText = CHARACTER_RESPONSES.Default.greeting[randi() % CHARACTER_RESPONSES.Default.greeting.size()]
	speech_bubble.char_name = char_name
	speech_bubble.text = greetText

# Asks for something
func _make_request():
	var choice = ["Heads", "Tails"][randi() % 2]
	if choice == "Heads":
		var request = CHARACTER_RESPONSES.Default.request_gun
		var requestText = request[randi() % request.size()]
		speech_bubble.text = requestText
	else:
		var request = CHARACTER_RESPONSES.Default.request_melee
		var requestText = request[randi() % request.size()]
		speech_bubble.text = requestText

# When the user clicks the "Continue" button
func _on_speech_bubble_user_clicked() -> void:
	if state == States.GREETING: # If has greeted then request something
		state = States.REQUESTING
		_make_request()
	pass # Replace with function body.
