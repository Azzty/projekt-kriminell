extends Node

const _lockpick_scene := preload("res://Scenes/UI Elements/lockpick_minigame.tscn")
const _mission_failed_scene := preload("res://Scenes/UI Elements/mission_failed_screen.tscn")

var ui_locked := false
var gui: CanvasLayer

var _active_extra_scenes := []

signal timer_value_changed(new_time: float)

func clear_extra_ui_elements():
	if not gui: return
	for scene in _active_extra_scenes:
		if scene: scene.queue_free()
	_active_extra_scenes.clear()

func spawn_lockpick_minigame(unlocked_signal: Signal, required_wins := 4, initial_speed := 50.0):
	if not gui: return

	get_tree().paused = true
	var scene = _lockpick_scene.instantiate()
	scene.required_wins = required_wins
	scene.speed = initial_speed
	gui.add_child(scene)
	scene.global_position = get_viewport().get_visible_rect().get_center()
	scene.global_position -= scene.get_rect().size * 0.5

	scene.minigame_won.connect(func ():
		get_tree().paused = false
		unlocked_signal.emit()
		)
	scene.minigame_lost.connect(func ():
		get_tree().paused = false
		)
	_active_extra_scenes.append(scene)

func spawn_mission_failed_screen():
	if not gui: return
	clear_extra_ui_elements()
	var scene := _mission_failed_scene.instantiate()
	gui.add_child(scene)
	scene.find_child("RetryButton").grab_focus()
	_active_extra_scenes.append(scene)

func override_start_gui():
	if not gui: return
	gui.start_screen_override.emit()

func set_timer_visibility(value: bool):
	if not gui: return
	gui.set_timer_visibility(value)
