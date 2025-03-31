extends CanvasLayer

@onready var money_label: Label = $MoneyLabel

func _ready() -> void:
	GameState.money_changed.connect(update_money_label)

func update_money_label():
	money_label.text = "Money: $" + str(GameState.money)
