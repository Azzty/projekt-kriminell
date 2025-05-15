extends CanvasLayer

@onready var money_label: Label = $MoneyLabel
@onready var time_label: Label = $TimeLabel

@warning_ignore("unused_signal")
signal start_screen_override

func _ready() -> void:
	GuiManager.gui = get_node(".") # Tell manager to use this gui
	GameState.money_changed.connect(update_money_label)
	GuiManager.timer_value_changed.connect(update_time_label)

func update_money_label():
	money_label.text = "Money: $" + str(GameState.money)

func update_time_label(new_time: float):
	time_label.text = str(snapped(new_time, 0.1)) + " s"
