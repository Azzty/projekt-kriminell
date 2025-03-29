extends Area2D

@onready var button: Button = $Button

func _on_body_entered() -> void:
	button.visible = true
	button.disabled = false

func _on_body_exited() -> void:
	button.visible = false
	button.disabled = true

func _on_button_pressed() -> void:
	queue_free()
