extends Node3D

var is_close = false

func _on_area_3d_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
	SignalBus.CloseToInteractable.emit()
	is_close = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
	SignalBus.FarFromInteractable.emit()
	is_close = false


func _unhandled_input(event: InputEvent) -> void:
	if not is_close:
		return
		
	if Input.is_action_just_pressed("interact"):
		SignalBus.ItemRetrieved.emit()
		queue_free()
