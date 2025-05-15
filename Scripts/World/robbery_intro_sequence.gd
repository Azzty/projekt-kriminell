extends Node

@export var disabled := false

@onready var trouble_intro = $%TroubleIntro
@onready var trouble_main = $%TroubleMain
@onready var player = $%Player
@onready var intro_animation = $%IntroAnimation

func _ready() -> void:
	if disabled:
		player.global_position = Vector2(-20, 150)
		return
	trouble_intro.play()
	player.set_process(false)
	
	var camera: Camera2D = player.find_child("Camera2D")
	
	camera.global_position = Vector2(200, -150)
	camera.zoom = Vector2(4,4)
	var camera_tween_1 = get_tree().create_tween()
	camera_tween_1.tween_property(camera, "global_position", Vector2(0, 520), 5.5)
	camera_tween_1.play()

	await camera_tween_1.finished
	intro_animation.play("entry")
	var camera_tween_2 = get_tree().create_tween()
	camera_tween_2.set_trans(Tween.TRANS_CUBIC)
	camera_tween_2.set_ease(Tween.EASE_IN)
	camera_tween_2.tween_property(camera, "global_position", Vector2(0, 150), 2.2).from_current()
	camera_tween_2.play()
	
	await trouble_intro.finished
	trouble_main.play()
	
	await get_tree().create_timer(0.7).timeout
	player.global_position = Vector2(-20, 150)
	player.set_process(true)
	camera.position = Vector2.ZERO
	camera.align()
