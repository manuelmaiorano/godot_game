extends Node3D

@export var dart_scene: PackedScene
@onready var dart_attachment: Marker3D = %DartAttachment
@onready var camera_3d: Camera3D = %Camera3D
@onready var pitch: MeshInstance3D = $ballista/Yaw/Pitch
@onready var yaw: MeshInstance3D = $ballista/Yaw

var player_close = false
var is_active = false
var shooter = null

func make_camera_current():
	camera_3d.make_current()
	
		
func fire():
	var instance = dart_scene.instantiate()
	add_child(instance)
	instance.shooter = shooter
	instance.global_transform = dart_attachment.global_transform
	instance.velocity = - dart_attachment.global_basis.z * 100


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		SignalBus.CloseToInteractable.emit()
		player_close = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		SignalBus.FarFromInteractable.emit()
		player_close = false


func _unhandled_input(event: InputEvent) -> void:
	if not player_close:
		return
	
	if not is_active:
		if Input.is_action_just_pressed("interact"):
			SignalBus.BallistaModeEnter.emit(self)
			is_active = true
	else:
		if Input.is_action_just_pressed("interact"):
			SignalBus.BallistaModeExit.emit()
			is_active = false
		
