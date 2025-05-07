# Class for holding and creating data about items in the game
class_name GameItem

var texture: Texture
var name: String
var value: float
var tags: Array
var materials: Dictionary

static var item_data = {
	"Revolver": {
		"tags": ["Weapon", "Gun"],
		"texture": load("res://Assets/sprites/Items/Weapons/Guns/revolver.png"),
		"name": "Revolver",
		"value": 200,
		"materials": {"iron": 1, "wood": 0.5}
	},
	"Crowbar": {
		"tags": ["Weapon", "Melee"],
		"texture": load("res://Assets/sprites/Items/Weapons/Melee/crowbar.png"),
		"name": "Crowbar",
		"value": 100,
		"materials": {"iron": 4}
	},
	"Document": {
		"tags": ["Special", "QuestItem"],
		"texture": load("res://Assets/sprites/Items/Special/document.png"),
		"name": "Document",
		"value": 100,
		"materials": {"paper": 0.1}
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
		for property in data:
			self[property] = data[property]
		#texture = data.texture
		#name = data.name
		#value = data.value
		#tags = data.tags
	else:
		print_debug(item_id, " is not a valid item_id")
