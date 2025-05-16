extends Node3D

@export var dart_scene: PackedScene
@export var rotation_interpolate_speed: float

@onready var dart_attachment: Marker3D = %DartAttachment
@onready var camera_3d: Camera3D = %Camera3D
@onready var pitch: MeshInstance3D = $ballista/Yaw/Pitch
@onready var yaw: MeshInstance3D = $ballista/Yaw
@onready var operator_position: Marker3D = %OperatorPosition

var player_close = false
var is_active = false
var shooter = null

func make_camera_current():
	camera_3d.make_current()

func aim_at(target, delta):
	var direction: Vector3 = global_position - target.global_position
	direction.y = 0
	if direction.is_zero_approx():
		return
	
	var q_from = yaw.basis.get_rotation_quaternion()
	var q_to = Transform3D().looking_at(direction.normalized(), Vector3.UP, true).basis.get_rotation_quaternion()
	
	
	# Interpolate current rotation with desired one.
	yaw.basis = Basis(q_from.slerp(q_to, delta * rotation_interpolate_speed))
	return q_from.angle_to(q_to)

		
func fire():
	var instance = dart_scene.instantiate()
	add_child(instance)
	instance.shooter = shooter
	instance.global_transform = dart_attachment.global_transform
	instance.velocity = - dart_attachment.global_basis.z * 100


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		if shooter == null:
			SignalBus.CloseToInteractable.emit()
			player_close = true
		return
	
	if body.has_method("close_to_ballista"):
		body.close_to_ballista(self)
	
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
		
