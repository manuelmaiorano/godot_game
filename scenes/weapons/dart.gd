extends CharacterBody3D

@onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * ProjectSettings.get_setting("physics/3d/default_gravity_vector")

@export var stats: WeaponStats
var shooter: Node3D


func _physics_process(delta: float) -> void:
	velocity += gravity * delta
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		if collider.has_method("take_damage"):
			collider.take_damage(shooter, stats.damage)
		queue_free()
