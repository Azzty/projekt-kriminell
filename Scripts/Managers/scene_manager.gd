extends Node

var current_scene: Node # Rotnoden för scenen

@onready var game_node = get_node("/root/Game")  # Hitta "Game"-noden

func _ready() -> void:
	GameState.change_scene.connect(handle_scene_changed)

func handle_scene_changed(next_scene_path: String):
	var scene: Node = load(next_scene_path).instantiate()
	game_node.add_child(scene)
	if current_scene: current_scene.queue_free()
	current_scene = scene
