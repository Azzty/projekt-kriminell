extends Control

@onready var speed_upgrade: Control = %SpeedUpgrade
@onready var sell_upgrade: Control = %SellUpgrade

var speed_upgrade_cost: int
var sell_upgrade_cost: int

signal exit

func _ready() -> void:
	_update_speed_button()
	_update_sell_button()

func _update_speed_button():
	var speed_upgrade_amount := (int(GameState.player_speed / 50) - int(GameState.DEFAULT_PLAYER_SPEED / 50) + 1)
	speed_upgrade_cost = speed_upgrade_amount * 100
	speed_upgrade.find_child("Button").text = "Cost: $" + str(speed_upgrade_cost)

func _update_sell_button():
	var sell_upgrade_amount: int = GameState.multiplier_upgrade / 0.1 - 9
	sell_upgrade_cost = sell_upgrade_amount * 100
	sell_upgrade.find_child("Button").text = "Cost: $" + str(sell_upgrade_cost)

## Increases the speed variable by 50
func _upgrade_speed() -> void:
	if GameState.money - speed_upgrade_cost >= 0:
		GameState.player_speed += 50
		GameState.money -= speed_upgrade_cost
		_update_speed_button()

## Increases the multiplier_upgrade by 0.1
func _upgrade_sell_multiplier() -> void:
	if GameState.money - sell_upgrade_cost >= 0:
		GameState.multiplier_upgrade += 0.1
		GameState.money -= sell_upgrade_cost
		_update_sell_button()
