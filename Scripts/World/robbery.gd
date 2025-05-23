extends Node

@export var enabled := true

@onready var trouble_intro = $%TroubleIntro
@onready var trouble_main = $%TroubleMain
@onready var mission_failed = $%MissionFailed
@onready var player = $%Player
@onready var intro_animation = $%IntroAnimation
@onready var robbery_timer = $%RobberyTimer
@onready var sirens = $%Sirens

var camera_position_tween: Tween
var camera_zoom_tween: Tween

func _ready() -> void:
	GuiManager.set_timer_visibility(false)
	robbery_timer.timeout.connect(lose_robbery)

	if not enabled:
		player.global_position = Vector2(-20, 150)
		robbery_timer.start()
		GuiManager.set_timer_visibility(true)
		return

	$CarStart.play()
	await get_tree().create_timer(0.5).timeout

	GuiManager.fade_in()
	trouble_intro.play()
	player.set_physics_process(false)

	var camera: Camera2D = player.find_child("Camera2D")

	camera.global_position = Vector2(200, -150)
	camera.zoom = Vector2(4, 4)
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
	trouble_main.play(60.0 - robbery_timer.wait_time)

	robbery_timer.start()
	GuiManager.set_timer_visibility(true)

	await get_tree().create_timer(0.7).timeout
	player.global_position = Vector2(-20, 150)
	player.set_physics_process(true)
	camera.position = Vector2.ZERO
	camera.align()

func lose_robbery():
	get_tree().paused = false
	GuiManager.ui_locked = true
	player.set_physics_process(false)
	player.animated_sprite.play("Idle")

	var camera: Camera2D = player.find_child("Camera2D")
	camera_position_tween = get_tree().create_tween()
	camera_position_tween.set_loops(-1)
	camera_position_tween.set_ease(Tween.EASE_IN_OUT)
	camera_position_tween.set_trans(Tween.TRANS_CIRC)
	camera_position_tween.tween_property(camera, "position", Vector2(10, 10), 1.49)
	camera_position_tween.tween_property(camera, "position", Vector2(-10, -10), 1.49)
	camera_position_tween.tween_property(camera, "position", Vector2(0, -10), 1.49)
	camera_position_tween.tween_property(camera, "position", Vector2(-10, 0), 1.49)

	camera_zoom_tween = get_tree().create_tween()
	camera_zoom_tween.tween_property(camera, "zoom", Vector2(2, 2), 6)

	mission_failed.play()
	sirens.play()
	camera_position_tween.play()
	camera_zoom_tween.play()

	GuiManager.spawn_mission_failed_screen()

#func win_robbery():
	#GameState.change_scene.emit("res://Scenes/Levels/store.tscn")

func _process(_delta: float) -> void:
	GuiManager.timer_value_changed.emit(robbery_timer.time_left)

func _exit_tree():
	if camera_position_tween:
		camera_position_tween.stop()
	if camera_zoom_tween:
		camera_zoom_tween.stop()

func _on_van_exfiltrated() -> void:
	robbery_timer.stop()
	if GuiManager.gui: GuiManager.gui.set_timer_visibility(false)
