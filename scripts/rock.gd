extends Node3D

@export var stats: WeaponStats
@export var shooter: Node
@onready var rigid_body_3d: RigidBody3D = %RigidBody3D
@onready var detect_area: Area3D = %DetectArea

func _ready() -> void:
	$RigidBody3D/DetectArea/CollisionShape3D.debug_color = Color.YELLOW
	
func apply_impulse(velocity):
	rigid_body_3d.linear_velocity = velocity
	#rigid_body_3d.apply_central_impulse(velocity)
	

func activate():
	$RigidBody3D/DetectArea/CollisionShape3D.debug_color = Color.RED
	for body in detect_area.get_overlapping_bodies():
		if body.has_method("take_explosion_damage"):
			var velocity = (body.global_position - global_position + Vector3.UP).normalized() * 100
			body.take_explosion_damage(velocity, stats.damage)
	rigid_body_3d.freeze = true
	
	
func _on_rigid_body_3d_body_entered(body: Node) -> void:

	if body.has_method("take_damage"):
		body.take_damage(shooter, stats.damage)
	
	activate()
	await get_tree().create_timer(1.0).timeout
	queue_free()
