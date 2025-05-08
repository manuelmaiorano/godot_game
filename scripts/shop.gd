extends Node3D


func _on_area_3d_body_entered(body: Node3D) -> void:
	SignalBus.ShopEntered.emit()


func _on_area_3d_body_exited(body: Node3D) -> void:
	SignalBus.ShopExited.emit()
