extends Node3D

@export var stats: WeaponStats
@export var shooter: Node
@onready var rigid_body_3d: RigidBody3D = %RigidBody3D


func apply_impulse(velocity):
	rigid_body_3d.linear_velocity = velocity
	#rigid_body_3d.apply_central_impulse(velocity)
	
func _on_rigid_body_3d_body_entered(body: Node) -> void:

	if body.has_method("take_damage"):
		body.take_damage(shooter, stats.damage)
	queue_free()
