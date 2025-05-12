extends StaticBody2D

signal unlocked_signal

@onready var door := $%Door
@onready var pin_joint := $%PinJoint2D
@onready var spring_joint := $%DampedSpringJoint2D
@onready var hold_button := $%HoldButton

@export var required_wins := 4
@export var speed := 50.0

func _ready() -> void:
	hold_button.rotation -= rotation
	var sprite_size := Utilities.get_sprite_rect(door.find_child("DoorSprite")).size
	hold_button.global_position = global_position - Vector2(sprite_size.x * 0.25, 0)

func _on_hold_button_activated() -> void:
	GuiManager.spawn_lockpick_minigame(unlocked_signal, required_wins, speed)

func _on_unlocked_signal() -> void:
	door.freeze = false
	hold_button.queue_free()
