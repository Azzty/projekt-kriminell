extends CanvasLayer

signal fade_in_finished
signal fade_out_finished

@onready var black_screen: Sprite2D = %BlackScreen

## Turns from black to transparent
func fade_in(duration := 1.0):
	var fade := create_tween()
	fade.tween_property(black_screen, "modulate", Color(0,0,0,0), duration)
	await fade.finished
	fade_in_finished.emit()

## Turns from transparent to black
func fade_out(duration := 1.0):
	var fade := create_tween()
	fade.tween_property(black_screen, "modulate", Color(0,0,0,1), duration)
	await fade.finished
	fade_out_finished.emit()
