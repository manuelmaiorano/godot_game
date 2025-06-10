extends RigidBody3D

var strength = 1
var velocity_to_signal = 2.3

func take_damage(shooter, damage):
	var direction = (global_position - shooter.global_position).normalized()
	apply_central_impulse(direction * strength)


func _on_body_entered(body: Node) -> void:
	if linear_velocity.length() > velocity_to_signal:
		SignalBus.WorldEvent.emit(global_position)
		print("rock fell")
		
