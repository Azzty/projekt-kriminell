extends Node

# Different types of items
# Base-class for all items
class Item:
	var item_texture: Texture
	var item_name: String
	var item_value: float
	

# Subclasses for all types of items
class Weapon extends Item:
	pass
class Special extends Item:
	pass
class Misc extends Item:
	pass
class Materials extends Item:
	pass

# Subclass for all guns
class Gun extends Weapon:
	var gun_types = {
		"Revolver": {
			"texture": load("res://Assets/sprites/Items/Weapons/Guns/revolver.png"),
			"name": "Revolver",
			"value": 200
		}
	}
	func _init(gun_type: String) -> void:
		var gun_data = gun_types[gun_type]
		self.item_name = gun_data.name
		self.item_texture = gun_data.texture
		self.item_value = gun_data.value
	pass
# Subclass for all melee
class Melee extends Weapon:
	func _init(
		name: String = "Melee",
		texture: Texture = load("res://Assets/sprites/Items/Weapons/Melee/crowbar.png")
		) -> void:
		self.item_name = name
		self.item_texture = texture
	pass
