extends CanvasLayer

@onready var money_label: Label = $MoneyLabel

signal start_screen_override

func _ready() -> void:
	GuiManager.gui = get_node(".") # Tell manager to use this gui
	GameState.money_changed.connect(update_money_label)

func update_money_label():
	money_label.text = "Money: $" + str(GameState.money)
