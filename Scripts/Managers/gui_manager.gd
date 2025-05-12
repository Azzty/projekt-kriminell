extends Node

const _lockpick_scene := preload("res://Scenes/UI Elements/lockpick_minigame.tscn")

var gui: CanvasLayer

func spawn_lockpick_minigame(unlocked_signal: Signal, required_wins := 4, initial_speed := 50):
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
