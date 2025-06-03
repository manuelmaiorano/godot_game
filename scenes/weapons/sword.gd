extends Node3D

@export var wielder: Node3D
@export var stats: WeaponStats
@export var active: bool = false

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == wielder:
		return
		
	if body.has_method("take_damage") and active:
		body.take_damage(wielder, stats.damage)
