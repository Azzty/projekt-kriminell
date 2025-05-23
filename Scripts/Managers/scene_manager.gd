extends Node

var current_scene: Node # Rotnoden för scenen
var game_node: Node # Game node reference

signal scene_switched

## Make current "local" scene child of "Game" node to make scene logic consistent by
## creating a new node named Game if it doenst already exist
func _ready() -> void:
	GameState.change_scene.connect(handle_scene_changed)
	if not get_tree().root.find_child("Game"):
		var scene = Utilities.find_first_child_of_class(get_tree().root, "Node2D")
		if not scene: scene = Utilities.find_first_child_of_class(get_tree().root, "Control")
		if scene: handle_scene_changed(scene.scene_file_path)

## Change current scene into a new scene
func handle_scene_changed(next_scene_path: String, restart_current_scene := false, fade := true):
	if fade:
		await GuiManager.fade_out()
		print("Faded out n shit")

	# Check if "Game" node exists in the scene tree
	game_node = get_tree().root.get_node_or_null("Game")

	# If it doesn't exist, create it and add it to the root
	if not game_node:
		current_scene = Utilities.find_first_child_of_class(get_tree().root, "Node2D")
		if not current_scene: current_scene = Utilities.find_first_child_of_class(get_tree().root, "Control")
		game_node = Node.new()
		game_node.name = "Game"
		get_tree().root.add_child.call_deferred(game_node)

		var GUI: CanvasLayer = load("res://Scenes/Main/gui.tscn").instantiate()
		game_node.add_child.call_deferred(GUI)
		await GUI.ready
		GuiManager.gui = GUI
		GuiManager.override_start_gui()

	if restart_current_scene:
		next_scene_path = current_scene.scene_file_path
		current_scene.queue_free()

	# Load and instantiate the new scene
	var scene: Node = load(next_scene_path).instantiate()
	game_node.add_child.call_deferred(scene)

	# Free the current scene if it exists
	if current_scene:
		current_scene.queue_free()

	# Update current scene reference
	current_scene = scene
	scene_switched.emit()

	if current_scene.name == "Robbery":
		return
	if fade: GuiManager.fade_in()
