extends Node3D

@export var wielder: Node3D
@export var stats: WeaponStats

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(wielder, stats.damage)
