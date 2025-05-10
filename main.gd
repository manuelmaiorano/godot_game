extends Node3D
@onready var state_chart: StateChart = %StateChart


func _ready() -> void:
	SignalBus.ShopEntered.connect(func (x): state_chart.send_event("to_menu"))
	SignalBus.ShopExited.connect(func (): state_chart.send_event("to_playing"))
	SignalBus.PlayerDead.connect(func (): state_chart.send_event("player_dead"))
	SignalBus.ItemRetrieved.connect(func (): state_chart.send_event("item_retrieved"); SignalBus.MissionStatusChanged.emit("back to ship"))
	SignalBus.CloseToShip.connect(func (): state_chart.send_event("back_to_ship"))
	SignalBus.RestartGame.connect(func (): get_tree().reload_current_scene())

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_playing_state_entered() -> void:
	SignalBus.MissionStatusChanged.emit("get item")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false


func _on_menu_mode_state_entered() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true


func _on_game_over_state_entered() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	



func _on_returned_to_ship_state_entered() -> void:
	SignalBus.MissionCompleted.emit()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
