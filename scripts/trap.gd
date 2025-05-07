extends Node3D
@onready var detect_area: Area3D = %DetectArea
@export var stats: WeaponStats

func activate():
	for body in detect_area.get_overlapping_bodies():
		if body.has_method("take_explosion_damage"):
			var velocity = (body.global_position - global_position + Vector3.UP).normalized() * 100
			body.take_explosion_damage(velocity)
			#body.take_damage(self, stats.damage)


func _on_switch_body_entered(body: Node3D) -> void:
	activate()
