extends Node3D
@onready var state_chart: StateChart = %StateChart


func _ready() -> void:
	SignalBus.ShopEntered.connect(func (x): state_chart.send_event("to_menu"))
	SignalBus.ShopExited.connect(func (): state_chart.send_event("to_playing"))


func _on_playing_state_entered() -> void:
	get_tree().paused = false


func _on_menu_mode_state_entered() -> void:
	get_tree().paused = true
