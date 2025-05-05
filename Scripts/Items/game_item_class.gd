# Class for holding and creating data about items in the game
class_name GameItem

var texture: Texture
var name: String
var value: float
var tags: Array

## TODO: Add materials to items, for example: {"iron": 2, "wood": 1}

static var item_data = {
	"Revolver": {
		"tags": ["Weapon", "Gun"],
		"texture": load("res://Assets/sprites/Items/Weapons/Guns/revolver.png"),
		"name": "Revolver",
		"value": 200
	},
	"Crowbar": {
		"tags": ["Weapon", "Melee"],
		"texture": load("res://Assets/sprites/Items/Weapons/Melee/crowbar.png"),
		"name": "Crowbar",
		"value": 100
	},
	"Document": {
		"tags": ["Special", "QuestItem"],
		"texture": load("res://Assets/sprites/Items/Special/document.png"),
		"name": "Document",
		"value": 100
	},
	"Apple": {
		"tags": ["Misc", "Food"],
		"texture": load("res://Assets/sprites/Items/Misc/apple.png"),
		"name": "Apple",
		"value": 5
	}
}

func _init(item_id: String):
	if item_data.has(item_id):
		var data = item_data[item_id]
		texture = data.texture
		name = data.name
		value = data.value
		tags = data.tags
	else:
		print_debug(item_id, " is not a valid item_id")
