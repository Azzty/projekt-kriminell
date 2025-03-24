extends Area2D

@onready var button: Button = $Button

func _on_body_entered(_body: Node2D) -> void:
	button.visible = true
	button.disabled = false

func _on_body_exited(_body: Node2D) -> void:
	button.visible = false
	button.disabled = true

func _on_button_pressed() -> void:
	queue_free()
