extends Node2D

const CHARACTER_RESPONSES: Dictionary = preload("res://Assets/Characters/character_responses.json").data
const CHARACTER_NAMES: Array = preload("res://Assets/Characters/character_names.json").data

@onready var speech_bubble: Panel = $SpeechBubble
@export var requested_item_tags: Array[String] = []
var request: String

signal customer_leaving

# The diffrerent states the customer can be in
enum States {
	GREETING,
	REQUESTING,
	ITEM_GIVEN_CORRECT,
	ITEM_GIVEN_INCORRECT,
	REQUEST_ACCEPTED,
	REQUEST_DENIED,
	WAITING,
	LEAVING
}

var recieved_item = false

@export var state: States:
	set(value):
		state = value
		handle_state_changed()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var char_name = CHARACTER_NAMES[randi() % CHARACTER_NAMES.size()]
	var greetText = CHARACTER_RESPONSES.Default.greeting[randi() % CHARACTER_RESPONSES.Default.greeting.size()]
	await $AnimationPlayer.animation_finished
	speech_bubble.char_name = char_name
	speech_bubble.text = greetText
	await speech_bubble.finished_writing
	await get_tree().create_timer(0.5).timeout
	state = States.REQUESTING

# Handles what the customer does when the state changes
func handle_state_changed():
	match state:
		States.ITEM_GIVEN_CORRECT: # Purchased a requested item
			_write_response(CHARACTER_RESPONSES.Default.item_given_correct)
			recieved_item = true
			await speech_bubble.finished_writing
			await get_tree().create_timer(0.25).timeout
			state = States.LEAVING
		
		States.ITEM_GIVEN_INCORRECT: # Given a non-requested item
			_write_response(CHARACTER_RESPONSES.Default.item_given_incorrect)
			await speech_bubble.finished_writing
			await get_tree().create_timer(0.25).timeout
			state = States.REQUESTING
		
		States.REQUESTING: # Requests an item
			if not request: _make_request()
			_write_response(CHARACTER_RESPONSES.Default["_".join(["request", request.to_lower()])], false)
		
		States.LEAVING: # Recieved all requested items and is now leaving
			_write_response(CHARACTER_RESPONSES.Default.leaving, false)
			await speech_bubble.finished_writing
			await get_tree().create_timer(0.25).timeout
			print("customer is leaving!")
			customer_leaving.emit()
			$AnimationPlayer.play("customer_leave")
			await $AnimationPlayer.animation_finished
			queue_free()

func _write_response(response, clear: bool = true):
	if recieved_item and not state == States.LEAVING: return
	var responseText = response[randi() % response.size()]
	speech_bubble.write_text(responseText, clear)

# Asks for something
func _make_request():
	if request: return
	var choice = ["Heads", "Tails"][randi() % 2]
	if choice == "Heads":
		#_write_response(CHARACTER_RESPONSES.Default.request_gun)
		request = "Gun"
		requested_item_tags.append(request)
	else:
		#_write_response(CHARACTER_RESPONSES.Default.request_melee)
		request = "Melee"
		requested_item_tags.append(request)

# When the user clicks the "Continue" button
func _on_speech_bubble_user_clicked() -> void:
	if state == States.GREETING: # If has greeted then request something
		state = States.REQUESTING
		_make_request()

func show_speech_bubble():
	speech_bubble.fade_in()
